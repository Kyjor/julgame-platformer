import { registerScript } from "julgame/src/engine/runtime/scriptRegistry";
import { registerScriptSounds } from "julgame/src/engine/runtime/scriptRegistry";


    // using JulGame

    export class Title {
        fade
        parent
        textBox

        constructor() {
            

            this.fade = true
            this.parent = null
            this.textBox = null

        }
    }

    function JulGame_initialize_Title(self: Title) {
        //(globalThis as any).JulGame.MainLoopModule.enable_profiling()
        self.textBox = (globalThis as any).MAIN.scene.uiElements[0]
    }

    function JulGame_update_Title(self: Title, deltaTime) {
        try {
            if (self.fade) {
                self.textBox.color = [self.textBox.color[0], self.textBox.color[1], self.textBox.color[2], self.textBox.color[3] - 1]
                self.textBox.text = self.textBox.text
                if (self.textBox.color[3] <= 25) {
                    self.fade = false
                }
            } else {
                self.textBox.color = [self.textBox.color[0], self.textBox.color[1], self.textBox.color[2], self.textBox.color[3] + 1]
                self.textBox.text = self.textBox.text
                if (self.textBox.color[3] >= 250) {
                    self.fade = true
                }
            }

            if ((globalThis as any).JulGame.InputModule.get_button_pressed((globalThis as any).MAIN.input, "RETURN")) {
                (globalThis as any).JulGame.change_scene("level_1.json")
                // sound = (globalThis as any).JulGame.create_sound_source(self.parent, (globalThis as any).JulGame.SoundSourceModule.SoundSource(Number(-1), false, "confirm-ui.wav", 50))
                // (globalThis as any).JulGame.Component.toggle_sound(sound)
            }
        } catch (e) {
            console.error(String(e))


        }
    }
registerScript("Title", {
    create: () => new Title(),
    initialize: JulGame_initialize_Title,
    update: JulGame_update_Title,
});
registerScriptSounds(["confirm-ui.wav"]);
