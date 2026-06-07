import { registerScript } from "julgame/src/engine/runtime/scriptRegistry";


    // using JulGame

    export class Saw {
        animator: Animator
        endingY: number
        isMovingUp: boolean
        rotation: number
        parent: Entity
        sound: SoundSource
        speed: Number
        startingY: number

        constructor() {
            

            this.endingY = 3.0
            this.isMovingUp = false
            this.rotation = 0.0
            this.speed = 5.0
            this.startingY = 0.0

        }
    }

    function JulGame_update_Saw(self: Saw, deltaTime) {
        self.rotation += 5.0
        self.parent.sprite.rotation =  self.rotation % 360.0

        if (self.parent.transform.position.y >= self.startingY && !self.isMovingUp) {
            self.isMovingUp = true
        } else if (self.parent.transform.position.y <= self.endingY && self.isMovingUp) {
            self.isMovingUp = false
        }

        if (self.isMovingUp) {
            self.parent.transform.position = {x: self.parent.transform.position.x, y: self.parent.transform.position.y - self.speed*deltaTime}
        } else {
            self.parent.transform.position = {x: self.parent.transform.position.x, y: self.parent.transform.position.y + self.speed*deltaTime}
        }
    }
registerScript("Saw", {
    create: () => new Saw(),
    update: JulGame_update_Saw,
});
