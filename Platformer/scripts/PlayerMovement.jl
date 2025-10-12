module PlayerMovementModule
    using JulGame
    include("Easings.jl")

    mutable struct PlayerMovement <: Script
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
        jumpVelocity::EditorExport{Float64}
        jumpSound
        parent
        starSound

        xDir
        yDir
        
        # Camera smoothing variables
        cameraFollowSpeed
        cameraTargetX
        cameraLerpTime
        
        # Advanced camera features
        deadZoneWidth
        lookaheadDistance
        lookaheadSpeed
        cameraVelocity
        lastPlayerX

        function PlayerMovement()
            this = new()

            this.canMove = false
            this.input = C_NULL
            this.isFacingRight = true
            this.isJump = false
            this.parent = C_NULL
            this.jumpSound = C_NULL 
            this.jumpVelocity = -10.0

            this.xDir = 0
            this.yDir = 0
            
            # Initialize camera smoothing
            this.cameraFollowSpeed = 4.0
            this.cameraTargetX = 0.0
            this.cameraLerpTime = 0.0
            
            # Initialize advanced camera features
            this.deadZoneWidth = 2.0  # Player can move this distance without camera moving
            this.lookaheadDistance = 1.5  # How far ahead to look based on velocity
            this.lookaheadSpeed = 0.8  # How quickly lookahead responds
            this.cameraVelocity = 0.0
            this.lastPlayerX = 0.0

            return this
        end
    end

    function JulGame.initialize(this::PlayerMovement)
        this.animator = this.parent.animator
        this.animator.currentAnimation = this.animator.animations[1]
        this.jumpSound = this.parent.soundSource
        this.cameraTarget = JulGame.TransformModule.Transform(Vector2f(this.parent.transform.position.x, 0))
        MAIN.scene.camera.target = this.cameraTarget
        this.cameraTargetX = this.parent.transform.position.x
        this.lastPlayerX = this.parent.transform.position.x
        this.gameManager = JulGame.SceneModule.get_entity_by_name(MAIN.scene, "Game Manager").scripts[1]
        this.deathsThisLevel = 0
        # this.coinSound = JulGame.create_sound_source(this.parent, JulGame.SoundSourceModule.SoundSource(Int32(-1), false, "coin.wav", Int32(50)))
        # this.hurtSound = JulGame.create_sound_source(this.parent, JulGame.SoundSourceModule.SoundSource(Int32(-1), false, "hit.wav", Int32(50)))
        # this.starSound = JulGame.create_sound_source(this.parent, JulGame.SoundSourceModule.SoundSource(Int32(-1), false, "power-up.wav", Int32(50)))
        collisionEvent = JulGame.Macros.@argevent (col) handleCollisions(this, col)
        JulGame.Component.add_collision_event(this.parent.collider, collisionEvent)
    end

    function JulGame.update(this::PlayerMovement, deltaTime)
        this.canMove = true
        x = 0
        speed = 5
        input = MAIN.input

        # Inputs match SDL2 scancodes after "SDL_SCANCODE_"
        # https://wiki.libsdl.org/SDL2/SDL_Scancode
        # Spaces full scancode is "SDL_SCANCODE_SPACE" so we use "SPACE". Every other key is the same.
        if ((JulGame.InputModule.get_button_pressed(input, "SPACE")  || input.button == 1)|| this.isJump) && this.parent.rigidbody.grounded && this.canMove 
            JulGame.Component.toggle_sound(this.jumpSound)
            JulGame.RigidbodyModule.set_velocity(this.parent.rigidbody, Vector2f(JulGame.Component.get_velocity(this.parent.rigidbody).x, 0))
            JulGame.RigidbodyModule.add_velocity(this.parent.rigidbody, Vector2f(0, this.jumpVelocity))
            this.animator.currentAnimation = this.animator.animations[3]
        end
        if (JulGame.InputModule.get_button_held_down(input, "A") || JulGame.InputModule.get_button_held_down(input, "LEFT") || input.xDir == -1) && this.canMove
            x = -speed
            if this.parent.rigidbody.grounded
                this.animator.currentAnimation = this.animator.animations[2]
            end
            if this.isFacingRight
                this.isFacingRight = false
                JulGame.Component.flip(this.parent.sprite)
            end
        elseif (JulGame.InputModule.get_button_held_down(input, "D")  || JulGame.InputModule.get_button_held_down(input, "RIGHT") || input.xDir == 1) && this.canMove
            if this.parent.rigidbody.grounded
                this.animator.currentAnimation = this.animator.animations[2]
            end
            x = speed
            if !this.isFacingRight
                this.isFacingRight = true
                JulGame.Component.flip(this.parent.sprite)
            end
        elseif this.parent.rigidbody.grounded
            this.animator.currentAnimation = this.animator.animations[1]
        end
        
        JulGame.RigidbodyModule.set_velocity(this.parent.rigidbody, Vector2f(x, JulGame.Component.get_velocity(this.parent.rigidbody).y))
        x = 0
        this.isJump = false
        if this.parent.transform.position.y > 8
            respawn(this)
        end

        # Advanced camera system with dead zone and lookahead
        playerX = this.parent.transform.position.x
        playerVelocity = (playerX - this.lastPlayerX) / deltaTime
        
        # Calculate lookahead based on player velocity
        lookaheadTarget = 0.0
        if abs(playerVelocity) > 0.1
            lookaheadTarget = sign(playerVelocity) * this.lookaheadDistance * min(abs(playerVelocity) / 10.0, 1.0)
        end
        
        # Smooth the lookahead target
        this.cameraVelocity += (lookaheadTarget - this.cameraVelocity) * this.lookaheadSpeed * deltaTime
        
        # Calculate ideal camera position (player + lookahead)
        idealCameraX = playerX + this.cameraVelocity
        
        # Apply dead zone - only move camera if player is outside dead zone
        deadZoneLeft = this.cameraTargetX - this.deadZoneWidth / 2
        deadZoneRight = this.cameraTargetX + this.deadZoneWidth / 2
        
        if idealCameraX < deadZoneLeft
            # Player moved left beyond dead zone
            this.cameraTargetX = idealCameraX + this.deadZoneWidth / 2
        elseif idealCameraX > deadZoneRight
            # Player moved right beyond dead zone
            this.cameraTargetX = idealCameraX - this.deadZoneWidth / 2
        end
        
        # Smooth camera movement with ease_out_cubic for very smooth motion
        currentCameraX = this.cameraTarget.position.x
        distance = abs(this.cameraTargetX - currentCameraX)
        
        if distance > 0.001
            # Use ease_out_cubic for ultra-smooth movement
            lerpFactor = min(deltaTime * this.cameraFollowSpeed, 1.0)
            easedLerp = ease_out_cubic(lerpFactor)
            newCameraX = currentCameraX + (this.cameraTargetX - currentCameraX) * easedLerp
            this.cameraTarget.position = Vector2f(newCameraX, 4.75)
        end
        
        # Update last player position for velocity calculation
        this.lastPlayerX = playerX
    end

    function handleCollisions(this::PlayerMovement, otherCollider)
        return
        if otherCollider.tag == "Coin"
            JulGame.SceneModule.destroy_entity(MAIN, otherCollider.parent)
            #JulGame.Component.toggle_sound(this.coinSound)
            JulGame.UI.update_text(MAIN.scene.uiElements[1], string(parse(Int, split(MAIN.scene.uiElements[1].text, "/")[1]) + 1, "/", parse(Int, split(MAIN.scene.uiElements[1].text, "/")[2])))
            if parse(Int, split(MAIN.scene.uiElements[1].text, "/")[1]) == parse(Int, split(MAIN.scene.uiElements[1].text, "/")[2])
                if this.gameManager.currentLevel == 1
                    if this.deathsThisLevel == 0
                        this.gameManager.starCount = this.gameManager.starCount + 1
                    end
                    this.gameManager.currentLevel = 2
                    JulGame.MainLoop.change_scene("level_2.json")
                elseif this.gameManager.currentLevel == 2
                    if this.deathsThisLevel == 0
                        this.gameManager.starCount = this.gameManager.starCount + 1
                    end
                    this.gameManager.currentLevel = 3
                    JulGame.MainLoop.change_scene("level_3.json")
                else 
                    # you win text
                    MAIN.scene.uiElements[1].isCenteredX, MAIN.scene.uiElements[1].isCenteredY = true, true
                    JulGame.UI.update_text(MAIN.scene.uiElements[1], "You Win!")

                    if this.deathsThisLevel == 0
                        this.gameManager.starCount = this.gameManager.starCount + 1
                        JulGame.UI.update_text(MAIN.scene.uiElements[2], string(this.gameManager.starCount))
                    end
                end
            end
        elseif otherCollider.tag == "Hazard"
            respawn(this)
        elseif otherCollider.tag == "Star"
            #JulGame.Component.toggle_sound(this.starSound)
            JulGame.SceneModule.destroy_entity(MAIN, otherCollider.parent)
            this.gameManager.starCount = this.gameManager.starCount + 1
            JulGame.UI.update_text(MAIN.scene.uiElements[2], string(this.gameManager.starCount))
        end
    end

    function respawn(this::PlayerMovement)
       # JulGame.Component.toggle_sound(this.hurtSound)
        this.parent.transform.position = Vector2f(1, 4)
        this.gameManager.starCount = max(this.gameManager.starCount - 1, 0)
        #JulGame.UI.update_text(MAIN.scene.uiElements[2], string(this.gameManager.starCount))
        this.deathsThisLevel += 1
        
        # Reset camera smoothing state
        this.cameraTargetX = this.parent.transform.position.x
        this.cameraLerpTime = 0.0
        this.lastPlayerX = this.parent.transform.position.x
        this.cameraVelocity = 0.0
    end
end # module    