module Platformer
    using JulGame
    using JulGame.Math
    using JulGame.SceneBuilderModule
    
    function run()
        JulGame.PIXELS_PER_UNIT = 16
        scene = Scene("level_0.json")
        return scene.init("JulGame Example", false, Vector2(),Vector2(1280, 720), true, 1.0, true, 60)
    end

    julia_main() = run()
end
# comment when building
Platformer.run()