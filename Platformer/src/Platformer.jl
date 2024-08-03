module Platformer
    using JulGame
    using JulGame.Math
    using JulGame.SceneBuilderModule
    
    function run()
        JulGame.MAIN = JulGame.Main(Float64(1.0))
        JulGame.PIXELS_PER_UNIT = 16
        scene = SceneBuilderModule.Scene("level_0.json")
        return SceneBuilderModule.load_and_prepare_scene(scene, "JulGame Example", false, Vector2(),Vector2(1280, 720), true, 1.0, true, 60)
    end

    julia_main() = run()
end
# comment when building
Platformer.run()