import { registerScript } from "julgame/src/engine/runtime/scriptRegistry";
import { registerScriptSounds } from "julgame/src/engine/runtime/scriptRegistry";

function ease_out_cubic(x: number): number {
    return 1 - Math.pow(1 - x, 3);
}


    // using JulGame
    // include("Easings.jl")

    export class PlayerMovement {
        animator
        cameraTarget
        canMove
        coinSound
        deathsThisLevel
        gameManager
        hurtSound
        input
        isFacingRight
        isJump 
        jumpVelocity: number
        jumpSound
        parent
        starSound
        cameraOffsetY: number
        
        // Variable jump variables
        jumpReleased
        minJumpVelocity: number
        jumpDampening: number

        xDir
        yDir
        
        // Camera smoothing variables
        cameraFollowSpeed
        cameraTargetX
        cameraLerpTime
        
        // Advanced camera features
        deadZoneWidth
        lookaheadDistance
        lookaheadSpeed
        cameraVelocity
        lastPlayerX

        constructor() {
            

            this.canMove = false
            this.input = null
            this.isFacingRight = true
            this.isJump = false
            this.parent = null
            this.jumpSound = null 
            this.jumpVelocity = -10.0
            this.cameraOffsetY = 2.0
            
            // Variable jump settings
            this.jumpReleased = true
            this.minJumpVelocity = -3.0  // Minimum jump height when button released early
            this.jumpDampening = 0.4  // How much to dampen upward velocity when button released

            this.xDir = 0
            this.yDir = 0
            
            // Initialize camera smoothing
            this.cameraFollowSpeed = 4.0
            this.cameraTargetX = 0.0
            this.cameraLerpTime = 0.0
            
            // Initialize advanced camera features
            this.deadZoneWidth = 2.0  // Player can move this distance without camera moving
            this.lookaheadDistance = 1.5  // How far ahead to look based on velocity
            this.lookaheadSpeed = 0.8  // How quickly lookahead responds
            this.cameraVelocity = 0.0
            this.lastPlayerX = 0.0

        }
    }

    function JulGame_initialize_PlayerMovement(self: PlayerMovement) {
        self.animator = self.parent.animator
        self.animator.currentAnimation = self.animator.animations[0]
        self.jumpSound = self.parent.soundSource
        self.cameraTarget = { position: { x: self.parent.transform.position.x, y: self.cameraOffsetY, z: 0.0 }, scale: { x: 1, y: 1, z: 1 } };
        (globalThis as any).MAIN.scene.camera.target = self.cameraTarget
        self.cameraTargetX = self.parent.transform.position.x
        self.lastPlayerX = self.parent.transform.position.x
        self.gameManager = (globalThis as any).JulGame.SceneModule.get_entity_by_name((globalThis as any).MAIN.scene, "Game Manager").scripts[0]
        self.deathsThisLevel = 0
        // self.coinSound = (globalThis as any).JulGame.create_sound_source(self.parent, (globalThis as any).JulGame.SoundSourceModule.SoundSource(Number(-1), false, "coin.wav", 50))
        // self.hurtSound = (globalThis as any).JulGame.create_sound_source(self.parent, (globalThis as any).JulGame.SoundSourceModule.SoundSource(Number(-1), false, "hit.wav", 50))
        // self.starSound = (globalThis as any).JulGame.create_sound_source(self.parent, (globalThis as any).JulGame.SoundSourceModule.SoundSource(Number(-1), false, "power-up.wav", 50))
        let collisionEvent = (col: any) => handleCollisions(self, col);
        (globalThis as any).JulGame.Component.add_collision_event(self.parent.collider, collisionEvent)
    }

    function JulGame_update_PlayerMovement(self: PlayerMovement, deltaTime) {
        self.canMove = true
        let x = 0
        let speed = 5
        let input = (globalThis as any).MAIN.input

        // Inputs match SDL2 scancodes after "SDL_SCANCODE_"
        // https://wiki.libsdl.org/SDL2/SDL_Scancode
        // Spaces full scancode is "SDL_SCANCODE_SPACE" so we use "SPACE". Every other key is the same.
        
        // Jump input
        let jumpPressed = (globalThis as any).JulGame.InputModule.get_button_pressed(input, "SPACE") || input.button == 1 || self.isJump
        let jumpHeld = (globalThis as any).JulGame.InputModule.get_button_held_down(input, "SPACE") || input.button == 1
        
        if (jumpPressed && self.parent.rigidbody.grounded && self.canMove) {
            (globalThis as any).JulGame.Component.toggle_sound(self.jumpSound)
            self.parent.rigidbody.velocity = {x: self.parent.rigidbody.velocity.x, y: 0};
            (globalThis as any).JulGame.RigidbodyModule.add_velocity(self.parent.rigidbody, {x: 0, y: self.jumpVelocity})
            self.animator.currentAnimation = self.animator.animations[2]
            self.jumpReleased = false
        }
        
        // Variable jump height: dampen upward velocity when jump button is released
        let currentVelocity = (globalThis as any).JulGame.RigidbodyModule.Component_get_velocity(self.parent.rigidbody)
        if (!jumpHeld && !self.jumpReleased && currentVelocity.y < self.minJumpVelocity) {
            // Player released jump button while still going up - apply dampening
            self.parent.rigidbody.velocity = {x: currentVelocity.x, y: currentVelocity.y * self.jumpDampening}
            self.jumpReleased = true
        }
        
        // Reset jumpReleased when grounded
        if (self.parent.rigidbody.grounded) {
            self.jumpReleased = true
        }
        if (((globalThis as any).JulGame.InputModule.get_button_held_down(input, "A") || (globalThis as any).JulGame.InputModule.get_button_held_down(input, "LEFT") || input.xDir == -1) && self.canMove) {
            x = -speed
            if (self.parent.rigidbody.grounded) {
                self.animator.currentAnimation = self.animator.animations[1]
            }
            if (self.isFacingRight) {
                self.isFacingRight = false;
                (globalThis as any).JulGame.Component.flip(self.parent.sprite)
            }
        } else if (((globalThis as any).JulGame.InputModule.get_button_held_down(input, "D")  || (globalThis as any).JulGame.InputModule.get_button_held_down(input, "RIGHT") || input.xDir == 1) && self.canMove) {
            if (self.parent.rigidbody.grounded) {
                self.animator.currentAnimation = self.animator.animations[1]
            }
            x = speed
            if (!self.isFacingRight) {
                self.isFacingRight = true;
                (globalThis as any).JulGame.Component.flip(self.parent.sprite)
            }
        } else if (self.parent.rigidbody.grounded) {
            self.animator.currentAnimation = self.animator.animations[0]
        }
        
        self.parent.rigidbody.velocity = {x: x, y: self.parent.rigidbody.velocity.y}
        x = 0
        self.isJump = false
        if (self.parent.transform.position.y > 8) {
            respawn(self)
        }

        // Advanced camera system with dead zone and lookahead
        let playerX = self.parent.transform.position.x
        let playerVelocity = (playerX - self.lastPlayerX) / deltaTime
        
        // Calculate lookahead based on player velocity
        let lookaheadTarget = 0.0
        if (Math.abs(playerVelocity) > 0.1) {
            lookaheadTarget = Math.sign(playerVelocity) * self.lookaheadDistance * Math.min(Math.abs(playerVelocity) / 10.0, 1.0)
        }
        
        // Smooth the lookahead target
        self.cameraVelocity += (lookaheadTarget - self.cameraVelocity) * self.lookaheadSpeed * deltaTime
        
        // Calculate ideal camera position (player + lookahead)
        let idealCameraX = playerX + self.cameraVelocity
        
        // Apply dead zone - only move camera if player is outside dead zone
        let deadZoneLeft = self.cameraTargetX - self.deadZoneWidth / 2
        let deadZoneRight = self.cameraTargetX + self.deadZoneWidth / 2
        
        if (idealCameraX < deadZoneLeft) {
            // Player moved left beyond dead zone
            self.cameraTargetX = idealCameraX + self.deadZoneWidth / 2
        } else if (idealCameraX > deadZoneRight) {
            // Player moved right beyond dead zone
            self.cameraTargetX = idealCameraX - self.deadZoneWidth / 2
        }
        
        // Smooth camera movement with ease_out_cubic for very smooth motion
        let currentCameraX = self.cameraTarget.position.x
        let distance = Math.abs(self.cameraTargetX - currentCameraX)
        
        if (distance > 0.001) {
            // Use ease_out_cubic for ultra-smooth movement
            let lerpFactor = Math.min(deltaTime * self.cameraFollowSpeed, 1.0)
            let easedLerp = ease_out_cubic(lerpFactor)
            let newCameraX = currentCameraX + (self.cameraTargetX - currentCameraX) * easedLerp
            self.cameraTarget.position = {x: newCameraX, y: self.cameraOffsetY, z: self.cameraTarget.position.z}
        }
        
        // Update last player position for velocity calculation
        self.lastPlayerX = playerX
    }

    function handleCollisions(self: PlayerMovement, collision) {
        let otherCollider = collision.collider
        if (otherCollider.tag == "Coin") {
            (globalThis as any).JulGame.destroy_entity((globalThis as any).MAIN, otherCollider.parent);
            //(globalThis as any).JulGame.Component.toggle_sound(self.coinSound)
            (globalThis as any).MAIN.scene.uiElements[0].text = [parseInt( (globalThis as any).MAIN.scene.uiElements[0].text.split('/')[0]) + 1, "/", parseInt( (globalThis as any).MAIN.scene.uiElements[0].text.split('/')[1])].join("")
            if (parseInt( (globalThis as any).MAIN.scene.uiElements[0].text.split('/')[0]) == parseInt( (globalThis as any).MAIN.scene.uiElements[0].text.split('/')[1])) {
                if (self.gameManager.currentLevel == 1) {
                    if (self.deathsThisLevel == 0) {
                        self.gameManager.starCount = self.gameManager.starCount + 1
                    }
                    self.gameManager.currentLevel = 2;
                    (globalThis as any).JulGame.change_scene("level_2.json")
                } else if (self.gameManager.currentLevel == 2) {
                    if (self.deathsThisLevel == 0) {
                        self.gameManager.starCount = self.gameManager.starCount + 1
                    }
                    self.gameManager.currentLevel = 3;
                    (globalThis as any).JulGame.change_scene("level_3.json")
                } else { 
                    // you win text
                    (globalThis as any).MAIN.scene.uiElements[0].isCenteredX, (globalThis as any).MAIN.scene.uiElements[0].isCenteredY = true, true;
                    (globalThis as any).MAIN.scene.uiElements[0].text = "You Win!"

                    if (self.deathsThisLevel == 0) {
                        self.gameManager.starCount = self.gameManager.starCount + 1;
                        (globalThis as any).MAIN.scene.uiElements[1].text = String(self.gameManager.starCount)
                    }
                }
            }
        } else if (otherCollider.tag == "Hazard") {
            respawn(self)
        } else if (otherCollider.tag == "Star") {
            //(globalThis as any).JulGame.Component.toggle_sound(self.starSound)
            (globalThis as any).JulGame.destroy_entity((globalThis as any).MAIN, otherCollider.parent)
            self.gameManager.starCount = self.gameManager.starCount + 1;
            (globalThis as any).MAIN.scene.uiElements[1].text = String(self.gameManager.starCount)
        }
    }

    function respawn(self: PlayerMovement) {
       // (globalThis as any).JulGame.Component.toggle_sound(self.hurtSound)
        let pos = self.parent.transform.position
        self.parent.transform.position = {x: 1, y: 4, z: pos.z}
        self.gameManager.starCount = Math.max(self.gameManager.starCount - 1, 0);
        (globalThis as any).MAIN.scene.uiElements[1].text = String(self.gameManager.starCount)
        self.deathsThisLevel += 1
        
        // Reset camera smoothing state
        self.cameraTargetX = self.parent.transform.position.x
        self.cameraLerpTime = 0.0
        self.lastPlayerX = self.parent.transform.position.x
        self.cameraVelocity = 0.0
    }
registerScript("PlayerMovement", {
    create: () => new PlayerMovement(),
    initialize: JulGame_initialize_PlayerMovement,
    update: JulGame_update_PlayerMovement,
});
registerScriptSounds(["coin.wav", "hit.wav", "power-up.wav"]);
