import { registerScript } from "julgame/src/engine/runtime/scriptRegistry";
import { vecAdd, vecSub, vecMul, vecDiv, vecNeg } from "julgame/src/engine/core/vectorOps";


    // using JulGame

    export class Water {
        main
        offset
        parent
        
        constructor() {
            

            this.parent = null
            this.offset = {x: 0, y: 0}

        }
    }

    function JulGame_initialize_Water(self: Water) {
        self.offset = {x: self.parent.transform.position.x + 9, y: 7.5}
    }

    function JulGame_update_Water(self: Water, deltaTime) {
        self.parent.transform.position = vecAdd({x: (globalThis as any).MAIN.scene.camera.position.x, y: 0}, self.offset)
    }

    function JulGame_on_shutdown_Water(self: Water) {
    }
registerScript("Water", {
    create: () => new Water(),
    initialize: JulGame_initialize_Water,
    update: JulGame_update_Water,
    onShutdown: JulGame_on_shutdown_Water,
});
