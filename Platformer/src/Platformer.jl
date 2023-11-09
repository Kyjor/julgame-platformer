module Platformer
    using JulGame
    using JulGame.Math
    using JulGame.SceneBuilderModule

    function run()
        SDL2.init()

        dir = joinpath(pwd(), "..") 
        scene = Scene(dir, "scene.json")
        main = scene.init(false, Vector2(1280, 720), 1.25, 60.0, [])
        return main
    end

    julia_main() = run()
end
# comment when building
Platformer.run()