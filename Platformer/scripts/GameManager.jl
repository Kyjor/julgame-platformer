using JulGame.MainLoop 

mutable struct GameManager
    parent

    function GameManager()
        this = new()

        this.parent = C_NULL

        return this
    end
end

function Base.getproperty(this::GameManager, s::Symbol)
    if s == :initialize
        function()
            MAIN.scene.camera.offset = JulGame.Math.Vector2f(0, -2.75)
            MAIN.cameraBackgroundColor = [30, 111, 80]
            this.parent.addComponent(ShapeModule.Shape(Math.Vector2(10,5), Math.Vector3(0), true; isWorldEntity=false, position=Math.Vector2f(1.05,0.7)))
            MAIN.scene.getEntityByName("CoinUI").getSprite().isWorldEntity = false
            MAIN.scene.getEntityByName("CoinUI").getSprite().position = JulGame.Math.Vector2f(-.1, 1)
            MAIN.scene.getEntityByName("LivesUI").getSprite().isWorldEntity = false
            MAIN.scene.getEntityByName("LivesUI").getSprite().position = JulGame.Math.Vector2f(-.1, .25)
        end
    elseif s == :update
        function(deltaTime)
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