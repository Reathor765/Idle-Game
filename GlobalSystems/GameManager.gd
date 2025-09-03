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
		var loaded_resource = ResourceLoader.load(SAVE_PATH)
		# By duplicating the resource, we ensure we have a unique instance in memory.
		# This guarantees that when we save, all sub-resources (like scout_findings)
		# are saved correctly within the main player_data file.
		if loaded_resource is PlayerData:
			player_data = loaded_resource.duplicate(true)
		# This guarantees that when we save, all sub-resources (like scout_findings)
		# are saved correctly within the main player_data file.
		if loaded_resource is PlayerData:
			player_data = loaded_resource.duplicate(true)
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
	player_data.resources = {"metals": 100.0, "polymers": 50.0, "organics": 0.0, "crystals": 0.0, "research_points": 0.0}
	player_data.systems = {
		"Sol": {
			"robotics": {
				"Miner": 1,
				"Scout": 1
			},
			"infrastructure": {
				"Fabricator": 1,
				"Research": 1
			},
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
		return  # No previous save time, so no offline progress to calculate.

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
			_grant_completed_unit(unit_name)
		state_changed = true

	# --- Complete Offline Scouting Missions ---
	if player_data.scout_findings and player_data.scout_findings.is_mission_active():
		if player_data.scout_findings.mission_completion_timestamp <= time_now:
			print("Completing offline scouting mission.")
			complete_scouting_mission(false)  # This will add the new asteroid to the discovered list
			state_changed = true

	# --- Grant Offline Resources (Research & Mining) ---
	if effective_offline_time > 0:
		# For simplicity, grant 1 research point per minute offline, capped at 180 RP
		var research_points_earned = min(effective_offline_time / 60.0, 180.0)
		if research_points_earned > 0:
			add_resource("research_points", research_points_earned, false)
			state_changed = true

		if player_data.scout_findings:
			# Note: This uses the miner count *after* offline builds completed. This is a small bonus for the player.
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

				if not mined_resources.is_empty():
					state_changed = true

	# --- Complete Offline Milestones (AFTER state has been updated) ---
	var milestones_to_complete: Array[String] = []
	for milestone_id in player_data.get_incomplete_milestones():
		if player_data.is_milestone_condition_met(milestone_id):
			milestones_to_complete.append(milestone_id)

	if not milestones_to_complete.is_empty():
		print("Completing offline milestones: ", milestones_to_complete)
		for milestone_id in milestones_to_complete:
			# Directly modify player_data to avoid emitting multiple signals inside the loop.
			player_data.complete_milestone(milestone_id)
		state_changed = true

	print("Player was offline for %s seconds. Granting %s seconds of progress." % [time_offline, effective_offline_time])

	# If any state changed during offline calculation, emit one signal to update the UI.
	if state_changed:
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
	_add_system_unit("Sol", "robotics", "Scout", 1, false)

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


func start_scouting_mission(mission_index: int, duration_seconds: int, reward_scout_count: int) -> bool:
	if not player_data or not player_data.scout_findings: return false
	if player_data.scout_findings.is_mission_active(): return false # Mission already in progress

	var scout_count = player_data.systems.get("Sol", {}).get("robotics", {}).get("Scout", 0)
	if scout_count == 0: return false # No scouts to send

	var findings = player_data.scout_findings
	findings.mission_completion_timestamp = Time.get_unix_time_from_system() + duration_seconds
	findings.active_mission_index = mission_index
	findings.active_mission_reward_scouts = reward_scout_count
	
	player_data_updated.emit()
	return true


func complete_scouting_mission(p_emit_signal: bool = true) -> void:
	if not player_data or not player_data.scout_findings: return
	var findings = player_data.scout_findings
	
	# Use the reward scout count that was stored when the mission started.
	var new_asteroid = findings.generate_new_asteroid(findings.active_mission_reward_scouts)
	findings.discovered_asteroids.append(new_asteroid)
	
	# If there was no active asteroid, promote the one we just found.
	if findings.is_active_asteroid_depleted():
		findings.promote_next_asteroid()
		
	findings.mission_completion_timestamp = 0
	findings.active_mission_index = -1
	findings.active_mission_reward_scouts = 0
	if p_emit_signal:
		player_data_updated.emit()


func purchase_global_upgrade(upgrade_id: String, cost: Dictionary) -> bool:
	if not player_data: return false
	
	# Double-check affordability (UI should prevent this, but good for safety)
	for resource in cost:
		if player_data.resources.get(resource, 0.0) < cost[resource]:
			printerr("Attempted to purchase upgrade '%s' without enough resources." % upgrade_id)
			return false
	
	# Deduct cost
	for resource in cost:
		player_data.resources[resource] -= cost[resource]
	
	# Grant upgrade
	player_data.global_upgrades[upgrade_id] = true
	
	player_data_updated.emit()
	return true


func complete_milestone(milestone_id: String) -> void:
	if not player_data: return
	
	# Call the player_data function to mark as complete.
	# If it was newly completed, emit the signal to update UI.
	if player_data.complete_milestone(milestone_id):
		print("Milestone completed: ", milestone_id)
		player_data_updated.emit()


func cycle_active_asteroid() -> void:
	if not player_data or not player_data.scout_findings: return
	
	if player_data.scout_findings.promote_next_asteroid():
		print("Promoted next asteroid from queue.")
	else:
		print("Asteroid queue is empty. Active asteroid cleared.")
	
	player_data_updated.emit()

# --- Upgrade Effect Calculation ---

# Returns a multiplier for tick speed. A value of 0.95 means 5% faster.
# This should be called by the TickManager to adjust its timing.
# Example usage in TickManager (if using a Timer node):
#   var tick_time_multiplier = GameManager.get_tick_time_multiplier()
#   tick_timer.wait_time = BASE_TICK_TIME * tick_time_multiplier
func get_tick_time_multiplier() -> float:
	if not player_data: return 1.0
	
	var multiplier := 1.0
	# Each upgrade makes ticks 10% faster (multiplies duration by 0.90)
	for i in range(1, 9):
		if player_data.has_upgrade("tick_time_%d" % i):
			multiplier *= 0.9
	return multiplier


# Returns a multiplier for resources found in new asteroids.
# This should be used in ScoutFindings.gd when generating a new asteroid's resources.
# Example usage in ScoutFindings.generate_new_asteroid():
#   var resource_multiplier = GameManager.get_asteroid_resource_multiplier()
#   new_asteroid["metals"] = base_metals * resource_multiplier
func get_asteroid_resource_multiplier() -> float:
	if not player_data: return 1.0
	
	var multiplier := 1.0
	# Each upgrade doubles the resources in newly generated asteroids.
	for i in range(1, 9):
		if player_data.has_upgrade("asteroid_%d" % i):
			multiplier *= 2.0
	return multiplier


# Returns a cost multiplier for building a specific unit.
# A value of 0.9 means 10% cheaper.
# This should be called by the UI when displaying and calculating build costs.
# Example usage in a build UI script:
#   var cost_multiplier = GameManager.get_unit_cost_multiplier("Fabricator")
#   var final_cost = BASE_FABRICATOR_COST * cost_multiplier
func get_unit_cost_multiplier(unit_name: String) -> float:
	if not player_data: return 1.0
	
	var multiplier := 1.0
	var upgrade_prefix := ""
	
	match unit_name:
		"Fabricator": upgrade_prefix = "fabricator"
		"Scout": upgrade_prefix = "scout"
		"Research": upgrade_prefix = "research"
		_: return 1.0 # No cost reduction for this unit type
	
	# Each upgrade tier provides a 10% cost reduction, stacking multiplicatively.
	for i in range(1, 9):
		if player_data.has_upgrade("%s_%d" % [upgrade_prefix, i]):
			multiplier *= 0.9
	return multiplier

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
	
	# Calculate research points generated this tick
	var research_bot_count = player_data.systems.get("Sol", {}).get("infrastructure", {}).get("Research", 0)
	if research_bot_count > 0:
		add_resource("research_points", delta * research_bot_count * 0.1, false) # 0.1 RP per bot per second

	# Calculate miner efficiency from upgrades
	var miner_efficiency_multiplier := 1.0
	# Each "Efficient Miners" upgrade adds a 50% bonus to miner output.
	# These bonuses are additive with each other.
	if player_data.has_upgrade("miner_1"): miner_efficiency_multiplier += 0.5
	if player_data.has_upgrade("miner_2"): miner_efficiency_multiplier += 0.5
	if player_data.has_upgrade("miner_3"): miner_efficiency_multiplier += 0.5
	if player_data.has_upgrade("miner_4"): miner_efficiency_multiplier += 0.5
	if player_data.has_upgrade("miner_5"): miner_efficiency_multiplier += 0.5
	if player_data.has_upgrade("miner_6"): miner_efficiency_multiplier += 0.5
	if player_data.has_upgrade("miner_7"): miner_efficiency_multiplier += 0.5
	if player_data.has_upgrade("miner_8"): miner_efficiency_multiplier += 0.5

	# Calculate potential resources mined this tick, including the efficiency bonus
	var base_yield :float = delta * miner_count * miner_efficiency_multiplier
	var potential_yield := {
		"metals": base_yield * 1.0,
		"polymers": base_yield * 0.2,
		"organics": base_yield * 0.1,
		"crystals": base_yield * 0.05
	}
	var mined_resources = player_data.scout_findings.mine_resources(potential_yield)
	var state_changed = not mined_resources.is_empty()

	for resource_name in mined_resources:
		add_resource(resource_name, mined_resources[resource_name], false)

	# Check for depletion after mining and promote the next asteroid if available.
	if state_changed and player_data.scout_findings.is_active_asteroid_depleted():
		if player_data.scout_findings.promote_next_asteroid():
			# This is a good place to trigger the "deplete asteroid" milestone.
			complete_milestone("deplete_asteroid_1")
			print("Active asteroid depleted. Promoting next from queue.")

	if state_changed:
		player_data_updated.emit()
