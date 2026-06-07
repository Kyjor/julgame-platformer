import { registerScript } from "julgame/src/engine/runtime/scriptRegistry";


    // using JulGame

    export class Spider {
        animator
        isMovingRight: boolean
        parent: Entity
        sound: SoundSource
        speed: number
        startingX: number
        endingX: number

        constructor() {
            

            this.endingX = 0
            this.isMovingRight = false
            this.startingX = 0
            this.speed = 0.0

        }
    }

    function JulGame_initialize_Spider(self: Spider) {
        self.animator = self.parent.animator
        self.parent.transform.position = {x: self.startingX, y: self.parent.transform.position.y}
    }
    function JulGame_update_Spider(self: Spider, deltaTime) {
        if (self.parent.transform.position.x <= self.startingX && !self.isMovingRight) {
            (globalThis as any).JulGame.Component.flip(self.parent.sprite)
            self.isMovingRight = true
        } else if (self.parent.transform.position.x >= self.endingX && self.isMovingRight) {
            (globalThis as any).JulGame.Component.flip(self.parent.sprite)
            self.isMovingRight = false
        }

        if (self.isMovingRight) {
            self.parent.transform.position = {x: self.parent.transform.position.x + self.speed*deltaTime, y: self.parent.transform.position.y}
        } else {
            self.parent.transform.position = {x: self.parent.transform.position.x - self.speed*deltaTime, y: self.parent.transform.position.y}
        }
    }
registerScript("Spider", {
    create: () => new Spider(),
    initialize: JulGame_initialize_Spider,
    update: JulGame_update_Spider,
});
