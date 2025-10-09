module SpiderModule    
    using JulGame

    mutable struct Spider
        animator
        endingX::Int
        isMovingRight::Bool
        parent::JulGame.EntityModule.Entity
        sound::JulGame.SoundSourceModule.SoundSource
        speed::Number
        startingX::Int

        function Spider()
            this = new()

            this.endingX = 0
            this.isMovingRight = false
            this.startingX = 0

            return this
        end
    end

    function JulGame.initialize(this::Spider)
        this.animator = this.parent.animator
    end
    function JulGame.update(this::Spider, deltaTime)
        if this.parent.transform.position.x <= this.startingX && !this.isMovingRight
            JulGame.Component.flip(this.parent.sprite)
            this.isMovingRight = true
        elseif this.parent.transform.position.x >= this.endingX && this.isMovingRight
            JulGame.Component.flip(this.parent.sprite)
            this.isMovingRight = false
        end

        if this.isMovingRight
            this.parent.transform.position = JulGame.Math.Vector2f(this.parent.transform.position.x + this.speed*deltaTime, this.parent.transform.position.y)
        else
            this.parent.transform.position = JulGame.Math.Vector2f(this.parent.transform.position.x - this.speed*deltaTime, this.parent.transform.position.y)
        end
    end
end # module