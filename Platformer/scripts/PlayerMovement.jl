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
            event = @event begin
                #this.jump()
            end
            this.animator = this.parent.getAnimator()
            this.animator.currentAnimation = this.animator.animations[1]
            this.jumpSound = this.parent.getSoundSource()
            this.cameraTarget = Transform(Vector2f(this.parent.getTransform().position.x, 0))
            MAIN.scene.camera.target = this.cameraTarget
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
                this.parent.getTransform().position = Vector2f(1, 4)
            end

            this.cameraTarget.position = Vector2f(this.parent.getTransform().position.x, 2.75)
        end
    elseif s == :setParent
        function(parent)
            this.parent = parent
            collisionEvent = @event begin
                this.handleCollisions()
            end
            this.parent.getComponent(Collider).addCollisionEvent(collisionEvent)
        end
    elseif s == :handleCollisions
        function()
            collider = this.parent.getComponent(Collider)
            for collision in collider.currentCollisions
                if collision.tag == "Coin"
                    DestroyEntity(collision.parent)
                end
            end
        end
    else
        getfield(this, s)
    end
end