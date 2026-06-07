module TitleModule
    using JulGame

    mutable struct Title <: Script
        fade
        parent
        textBox

        function Title()
            this = new()

            this.fade = true
            this.parent = C_NULL
            this.textBox = C_NULL

            return this
        end
    end

    function JulGame.initialize(this::Title)
        #JulGame.MainLoopModule.enable_profiling()
        this.textBox = MAIN.scene.uiElements[1]
    end

    function JulGame.update(this::Title, deltaTime)
        try
            if this.fade 
                this.textBox.color = (this.textBox.color[1], this.textBox.color[2], this.textBox.color[3], this.textBox.color[4] - 1)
                this.textBox.text = this.textBox.text
                if this.textBox.color[4] <= 25
                    this.fade = false
                end
            else
                this.textBox.color = (this.textBox.color[1], this.textBox.color[2], this.textBox.color[3], this.textBox.color[4] + 1)
                this.textBox.text = this.textBox.text
                if this.textBox.color[4] >= 250
                    this.fade = true
                end
            end

            if JulGame.InputModule.get_button_pressed(MAIN.input, "RETURN")
                JulGame.change_scene("level_1.json")
                # sound = JulGame.create_sound_source(this.parent, JulGame.SoundSourceModule.SoundSource(Int32(-1), false, "confirm-ui.wav", Int32(50)))
                # JulGame.Component.toggle_sound(sound)
            end
        catch e
            @error string(e)
            Base.show_backtrace(stdout, catch_backtrace())
            rethrow(e)
        end
    end
end # module