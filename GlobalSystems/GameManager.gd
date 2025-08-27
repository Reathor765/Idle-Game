extends Node

# GameManager is an autoloaded singleton responsible for managing the game state.
# It handles loading, saving, and providing access to the PlayerData resource.

#const SAVE_PATH = "user://player_data.tres"
const SAVE_PATH = "res://User/player_data.tres" # For testing in the editor; change to user:// for production

# Signal to notify UI elements or other systems that data has changed.
signal player_data_updated

var player_data: PlayerData


func _ready() -> void:
	# Set up a timer for periodic auto-saving.
	var auto_save_timer = Timer.new()
	auto_save_timer.wait_time = 30.0 # Auto-save every 30 seconds
	auto_save_timer.timeout.connect(save_game)
	add_child(auto_save_timer)
	auto_save_timer.start()

	load_game()


func _notification(what: int) -> void:
	# Save the game when the app is about to close or go into the background.
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_APPLICATION_PAUSED:
		save_game()


func load_game() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		player_data = ResourceLoader.load(SAVE_PATH) as PlayerData

	# If loading was successful, calculate offline progress.
	if player_data:
		print("Game data loaded from: ", SAVE_PATH)
		_calculate_offline_progress()
	else:
		# If no save file exists, or it was invalid, create a new game state.
		print("No save file found or file was invalid. Creating new game.")
		player_data = PlayerData.new()
		_initialize_new_game_state()

	player_data_updated.emit()


func save_game() -> void:
	if not player_data:
		return

	# Update the timestamp right before saving.
	@warning_ignore("narrowing_conversion")
	player_data.last_save_timestamp = Time.get_unix_time_from_system()

	var error = ResourceSaver.save(player_data, SAVE_PATH)
	if error == OK:
		print("Game data saved successfully.")
	else:
		print_rich("[color=red]Error saving game data: %s[/color]" % error)


func add_resource(resource_name: String, amount: float) -> void:
	if not player_data:
		return

	if not player_data.resources.has(resource_name):
		# If a resource doesn't exist in our dictionary, we can't add to it.
		# You might want to initialize it to 0 here if that fits your game logic.
		print_rich("[color=orange]Attempted to add to non-existent resource: %s[/color]" % resource_name)
		return

	player_data.resources[resource_name] += amount
	player_data_updated.emit()


func _initialize_new_game_state() -> void:
	# Set up the default state for a brand new player.
	player_data.resources = {"hydrogen": 100.0, "helium": 50.0, "lithium": 0.0, "beryllium": 0.0}
	player_data.systems = {
		"Sol": {
			"robotics": {
				"Miner": 1
			},
			"infrastructure": {
				"Fabricator": 1
			}
		}
	}
	player_data.global_upgrades = {}
	save_game() # Perform an initial save.


func _calculate_offline_progress() -> void:
	if player_data.last_save_timestamp == 0:
		return # No previous save time, so no offline progress to calculate.

	var time_now = Time.get_unix_time_from_system()
	var time_offline = time_now - player_data.last_save_timestamp
	# Cap offline time to a reasonable maximum (e.g., 2 hours for MVP)
	var effective_offline_time = min(time_offline, 7200)

	print("Player was offline for %s seconds. Granting %s seconds of progress." % [time_offline, effective_offline_time])

	# This is where you would calculate total income per second from all systems
	# and grant the resources. For now, we'll just add a placeholder amount.
	var metals_per_second = 1.0 # Placeholder
	var polymers_per_second = 0.5 # Placeholder

	player_data.resources["metals"] += metals_per_second * effective_offline_time
	player_data.resources["polymers"] += polymers_per_second * effective_offline_time
