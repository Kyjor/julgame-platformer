import { registerScript } from "julgame/src/engine/runtime/scriptRegistry";


    // using JulGame

    export class Fish {
        animator
        endingY: number
        isFire: boolean
        isMovingUp: boolean
        parent: Entity
        sound: SoundSource
        speed: number
        startingY: number

        constructor() {
            

            this.endingY = 0
            this.isFire = false
            this.isMovingUp = false
            this.speed = 0.0
            this.startingY = 0

        }
    }

    function JulGame_initialize_Fish(self: Fish) {
        self.animator = self.parent.animator
        self.parent.sprite.rotation = 90.0
        self.parent.transform.position = {x: self.parent.transform.position.x, y: self.startingY}
    }

    function JulGame_update_Fish(self: Fish, deltaTime) {
        if (self.parent.transform.position.y >= self.startingY && !self.isMovingUp) {
            self.parent.sprite.rotation = self.isFire ? 0 : 90.0
            self.isMovingUp = true
        } else if (self.parent.transform.position.y <= self.endingY && self.isMovingUp) {
            self.parent.sprite.rotation = self.isFire ? 180.0 : 270.0
            self.isMovingUp = false
        }

        if (self.isMovingUp) {
            self.parent.transform.position = {x: self.parent.transform.position.x, y: self.parent.transform.position.y - self.speed*deltaTime}
        } else {
            self.parent.transform.position = {x: self.parent.transform.position.x, y: self.parent.transform.position.y + self.speed*deltaTime}
        }
    }
registerScript("Fish", {
    create: () => new Fish(),
    initialize: JulGame_initialize_Fish,
    update: JulGame_update_Fish,
});
