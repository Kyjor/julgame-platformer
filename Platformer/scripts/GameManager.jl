module GameManagerModule
    using JulGame

    mutable struct GameManager <: Script
        currentLevel
        currentMusic
        soundBank
        starCount
        parent
        offsetApplied::Bool  # Track if we've set the batching offset

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
            this.offsetApplied = false
            
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
    
    function JulGame.update(this::GameManager, deltaTime)
        # WORKAROUND: Static batching requires 32,32 offset (half SCALE_UNITS)
        # TODO: Fix root cause in StaticSpriteBatcher.jl alignment calculation
        # See: cursor/static-batching-alignment-todo.md
        if !this.offsetApplied
            JulGame.set_batched_layer_offset(0, 32.0, 32.0)
            this.offsetApplied = true
        end
    end
end # module