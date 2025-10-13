module FishModule
    using JulGame

    mutable struct Fish <: Script
        animator
        endingY::EditorExport{Int}
        isFire::EditorExport{Bool}
        isMovingUp::Bool
        parent::JulGame.EntityModule.Entity
        sound::SoundSourceModule.SoundSource
        speed::EditorExport{Float64}
        startingY::EditorExport{Int}

        function Fish()
            this = new()

            this.endingY = 0
            this.isFire = false
            this.isMovingUp = false
            this.speed = 0.0
            this.startingY = 0

            return this
        end
    end

    function JulGame.initialize(this::Fish)
        this.animator = this.parent.animator
        this.parent.sprite.rotation = 90.0
        this.parent.transform.position = Vector2f(this.parent.transform.position.x, this.startingY)
    end

    function JulGame.update(this::Fish, deltaTime)
        if this.parent.transform.position.y >= this.startingY && !this.isMovingUp
            this.parent.sprite.rotation = this.isFire ? 0 : 90.0
            this.isMovingUp = true
        elseif this.parent.transform.position.y <= this.endingY && this.isMovingUp
            this.parent.sprite.rotation = this.isFire ? 180.0 : 270.0
            this.isMovingUp = false
        end

        if this.isMovingUp
            this.parent.transform.position = Vector2f(this.parent.transform.position.x, this.parent.transform.position.y - this.speed*deltaTime)
        else
            this.parent.transform.position = Vector2f(this.parent.transform.position.x, this.parent.transform.position.y + this.speed*deltaTime)
        end
    end
end # module