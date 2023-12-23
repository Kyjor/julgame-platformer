using JulGame.MainLoop 

mutable struct Water
    offset
    parent
    player
    
    function Water()
        this = new()

        this.parent = C_NULL
        this.player = C_NULL
        this.offset = C_NULL

        return this
    end
end

function Base.getproperty(this::Water, s::Symbol)
    if s == :initialize
        function()
            this.offset = JulGame.Math.Vector2f(this.parent.getTransform().position.x + MAIN.scene.camera.offset.x, 5.5)
            this.player = MAIN.scene.getEntityByName("Player")
        end
    elseif s == :update
        function(deltaTime)
            this.parent.getTransform().position = JulGame.Math.Vector2f(this.player.getTransform().position.x, 0) + this.offset
        end
    elseif s == :setParent 
        function(parent)
            this.parent = parent
        end
    elseif s == :onShutDown
        function ()
        end
    else
        try
            getfield(this, s)
        catch e
            println(e)
        end
    end
end