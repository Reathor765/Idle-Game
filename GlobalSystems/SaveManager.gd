extends Node

# This global script handles saving and loading game data.
# It must be configured as an AutoLoad singleton in Project Settings.

#const SAVE_PATH = "user://scout_findings.tres" ## uncomment this line for production
const SAVE_PATH = "res://User/ScoutFindings.tres" # This is the current file for testing

# Saves the provided ScoutFindings resource to the user directory.
func save_game(scout_data: ScoutFindings):
	if scout_data == null:
		printerr("SaveManager: Cannot save null scout_data.")
		return
		
	var error = ResourceSaver.save(scout_data, SAVE_PATH)
	if error == OK:
		print("Game saved successfully at: ", SAVE_PATH)
	else:
		printerr("Failed to save game. Error code: ", error)


# Loads the ScoutFindings resource from the user directory.
# If no save file exists, it loads the default resource from the provided path.
func load_game(default_data_path: String) -> ScoutFindings:
	if ResourceLoader.exists(SAVE_PATH):
		print("Save file found. Loading from: ", SAVE_PATH)
		# Load the saved resource.
		return ResourceLoader.load(SAVE_PATH)
	else:
		print("No save file found. Loading default data from: ", default_data_path)
		# Load the default resource and duplicate it to prevent overwriting the original file.
		var default_data = ResourceLoader.load(default_data_path)
		return default_data.duplicate()
