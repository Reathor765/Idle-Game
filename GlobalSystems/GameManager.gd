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
	TickManager.tick.connect(_on_tick)
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


func add_resource(resource_name: String, amount: float, p_emit_signal: bool = true) -> void:
	if not player_data:
		return

	if not player_data.resources.has(resource_name):
		# If a resource doesn't exist in our dictionary, initialize it to 0.
		player_data.resources[resource_name] = 0.0

	player_data.resources[resource_name] += amount
	if p_emit_signal:
		player_data_updated.emit()


func _initialize_new_game_state() -> void:
	# Set up the default state for a brand new player.
	player_data.resources = {"metals": 100.0, "polymers": 50.0, "organics": 0.0, "crystals": 0.0}
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
	player_data.build_queue = {}
	player_data.scout_findings = ScoutFindings.new()
	# Create the first asteroid for the player to mine.
	var starting_asteroid := {
		"metals": 50000,
		"polymers": 10000
	}
	player_data.scout_findings.active_asteroid = starting_asteroid
	player_data.global_upgrades = {}
	save_game() # Perform an initial save.


func _calculate_offline_progress() -> void:
	if player_data.last_save_timestamp == 0:
		return # No previous save time, so no offline progress to calculate.

	var time_now = Time.get_unix_time_from_system()
	var time_offline = time_now - player_data.last_save_timestamp
	# Cap offline time to a reasonable maximum (e.g., 2 hours for MVP)
	var effective_offline_time = min(time_offline, 7200)

	var state_changed := false

	# --- Complete Offline Builds ---
	var completed_builds: Array[String] = []
	for unit_name in player_data.build_queue:
		if player_data.build_queue[unit_name].completion_timestamp <= time_now:
			completed_builds.append(unit_name)

	if not completed_builds.is_empty():
		print("Completing offline builds: ", completed_builds)
		for unit_name in completed_builds:
			# Grant the unit and remove it from the queue without emitting signals yet.
			_grant_completed_unit(unit_name)
		state_changed = true
	
	# --- Complete Offline Scouting Missions ---
	if player_data.scout_findings and player_data.scout_findings.is_mission_active():
		if player_data.scout_findings.mission_completion_timestamp <= time_now:
			print("Completing offline scouting mission.")
			complete_scouting_mission(false) # This will add the new asteroid to the discovered list
			state_changed = true

	# If any builds were completed, we need to notify listeners of the new state.
	if state_changed:
		player_data_updated.emit()

	print("Player was offline for %s seconds. Granting %s seconds of progress." % [time_offline, effective_offline_time])
	
	# --- Grant Offline Resources from Mining ---
	if effective_offline_time > 0 and player_data.scout_findings:
		var miner_count = player_data.systems.get("Sol", {}).get("robotics", {}).get("Miner", 0)
		if miner_count > 0:
			var potential_yield := {
				"metals": effective_offline_time * miner_count * 1.0,
				"polymers": effective_offline_time * miner_count * 0.2,
				"organics": effective_offline_time * miner_count * 0.1,
				"crystals": effective_offline_time * miner_count * 0.05
			}
			var mined_resources = player_data.scout_findings.mine_resources(potential_yield)
			for resource_name in mined_resources:
				add_resource(resource_name, mined_resources[resource_name], false)
			
			# If we mined anything, the UI needs an update.
			if not mined_resources.is_empty():
				player_data_updated.emit()


func _add_system_unit(system_name: String, category: String, unit_name: String, amount: int = 1, p_emit_signal: bool = true) -> void:
	if not player_data:
		return
	
	# This helper function ensures the nested dictionary path exists.
	var current_level = player_data.systems
	for key in [system_name, category]:
		if not current_level.has(key):
			current_level[key] = {}
		current_level = current_level[key]
	
	# Increment the unit count, initializing it if it doesn't exist.
	current_level[unit_name] = current_level.get(unit_name, 0) + amount
	if p_emit_signal:
		player_data_updated.emit()


func add_miner() -> void:
	_add_system_unit("Sol", "robotics", "Miner", 1, false)

func add_fabricator() -> void:
	_add_system_unit("Sol", "infrastructure", "Fabricator", 1, false)

func add_scout() -> void:
	_add_system_unit("Sol", "infrastructure", "Scout", 1, false)

func add_research_bot() -> void:
	_add_system_unit("Sol", "infrastructure", "Research", 1, false)



func start_build(unit_name: String, build_time: float) -> void:
	if not player_data:
		return
	
	var completion_timestamp = Time.get_unix_time_from_system() + build_time
	player_data.build_queue[unit_name] = {
		"completion_timestamp": completion_timestamp,
		"total_build_time": build_time
	}
	player_data_updated.emit()


func complete_build(unit_name: String, p_emit_signal: bool = true) -> void:
	if not player_data or not player_data.build_queue.has(unit_name):
		return

	_grant_completed_unit(unit_name)
	if p_emit_signal:
		player_data_updated.emit()


func start_scouting_mission(duration_seconds: float) -> bool:
	if not player_data or not player_data.scout_findings: return false
	if player_data.scout_findings.is_mission_active(): return false # Mission already in progress

	var scout_count = player_data.systems.get("Sol", {}).get("infrastructure", {}).get("Scout", 0)
	if scout_count == 0: return false # No scouts to send

	player_data.scout_findings.mission_completion_timestamp = Time.get_unix_time_from_system() + duration_seconds
	player_data_updated.emit()
	return true


func complete_scouting_mission(p_emit_signal: bool = true) -> void:
	if not player_data or not player_data.scout_findings: return
	var scout_count = player_data.systems.get("Sol", {}).get("infrastructure", {}).get("Scout", 0)
	var new_asteroid = player_data.scout_findings.generate_new_asteroid(scout_count)
	player_data.scout_findings.discovered_asteroids.append(new_asteroid)
	player_data.scout_findings.mission_completion_timestamp = 0
	if p_emit_signal:
		player_data_updated.emit()


## Grants a unit and removes it from the build queue. Does not emit a signal.
func _grant_completed_unit(unit_name: String) -> void:
	if not player_data or not player_data.build_queue.has(unit_name):
		return

	# Grant the unit
	match unit_name:
		"Miner":
			add_miner()
		"Fabricator":
			add_fabricator()
		"Scout":
			add_scout()
		"Research":
			add_research_bot()
		_:
			printerr("Attempted to complete unknown build unit: ", unit_name)
			return

	# Remove from queue
	player_data.build_queue.erase(unit_name)

func _on_tick(delta: float) -> void:
	if not player_data or not player_data.scout_findings: return

	# Calculate potential resources mined this tick
	var miner_count = player_data.systems.get("Sol", {}).get("robotics", {}).get("Miner", 0)
	if miner_count == 0: return

	var potential_yield := {
		"metals": delta * miner_count * 1.0,
		"polymers": delta * miner_count * 0.2,
		"organics": delta * miner_count * 0.1,
		"crystals": delta * miner_count * 0.05
	}

	var mined_resources = player_data.scout_findings.mine_resources(potential_yield)
	for resource_name in mined_resources:
		add_resource(resource_name, mined_resources[resource_name], false)
	if not mined_resources.is_empty():
		player_data_updated.emit()
