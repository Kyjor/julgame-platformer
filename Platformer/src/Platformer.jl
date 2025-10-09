module Platformer 
    using JulGame

    println("Platformer.jl loading...")
    if get(ENV, "SKIP_PRECOMPILE", "false") == "false" && !JulGame.IS_EDITOR
        println("precompiling")
        include("additional_precompile.jl")
        println("precompiling done")
    end

    function get_folders_after_base_folder(path::String, base_folder::String)
        # Normalize the path to use forward slashes
        normalized_path = replace(path, '\\' => '/')
        
        # Split the path into components
        parts = split(normalized_path, '/')
        
        # Find the index of "images"
        base_folder_index = findfirst(==("base_folder"), parts)
        
        # Extract components after "images", or an empty array if not found
        result = base_folder_index === nothing ? "" : join(parts[base_folder_index+1:end], ",")
    
        # Append a comma if there are results
        return isempty(result) ? result : result * ","  
    end

    function get_all_files(folder::String, extensions, folderToPrefix)
        bytes_files = Dict{String, Vector{UInt8}}()

        for (root, _, files) in walkdir(folder)
            for file in files
                ext = lowercase(last(split(file, '.')))
                prefix = get_folders_after_base_folder(joinpath(root), folderToPrefix)
                if ext in extensions
                    file_path = joinpath(root, file)
                    bytes_files["$(prefix)$file"] = read(file_path)
                end
            end
        end
    
        return bytes_files
    end
    
    # Initialize an empty dictionary
    json_dict = Dict{String, Any}()
    # Iterate over all files in the directory
    scenes_dir = joinpath(@__DIR__, "..", "scenes")
    for file in readdir(scenes_dir)
        # Build the full path to the file
        full_path = joinpath(scenes_dir, file)
        if endswith(file, ".json")
            json_content = JulGame.SceneBuilderModule.JSON3.read(read(full_path, String))
            # Use the file name with the extension as the key
            json_dict[file] = json_content
        end
    end

    cached_images = get_all_files(joinpath(@__DIR__, "..", "assets", "images"), Set(["png", "jpg", "jpeg", "bmp", "gif", "tiff"]), "images")
    cached_fonts = get_all_files(joinpath(@__DIR__, "..", "assets", "fonts"), Set(["ttf", "otf", "woff", "woff2"]), "fonts")
    cached_sounds = get_all_files(joinpath(@__DIR__, "..", "assets", "sounds"), Set(["wav", "mp3", "ogg", "flac"]), "sounds")

    function run()
        JulGame.PIXELS_PER_UNIT = 16
        JulGame.ProjectModule = "Platformer"
        JulGame.SCENE_CACHE = json_dict
        JulGame.IMAGE_CACHE = cached_images
        JulGame.FONT_CACHE = cached_fonts
        JulGame.AUDIO_CACHE = cached_sounds

        scene = SceneBuilderModule.Scene(get(ENV, "SCENE", "level_0.json"))

        # Helper function to log errors
        function log_error(e)
            open(joinpath(pwd(), "error_log.txt"), "a") do file
                println(file, "ERROR:")
                println(file, e)
                Base.show_backtrace(file, catch_backtrace())
                
                println(file, "\n---\n")
            end
            Base.show_backtrace(stdout, catch_backtrace())
        end
    
        try
            SceneBuilderModule.load_and_prepare_scene(scene; windowName="Platformer", preloadAllScenes=false, scalingQuality="nearest")
        catch e
            @error first(string(e), min(length(string(e)), 500))
            log_error(first(string(e), min(length(string(e)), 500)))
            return Cint(-1)
        end
    
        @debug("Game ran successfully")
        return Cint(0)
    end

    julia_main() = run()
end
