extends Control


# This script manages the UI for starting scout missions and displaying their status.
# It works with a ScoutFindings resource to manage the state of missions and rewards.

# --- Node References ---
@onready var mission_1_label: RichTextLabel = $Panel/MissionSlot1/Mission1Label
@onready var mission_2_label: RichTextLabel = $Panel/MissionSlot2/Mission2Label
@onready var mission_3_label: RichTextLabel = $Panel/MissionSlot3/Mission3Label
@onready var button_1: Button = $Panel/MissionSlot1/Button
@onready var button_2: Button = $Panel/MissionSlot2/Button2
@onready var button_3: Button = $Panel/MissionSlot3/Button3
@onready var name_1: RichTextLabel = $Panel/CurrentAsteroid/Resource1/Name1
@onready var value_1: RichTextLabel = $Panel/CurrentAsteroid/Resource1/Value1
@onready var name_2: RichTextLabel = $Panel/CurrentAsteroid/Resource2/Name2
@onready var value_2: RichTextLabel = $Panel/CurrentAsteroid/Resource2/Value2
@onready var name_3: RichTextLabel = $Panel/CurrentAsteroid/Resource3/Name3
@onready var value_3: RichTextLabel = $Panel/CurrentAsteroid/Resource3/Value3
@onready var name_4: RichTextLabel = $Panel/CurrentAsteroid/Resource4/Name4
@onready var value_4: RichTextLabel = $Panel/CurrentAsteroid/Resource4/Value4
@onready var release_asteroid: Button = $Panel/CurrentAsteroid/ReleaseAsteroid
@onready var show_upgrade_panel: Button = $Panel/ShowUpgradePanel

# --- Mission Configuration ---
# You can configure the three available missions from the Godot Inspector.
@export_group("Mission 1 - Quick & Low Reward")
@export var mis_1_name: String = "Quick Scan"
@export var mis_1_duration: int = 30 # seconds
@export var mis_1_scout_count: int = 1 # Affects reward quality

@export_group("Mission 2 - Medium")
@export var mis_2_name: String = "Detailed Survey"
@export var mis_2_duration: int = 180 # seconds
@export var mis_2_scout_count: int = 3 # Affects reward quality

@export_group("Mission 3 - Long & High Reward")
@export var mis_3_name: String = "Deep Probe"
@export var mis_3_duration: int = 600 # seconds
@export var mis_3_scout_count: int = 5 # Affects reward quality


# --- Internal State ---
# A helper property to get the scout data from the central GameManager.
var scout_data: ScoutFindings:
	get: return GameManager.player_data.scout_findings if GameManager.player_data else null

# We'll store mission data in a more convenient structure for code access.
var missions: Array[Dictionary] = []
var mission_ui_nodes: Array[Dictionary] = []
var asteroid_resource_nodes: Array[Dictionary] = []


func _ready() -> void:
	# This UI panel gets all its state from the GameManager.
	# We connect to the player_data_updated signal to know when to refresh.
	GameManager.player_data_updated.connect(_on_player_data_updated)

	# Group UI nodes and config data for easier access by index.
	missions = [
		{"name": mis_1_name, "duration": mis_1_duration, "scouts": mis_1_scout_count},
		{"name": mis_2_name, "duration": mis_2_duration, "scouts": mis_2_scout_count},
		{"name": mis_3_name, "duration": mis_3_duration, "scouts": mis_3_scout_count}
	]
	mission_ui_nodes = [
		{"label": mission_1_label, "button": button_1},
		{"label": mission_2_label, "button": button_2},
		{"label": mission_3_label, "button": button_3}
	]
	
	# Group asteroid resource UI nodes for easy access by index
	asteroid_resource_nodes = [
		{"name": name_1, "value": value_1, "container": name_1.get_parent()},
		{"name": name_2, "value": value_2, "container": name_2.get_parent()},
		{"name": name_3, "value": value_3, "container": name_3.get_parent()},
		{"name": name_4, "value": value_4, "container": name_4.get_parent()}
	]

	# Connect button signals
	button_1.pressed.connect(_on_start_mission_pressed.bind(0))
	button_2.pressed.connect(_on_start_mission_pressed.bind(1))
	button_3.pressed.connect(_on_start_mission_pressed.bind(2))
	release_asteroid.pressed.connect(_on_release_asteroid_pressed)
	show_upgrade_panel.pressed.connect(_on_upgrades_window_pressed)

	# Perform the initial UI update.
	_on_player_data_updated()


