module GameManagerModule
    using JulGame

    mutable struct GameManager <: Script
        currentLevel
        currentMusic
        soundBank
        starCount
        parent

        function GameManager()
            this = new()

            this.currentLevel = 1
            this.parent = C_NULL
            this.soundBank = [
                "water-ambience.mp3",
                "lava.wav",
                "strong-wind.wav",
            ]
            this.starCount = 3

            return this
        end
    end


    function JulGame.initialize(this::GameManager)
        MAIN.scene.camera.backgroundColor = (30, 111, 80, 255)

        if this.currentLevel > 1
            JulGame.Component.unload_sound(this.currentMusic)
        end

        #this.currentMusic = JulGame.create_sound_source(this.parent, JulGame.SoundSourceModule.SoundSource(Int32(-1), true, this.soundBank[this.currentLevel], Int32(25)))
        #JulGame.Component.toggle_sound(this.currentMusic)
        
        MAIN.scene.uiElements[2].text = string(this.starCount)
    end
end # module