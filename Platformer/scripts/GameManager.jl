using JulGame.MainLoop 

mutable struct GameManager
    currentLevel::Int32
    parent

    function GameManager()
        this = new()

        this.currentLevel = 1
        this.parent = C_NULL

        return this
    end
end

function Base.getproperty(this::GameManager, s::Symbol)
    if s == :initialize
        function()
            MAIN.scene.camera.offset = JulGame.Math.Vector2f(0, -2.75)
            MAIN.cameraBackgroundColor = [30, 111, 80]
            MAIN.optimizeSpriteRendering = true

            this.parent.addComponent(ShapeModule.Shape(Math.Vector2(10,5), Math.Vector3(0), true; isWorldEntity=false, position=Math.Vector2f(1.05,0.7)))
            coinUI = MAIN.scene.getEntityByName("CoinUI")
            livesUI = MAIN.scene.getEntityByName("LivesUI")

            coinUI.persistentBetweenScenes = true
            coinUI.getSprite().isWorldEntity = false
            coinUI.getSprite().position = JulGame.Math.Vector2f(-.1, 1)

            livesUI.persistentBetweenScenes = true
            livesUI.getSprite().isWorldEntity = false
            livesUI.getSprite().position = JulGame.Math.Vector2f(-.1, .25)
            
            this.parent.persistentBetweenScenes = true
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