func _process(_delta: float) -> void:
	# If there's no data yet, do nothing.
	if not scout_data:
		return
		
	if not scout_data.is_mission_active():
		return

	if Time.get_unix_time_from_system() >= scout_data.mission_completion_timestamp:
		# The mission is done. Tell the GameManager to complete it.
		# The UI will update automatically via the player_data_updated signal.
		print("Mission timer complete. Notifying GameManager.")
		GameManager.complete_scouting_mission()
	else:
		# The mission is still running, so just update the countdown timer.
		_update_mission_progress_ui()


func _on_start_mission_pressed(mission_index: int) -> void:
	var mission_config = missions[mission_index]
	
	# Ask the GameManager to start the mission.
	var success = GameManager.start_scouting_mission(mission_index, mission_config.duration, mission_config.scouts)
	if success:
		print("Started mission: %s" % mission_config.name)
	else:
		print("Failed to start mission (already active or no scouts?).")


func _on_player_data_updated() -> void:
	if not scout_data: return
	_update_ui()
	_update_active_asteroid_ui()


func _update_ui() -> void:
	var is_mission_active = scout_data.is_mission_active()
	var active_idx = scout_data.active_mission_index

	for i in mission_ui_nodes.size():
		var ui = mission_ui_nodes[i]
		var config = missions[i]

		ui.button.disabled = is_mission_active
		if is_mission_active and i == active_idx:
			_update_mission_progress_ui()
		else:
			var duration_str = _format_duration(config.duration)
			var reward_tier: String
			if config.scouts <= 1: reward_tier = "Low"
			elif config.scouts <= 3: reward_tier = "Medium"
			else: reward_tier = "High"
			
			ui.label.text = "%s\nDuration: %s\nReward Quality: %s" % [config.name, duration_str, reward_tier]


func _update_mission_progress_ui() -> void:
	var active_idx = scout_data.active_mission_index
	if active_idx == -1: return

	var time_left = scout_data.mission_completion_timestamp - Time.get_unix_time_from_system()
	var time_left_str = _format_duration(time_left)
	var ui = mission_ui_nodes[active_idx]
	var config = missions[active_idx]
	ui.label.text = "%s\nIn Progress...\nTime remaining: %s" % [config.name, time_left_str]

# Updates the UI elements that display the current asteroid's resources.
func _update_active_asteroid_ui() -> void:
	# This check is needed because this can be called via a signal before scout_data is ready.
	if not scout_data: return

	var asteroid = scout_data.active_asteroid
	var resource_keys = asteroid.keys()

	for i in range(asteroid_resource_nodes.size()):
		var ui_group = asteroid_resource_nodes[i]
		if i < resource_keys.size():
			# This slot is used, so show it and set the text
			var res_key = resource_keys[i]
			var res_value = asteroid[res_key]
			
			ui_group.container.visible = true
			ui_group.name.text = res_key.capitalize() + ":"
			ui_group.value.text = _format_number(res_value)
		else:
			# This slot is not used, hide its container
			ui_group.container.visible = false


# Helper function to format seconds into a more readable string (e.g., "1m 30s")
func _format_duration(total_seconds: int) -> String:
	if total_seconds < 0: total_seconds = 0
	@warning_ignore("integer_division")
	var minutes = total_seconds / 60
	var seconds = total_seconds % 60
	if minutes > 0:
		return "%dm %ds" % [minutes, seconds]
	else:
		return "%ds" % seconds


# Helper function to format large numbers with commas for readability.
func _format_number(number: int) -> String:
	var s = str(number)
	var s_len = s.length()
	if s_len <= 3:
		return s
	
	var remainder = s_len % 3
	if remainder == 0:
		remainder = 3
	var result = s.substr(0, remainder)
	for i in range(remainder, s_len, 3):
		result += "," + s.substr(i, 3)
	return result

func _on_release_asteroid_pressed() -> void:
	GameManager.cycle_active_asteroid()

func _on_upgrades_window_pressed() -> void:
	var upgrades := get_tree().get_root().find_child("GlobalUpgrades", true, false)
	if upgrades:
		upgrades.visible = true
	else:
		push_warning("GlobalUpgrades node not found")
