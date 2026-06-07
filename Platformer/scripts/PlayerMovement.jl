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
        cameraOffsetY::EditorExport{Float64}
        
        # Variable jump variables
        jumpReleased
        minJumpVelocity::EditorExport{Float64}
        jumpDampening::EditorExport{Float64}

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
            this.cameraOffsetY = 2.0
            
            # Variable jump settings
            this.jumpReleased = true
            this.minJumpVelocity = -3.0  # Minimum jump height when button released early
            this.jumpDampening = 0.4  # How much to dampen upward velocity when button released

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
        this.cameraTarget = JulGame.TransformModule.Transform(Vector3f(this.parent.transform.position.x, this.cameraOffsetY, 0.0))
        MAIN.scene.camera.target = this.cameraTarget
        this.cameraTargetX = this.parent.transform.position.x
        this.lastPlayerX = this.parent.transform.position.x
        this.gameManager = JulGame.SceneModule.get_entity_by_name("Game Manager").scripts[1]
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
        
        # Jump input
        jumpPressed = JulGame.InputModule.get_button_pressed(input, "SPACE") || input.button == 1 || this.isJump
        jumpHeld = JulGame.InputModule.get_button_held_down(input, "SPACE") || input.button == 1
        
        if jumpPressed && this.parent.rigidbody.grounded && this.canMove 
            JulGame.Component.toggle_sound(this.jumpSound)
            this.parent.rigidbody.velocity = Vector2f(this.parent.rigidbody.velocity.x, 0)
            JulGame.RigidbodyModule.add_velocity(this.parent.rigidbody, Vector2f(0, this.jumpVelocity))
            this.animator.currentAnimation = this.animator.animations[3]
            this.jumpReleased = false
        end
        
        # Variable jump height: dampen upward velocity when jump button is released
        currentVelocity = JulGame.Component.get_velocity(this.parent.rigidbody)
        if !jumpHeld && !this.jumpReleased && currentVelocity.y < this.minJumpVelocity
            # Player released jump button while still going up - apply dampening
            this.parent.rigidbody.velocity = Vector2f(currentVelocity.x, currentVelocity.y * this.jumpDampening)
            this.jumpReleased = true
        end
        
        # Reset jumpReleased when grounded
        if this.parent.rigidbody.grounded
            this.jumpReleased = true
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
        
        this.parent.rigidbody.velocity = Vector2f(x, this.parent.rigidbody.velocity.y)
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
            this.cameraTarget.position = Vector3f(newCameraX, this.cameraOffsetY, this.cameraTarget.position.z)
        end
        
        # Update last player position for velocity calculation
        this.lastPlayerX = playerX
    end

    function handleCollisions(this::PlayerMovement, collision)
        otherCollider = collision.collider
        if otherCollider.tag == "Coin"
            JulGame.destroy(otherCollider.parent)
            #JulGame.Component.toggle_sound(this.coinSound)
            MAIN.scene.uiElements[1].text = string(parse(Int, split(MAIN.scene.uiElements[1].text, "/")[1]) + 1, "/", parse(Int, split(MAIN.scene.uiElements[1].text, "/")[2]))
            if parse(Int, split(MAIN.scene.uiElements[1].text, "/")[1]) == parse(Int, split(MAIN.scene.uiElements[1].text, "/")[2])
                if this.gameManager.currentLevel == 1
                    if this.deathsThisLevel == 0
                        this.gameManager.starCount = this.gameManager.starCount + 1
                    end
                    this.gameManager.currentLevel = 2
                    JulGame.change_scene("level_2.json")
                elseif this.gameManager.currentLevel == 2
                    if this.deathsThisLevel == 0
                        this.gameManager.starCount = this.gameManager.starCount + 1
                    end
                    this.gameManager.currentLevel = 3
                    JulGame.change_scene("level_3.json")
                else 
                    # you win text
                    MAIN.scene.uiElements[1].isCenteredX, MAIN.scene.uiElements[1].isCenteredY = true, true
                    MAIN.scene.uiElements[1].text = "You Win!"

                    if this.deathsThisLevel == 0
                        this.gameManager.starCount = this.gameManager.starCount + 1
                        MAIN.scene.uiElements[2].text = string(this.gameManager.starCount)
                    end
                end
            end
        elseif otherCollider.tag == "Hazard"
            respawn(this)
        elseif otherCollider.tag == "Star"
            #JulGame.Component.toggle_sound(this.starSound)
            JulGame.destroy(otherCollider.parent)
            this.gameManager.starCount = this.gameManager.starCount + 1
            MAIN.scene.uiElements[2].text = string(this.gameManager.starCount)
        end
    end

    function respawn(this::PlayerMovement)
       # JulGame.Component.toggle_sound(this.hurtSound)
        pos = this.parent.transform.position
        this.parent.transform.position = Vector3f(1, 4, pos.z)
        this.gameManager.starCount = max(this.gameManager.starCount - 1, 0)
        MAIN.scene.uiElements[2].text = string(this.gameManager.starCount)
        this.deathsThisLevel += 1
        
        # Reset camera smoothing state
        this.cameraTargetX = this.parent.transform.position.x
        this.cameraLerpTime = 0.0
        this.lastPlayerX = this.parent.transform.position.x
        this.cameraVelocity = 0.0
    end
end # module    