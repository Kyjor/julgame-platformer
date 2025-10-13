module SpiderModule    
    using JulGame

    mutable struct Spider <: Script
        animator
        isMovingRight::Bool
        parent::JulGame.EntityModule.Entity
        sound::JulGame.SoundSourceModule.SoundSource
        speed::EditorExport{Float64}
        startingX::EditorExport{Int}
        endingX::EditorExport{Int}

        function Spider()
            this = new()

            this.endingX = 0
            this.isMovingRight = false
            this.startingX = 0
            this.speed = 0.0

            return this
        end
    end

    function JulGame.initialize(this::Spider)
        this.animator = this.parent.animator
        this.parent.transform.position = Vector2f(this.startingX, this.parent.transform.position.y)
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