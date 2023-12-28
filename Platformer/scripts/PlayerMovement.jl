using JulGame.AnimationModule
using JulGame.AnimatorModule
using JulGame.RigidbodyModule
using JulGame.Macros
using JulGame.Math
using JulGame.MainLoop
using JulGame.SoundSourceModule
using JulGame.TransformModule

mutable struct PlayerMovement
    animator
    cameraTarget
    canMove
    coinSound
    gameManager
    input
    isFacingRight
    isJump 
    jumpVelocity
    jumpSound
    parent

    xDir
    yDir

    function PlayerMovement(jumpVelocity = -10)
        this = new()

        this.canMove = false
        this.input = C_NULL
        this.isFacingRight = true
        this.isJump = false
        this.parent = C_NULL
        this.coinSound = SoundSource("coin.wav", 1, 50)
        this.jumpSound = C_NULL 
        this.jumpVelocity = typeof(jumpVelocity) === Float64 ? jumpVelocity : parse(Float64, jumpVelocity)

        this.xDir = 0
        this.yDir = 0

        return this
    end
end

function Base.getproperty(this::PlayerMovement, s::Symbol)
    if s == :initialize
        function()
            this.animator = this.parent.getAnimator()
            this.animator.currentAnimation = this.animator.animations[1]
            this.jumpSound = this.parent.getSoundSource()
            this.cameraTarget = Transform(Vector2f(this.parent.getTransform().position.x, 0))
            MAIN.scene.camera.target = this.cameraTarget
            for entity in MAIN.scene.entities
                if entity.name == "Game Manager"
                    println("found game manager")
                end
            end
            this.gameManager = MAIN.scene.getEntityByName("Game Manager").scripts[1]
        end
    elseif s == :update
        function(deltaTime)
            this.canMove = true
            x = 0
            speed = 5
            input = MAIN.input

            # Inputs match SDL2 scancodes after "SDL_SCANCODE_"
            # https://wiki.libsdl.org/SDL2/SDL_Scancode
            # Spaces full scancode is "SDL_SCANCODE_SPACE" so we use "SPACE". Every other key is the same.
            if ((input.getButtonPressed("SPACE")  || input.button == 1)|| this.isJump) && this.parent.getRigidbody().grounded && this.canMove 
                this.jumpSound.toggleSound()
                AddVelocity(this.parent.getRigidbody(), Vector2f(0, this.jumpVelocity))
                this.animator.currentAnimation = this.animator.animations[3]
            end
            if (input.getButtonHeldDown("A") || input.xDir == -1) && this.canMove
                if input.getButtonPressed("A")
                end
                x = -speed
                if this.parent.getRigidbody().grounded
                    this.animator.currentAnimation = this.animator.animations[2]
                end
                if this.isFacingRight
                    this.isFacingRight = false
                    this.parent.getSprite().flip()
                end
            elseif (input.getButtonHeldDown("D")  || input.xDir == 1) && this.canMove
                if input.getButtonPressed("D")
                end
                if this.parent.getRigidbody().grounded
                    this.animator.currentAnimation = this.animator.animations[2]
                end
                x = speed
                if !this.isFacingRight
                    this.isFacingRight = true
                    this.parent.getSprite().flip()
                end
            elseif this.parent.getRigidbody().grounded
                this.animator.currentAnimation = this.animator.animations[1]
            end
            
            SetVelocity(this.parent.getRigidbody(), Vector2f(x, this.parent.getRigidbody().getVelocity().y))
            x = 0
            this.isJump = false
            if this.parent.getTransform().position.y > 8
                this.respawn()
            end

            this.cameraTarget.position = Vector2f(this.parent.getTransform().position.x, 2.75)
        end
    elseif s == :setParent
        function(parent)
            this.parent = parent
            collisionEvent = @argevent (col) this.handleCollisions(col)
            this.parent.getComponent(Collider).addCollisionEvent(collisionEvent)
        end
    elseif s == :handleCollisions
        function(otherCollider)
            if otherCollider.tag == "Coin"
                DestroyEntity(otherCollider.parent)
                this.coinSound.toggleSound()
                MAIN.scene.textBoxes[1].updateText(string(parse(Int, split(MAIN.scene.textBoxes[1].text, "/")[1]) + 1, "/", parse(Int, split(MAIN.scene.textBoxes[1].text, "/")[2])))
                if parse(Int, split(MAIN.scene.textBoxes[1].text, "/")[1]) == parse(Int, split(MAIN.scene.textBoxes[1].text, "/")[2])
                    if this.gameManager.currentLevel == 1
                        this.gameManager.currentLevel = 2
                        ChangeScene("level_2.json")
                    elseif this.gameManager.currentLevel == 2
                        this.gameManager.currentLevel = 3
                        ChangeScene("level_3.json")
                    else 
                        # you win text
                        MAIN.scene.textBoxes[1].isCenteredX, MAIN.scene.textBoxes[1].isCenteredY = true, true
                        MAIN.scene.textBoxes[1].updateText("You Win!")
                        MAIN.scene.textBoxes[1].setColor(0,0,0)
                    end
                end
            elseif otherCollider.tag == "Hazard"
                #this.respawn()
            end
        end
    elseif s == :respawn
        function()
            this.parent.getTransform().position = Vector2f(1, 4)
            MAIN.scene.textBoxes[2].updateText(string(parse(Int, MAIN.scene.textBoxes[2].text) - 1))
        end
    else
        getfield(this, s)
    end
end