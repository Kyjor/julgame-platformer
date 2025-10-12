module SawModule
    using JulGame

    mutable struct Saw <: Script
        animator::AnimatorModule.Animator
        endingY::Float64
        isMovingUp::Bool
        rotation::Float64
        parent::JulGame.EntityModule.Entity
        sound::SoundSourceModule.SoundSource
        speed::Number
        startingY::Float64

        function Saw()
            this = new()

            this.endingY = 3
            this.isMovingUp = false
            this.rotation = 0.0
            this.speed = 5.0
            this.startingY = 0

            return this
        end
    end

    function JulGame.update(this::Saw, deltaTime)
        this.rotation += 5.0
        this.parent.sprite.rotation =  this.rotation % 360.0

        if this.parent.transform.position.y >= this.startingY && !this.isMovingUp
            this.isMovingUp = true
        elseif this.parent.transform.position.y <= this.endingY && this.isMovingUp
            this.isMovingUp = false
        end

        if this.isMovingUp
            this.parent.transform.position = Vector2f(this.parent.transform.position.x, this.parent.transform.position.y - this.speed*deltaTime)
        else
            this.parent.transform.position = Vector2f(this.parent.transform.position.x, this.parent.transform.position.y + this.speed*deltaTime)
        end
    end
end # module