import { registerScript } from "julgame/src/engine/runtime/scriptRegistry";


    // using JulGame

    export class Background {
        parent

        constructor() {
            

            this.parent = null

        }
    }

    function JulGame_update_Background(self: Background, deltaTime) {
        self.parent.transform.position = {x: (globalThis as any).MAIN.scene.camera.position.x + 9.5, y: 0}
    }
registerScript("Background", {
    create: () => new Background(),
    update: JulGame_update_Background,
});
