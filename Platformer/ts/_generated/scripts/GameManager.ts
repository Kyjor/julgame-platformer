import { registerScript } from "julgame/src/engine/runtime/scriptRegistry";
import { registerScriptSounds } from "julgame/src/engine/runtime/scriptRegistry";


    // using JulGame

    export class GameManager {
        currentLevel
        currentMusic
        soundBank
        starCount
        parent
        offsetApplied: boolean  // Track if we've set the batching offset

        constructor() {
            

            this.currentLevel = 1
            this.parent = null
            this.soundBank = [
                "water-ambience.mp3",
                "lava.wav",
                "strong-wind.wav",
            ]
            this.starCount = 3
            this.offsetApplied = false

        }
    }
    
    
    function JulGame_initialize_GameManager(self: GameManager) {
        (globalThis as any).MAIN.scene.camera.backgroundColor = [30, 111, 80, 255]

        if (self.currentLevel > 1) {
            (globalThis as any).JulGame.Component.unload_sound(self.currentMusic)
        };

        //self.currentMusic = (globalThis as any).JulGame.create_sound_source(self.parent, (globalThis as any).JulGame.SoundSourceModule.SoundSource(Number(-1), true, self.soundBank[self.currentLevel], 25))
        //(globalThis as any).JulGame.Component.toggle_sound(self.currentMusic)
        
        (globalThis as any).MAIN.scene.uiElements[1].text = String(self.starCount)
    }
    
    function JulGame_update_GameManager(self: GameManager, deltaTime) {
        // WORKAROUND: Static batching requires 32,32 offset (half SCALE_UNITS)
        // TODO: Fix root cause in StaticSpriteBatcher.jl alignment calculation
        // See: cursor/static-batching-alignment-todo.md
        if (!self.offsetApplied) {
            (globalThis as any).JulGame.set_batched_layer_offset(0, 32.0, 32.0)
            self.offsetApplied = true
        }
    }
registerScript("GameManager", {
    create: () => new GameManager(),
    initialize: JulGame_initialize_GameManager,
    update: JulGame_update_GameManager,
});
registerScriptSounds(["lava.wav", "strong-wind.wav", "water-ambience.mp3"]);
