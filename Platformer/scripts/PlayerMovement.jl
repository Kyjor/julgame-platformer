using JulGame.Macros
using JulGame.MainLoop
using JulGame.SoundSourceModule

mutable struct PlayerMovement
    elapsedTime
    canMove
    gameManager
    input
    isFacingRight
    parent
    soundBank

    function PlayerMovement(followers)
        this = new()

        this.canMove = false
        this.elapsedTime = 0.0
        this.isFacingRight = true
        this.parent = C_NULL
        #this.gameManager = MAIN.scene.entities[1].scripts[1]
        this.shadow = followers[1]
        this.soundBank = Dict(
        )

        return this
    end
end

function Base.getproperty(this::PlayerMovement, s::Symbol)
    if s == :initialize
        function()

        end
    elseif s == :update
        function(deltaTime)
           
            # Inputs match SDL2 scancodes after "SDL_SCANCODE_"
            # https://wiki.libsdl.org/SDL2/SDL_Scancode
            # Spaces full scancode is "SDL_SCANCODE_SPACE" so we use "SPACE". Every other key is the same.
            directions = Dict(
                "A" => (-1, 0),  # Move left
                "D" => (1, 0),   # Move right
                "W" => (0, -1),  # Move up
                "S" => (0, 1)    # Move down
            )

            # Loop through the directions
            for (direction, (dx, dy)) in directions
                if input.getButtonHeldDown(direction) && this.canMove
                    if input.getButtonPressed(direction)
                    end
                    
                    if dx != 0
                        if (dx < 0 && this.isFacingRight) || (dx > 0 && !this.isFacingRight)
                            this.isFacingRight = !this.isFacingRight
                            this.parent.getSprite().flip()
                        end
                    end
                end
            end

            this.bob()
            this.elapsedTime += deltaTime
        end
    elseif s == :bob
        function()
            # Define bobbing parameters
            bobHeight = -0.20  # The maximum height the item will bob
            bobSpeed = 2.0   # The speed at which the item bobs up and down
            minBobHeight = -0.10

            # Calculate a sine wave for bobbing motion
            bobOffset = minBobHeight + bobHeight * (1.0 - cos(bobSpeed * this.elapsedTime)) / 2.0
        
            # Update the item's Y-coordinate
            this.parent.getSprite().offset = JulGame.Math.Vector2f(this.parent.getSprite().offset.x, this.startingY + bobOffset)
        end
    elseif s == :setParent
        function(parent)
            this.parent = parent
        end
    else
        try
            getfield(this, s)
        catch e
            println(e)
        end
    end
end