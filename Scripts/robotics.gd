extends Control
# This script controls the elements on the main screen that allows
# buying more miners and fabricators.

# --- UI Nodes ---
@onready var miner_buy_val: RichTextLabel = $Mining/MinerCost/MinerBuyVal
@onready var miner_buy_button: Button = $Mining/MinerBuyButton
@onready var miner_progress_bar: ProgressBar = $Mining/MinerProgressBar
@onready var miner_build_timer: Timer = $Mining/MinerProgressBar/BuildTimer
@onready var fab_buy_val: RichTextLabel = $Fabrication/FabCost/FabBuyVal
@onready var fab_buy_button: Button = $Fabrication/FabBuyButton
@onready var fab_progress_bar: ProgressBar = $Fabrication/FabProgressBar
@onready var fab_build_timer: Timer = $Fabrication/FabProgressBar/BuildTimer
@onready var scout_buy_val: RichTextLabel = $"Scout Drone/DroneCost/DroneBuyVal"
@onready var scout_buy_button: Button = $"Scout Drone/DroneBuyButton"
@onready var scout_progress_bar: ProgressBar = $"Scout Drone/DroneProgressBar"
@onready var scout_build_timer: Timer = $"Scout Drone/DroneProgressBar/BuildTimer"
@onready var research_buy_val: RichTextLabel = $"Research Bots/ResearchCost/ResearchBuyVal"
@onready var research_buy_button: Button = $"Research Bots/ResearchBuyButton"
@onready var research_progress_bar: ProgressBar = $"Research Bots/ResearchProgressBar"
@onready var research_build_timer: Timer = $"Research Bots/ResearchProgressBar/BuildTimer"

# --- Exported Configuration ---
@export_group("Miner")
@export var miner_base_cost: float = 100.0
@export var miner_cost_increment: float = 1.15
@export var miner_cost_resource: String = "metals"
@export var miner_base_build_time: float = 5.0 # seconds
@export var miner_build_time_increment: float = 1.05 # 5% longer per existing miner

@export_group("Fabricator")
@export var fab_base_cost: float = 500.0
@export var fab_cost_increment: float = 1.25
@export var fab_cost_resource: String = "polymers"
@export var fab_base_build_time: float = 20.0 # seconds
@export var fab_build_time_increment: float = 1.10 # 10% longer per existing fabricator

@export_group("Scout Drone")
@export var scout_base_cost: float = 500.0
@export var scout_cost_increment: float = 1.25
@export var scout_cost_resource: String = "crystals"
@export var scout_base_build_time: float = 20.0 # seconds
@export var scout_build_time_increment: float = 1.10 # 10% longer per existing fabricator

@export_group("Research Bots")
@export var research_base_cost: Dictionary = {}
@export var research_cost_increment: float = 1.35
@export var research_base_build_time: float = 600.0 # seconds
@export var research_build_time_increment: float = 1.10 # 10% longer per existing fabricator

# --- Private State ---
var _current_miner_cost: float = 0.0
var _current_fab_cost: float = 0.0
var _current_scout_cost: float = 0.0
var _current_research_cost: Dictionary = {}



func _ready() -> void:
	# It's good practice to wait a frame for autoloads like GameManager to be fully ready.
	await get_tree().process_frame

	# Connect to the signal to automatically update when data changes.
	GameManager.player_data_updated.connect(update_display)

	# Connect button signals to their handler functions.
	miner_buy_button.pressed.connect(_on_buy_miner_pressed)
	fab_buy_button.pressed.connect(_on_buy_fab_pressed)
	scout_buy_button.pressed.connect(_on_buy_scout_pressed)
	research_buy_button.pressed.connect(_on_buy_research_pressed)
	
	# Connect timer signals to their completion handlers.
	miner_build_timer.timeout.connect(_on_miner_build_complete)
	fab_build_timer.timeout.connect(_on_fab_build_complete)
	scout_build_timer.timeout.connect(_on_scout_build_complete)
	research_build_timer.timeout.connect(_on_research_build_complete)

	# Perform the initial UI update.
	update_display()

func _process(_delta: float) -> void:
	# Update progress bars every frame if their timers are running.
	if miner_progress_bar.visible and not miner_build_timer.is_stopped():
		miner_progress_bar.value = (miner_build_timer.wait_time - miner_build_timer.time_left) * 100.0 / miner_build_timer.wait_time
	if fab_progress_bar.visible and not fab_build_timer.is_stopped():
		fab_progress_bar.value = (fab_build_timer.wait_time - fab_build_timer.time_left) * 100.0 / fab_build_timer.wait_time
	if scout_progress_bar.visible and not scout_build_timer.is_stopped():
		scout_progress_bar.value = (scout_build_timer.wait_time - scout_build_timer.time_left) * 100.0 / scout_build_timer.wait_time
	if research_progress_bar.visible and not research_build_timer.is_stopped():
		research_progress_bar.value = (research_build_timer.wait_time - research_build_timer.time_left) * 100.0 / research_build_timer.wait_time

func update_display() -> void:
	if not GameManager.player_data:
		return

	# Get current counts from player data, using .get() for safety.
	var current_miners = GameManager.player_data.systems.get("Sol", {}).get("robotics", {}).get("Miner", 0)
	var current_fabs = GameManager.player_data.systems.get("Sol", {}).get("infrastructure", {}).get("Fabricator", 0)
	var current_scouts = GameManager.player_data.systems.get("Sol", {}).get("robotics", {}).get("Scout", 0)
	var current_research_bots = GameManager.player_data.systems.get("Sol", {}).get("infrastructure", {}).get("Research", 0)

	# Calculate current costs based on an exponential growth formula.
	_current_miner_cost = miner_base_cost * pow(miner_cost_increment, current_miners)
	_current_fab_cost = fab_base_cost * pow(fab_cost_increment, current_fabs)
	_current_scout_cost = scout_base_cost * pow(scout_cost_increment, current_scouts)

	# Calculate the cost for each resource required for the Research Bot.
	_current_research_cost.clear()
	for resource in research_base_cost:
		var base_cost = research_base_cost[resource]
		_current_research_cost[resource] = base_cost * pow(research_cost_increment, current_research_bots)

	# Update cost labels in the UI.
	miner_buy_val.text = "%s" % int(_current_miner_cost)
	fab_buy_val.text = "%s" % int(_current_fab_cost)
	scout_buy_val.text = "%s" % int(_current_scout_cost)
	# Format the multi-resource cost for the Research Bot label.
	research_buy_val.text = _format_multi_resource_cost(_current_research_cost)

	var time_now = Time.get_unix_time_from_system()

	# --- Update Miner UI ---
	if GameManager.player_data.build_queue.has("Miner"):
		var build_info = GameManager.player_data.build_queue["Miner"]
		var time_left = build_info.completion_timestamp - time_now
		miner_progress_bar.visible = true
		miner_buy_button.disabled = true
		if time_left > 0 and miner_build_timer.is_stopped():
			miner_build_timer.wait_time = time_left
			miner_build_timer.start()
	else:
		#miner_progress_bar.visible = false
		if not miner_build_timer.is_stopped():
			miner_build_timer.stop()
		var player_miner_resource = GameManager.player_data.resources.get(miner_cost_resource, 0.0)
		miner_buy_button.disabled = player_miner_resource < _current_miner_cost

	# --- Update Fabricator UI ---
	if GameManager.player_data.build_queue.has("Fabricator"):
		var build_info = GameManager.player_data.build_queue["Fabricator"]
		var time_left = build_info.completion_timestamp - time_now
		fab_progress_bar.visible = true
		fab_buy_button.disabled = true
		if time_left > 0 and fab_build_timer.is_stopped():
			fab_build_timer.wait_time = time_left
			fab_build_timer.start()
	else:
		#fab_progress_bar.visible = false
		if not fab_build_timer.is_stopped():
			fab_build_timer.stop()
		var player_fab_resource = GameManager.player_data.resources.get(fab_cost_resource, 0.0)
		fab_buy_button.disabled = player_fab_resource < _current_fab_cost

	# --- Update Scout Drone UI ---
	if GameManager.player_data.build_queue.has("Scout"):
		var build_info = GameManager.player_data.build_queue["Scout"]
		var time_left = build_info.completion_timestamp - time_now
		scout_progress_bar.visible = true
		scout_buy_button.disabled = true
		if time_left > 0 and scout_build_timer.is_stopped():
			scout_build_timer.wait_time = time_left
			scout_build_timer.start()
	else:
		#scout_progress_bar.visible = false
		if not scout_build_timer.is_stopped():
			scout_build_timer.stop()
		var player_scout_resource = GameManager.player_data.resources.get(scout_cost_resource, 0.0)
		scout_buy_button.disabled = player_scout_resource < _current_scout_cost

	# --- Update Research Bot UI ---
	if GameManager.player_data.build_queue.has("Research"):
		var build_info = GameManager.player_data.build_queue["Research"]
		var time_left = build_info.completion_timestamp - time_now
		research_progress_bar.visible = true
		research_buy_button.disabled = true
		if time_left > 0 and research_build_timer.is_stopped():
			research_build_timer.wait_time = time_left
			research_build_timer.start()
	else:
		#research_progress_bar.visible = false
		if not research_build_timer.is_stopped():
			research_build_timer.stop()
		
		var can_afford_research = true
		for resource in _current_research_cost:
			var cost = _current_research_cost[resource]
			if GameManager.player_data.resources.get(resource, 0.0) < cost:
				can_afford_research = false
				break
		research_buy_button.disabled = not can_afford_research

func _on_buy_miner_pressed() -> void:
	var player_resource_amount = GameManager.player_data.resources.get(miner_cost_resource, 0.0)
	if player_resource_amount >= _current_miner_cost:
		# 1. Deduct cost immediately.
		GameManager.player_data.resources[miner_cost_resource] -= _current_miner_cost
		
		# 2. Calculate build time and tell GameManager to start the build.
		var current_miners = GameManager.player_data.systems.get("Sol", {}).get("robotics", {}).get("Miner", 0)
		var build_time = miner_base_build_time * pow(miner_build_time_increment, current_miners)
		
		# Apply a 10% build time reduction for each Fabricator.
		var current_fabs = GameManager.player_data.systems.get("Sol", {}).get("infrastructure", {}).get("Fabricator", 0)
		build_time *= pow(0.9, current_fabs)

		GameManager.start_build("Miner", build_time)

func _on_buy_fab_pressed() -> void:
	var player_fab_resource = GameManager.player_data.resources.get(fab_cost_resource, 0.0)
	if player_fab_resource >= _current_fab_cost:
		GameManager.player_data.resources[fab_cost_resource] -= _current_fab_cost
		
		var current_fabs = GameManager.player_data.systems.get("Sol", {}).get("infrastructure", {}).get("Fabricator", 0)
		var build_time = fab_base_build_time * pow(fab_build_time_increment, current_fabs)
		GameManager.start_build("Fabricator", build_time)

func _on_buy_scout_pressed() -> void:
	var player_scout_resource = GameManager.player_data.resources.get(scout_cost_resource, 0.0)
	if player_scout_resource >= _current_scout_cost:
		GameManager.player_data.resources[scout_cost_resource] -= _current_scout_cost
		
		var current_scouts = GameManager.player_data.systems.get("Sol", {}).get("robotics", {}).get("Scout", 0)
		var build_time = scout_base_build_time * pow(scout_build_time_increment, current_scouts)

		# Apply a 10% build time reduction for each Fabricator.
		var current_fabs = GameManager.player_data.systems.get("Sol", {}).get("infrastructure", {}).get("Fabricator", 0)
		build_time *= pow(0.9, current_fabs)

		GameManager.start_build("Scout", build_time)

func _on_buy_research_pressed() -> void:
	# Check if player can afford all required resources
	var can_afford = true
	for resource in _current_research_cost:
		var cost = _current_research_cost[resource]
		if GameManager.player_data.resources.get(resource, 0.0) < cost:
			can_afford = false
			break
	
	if can_afford:
		# Deduct cost for each resource
		for resource in _current_research_cost:
			var cost = _current_research_cost[resource]
			GameManager.player_data.resources[resource] -= cost

		var current_research_bots = GameManager.player_data.systems.get("Sol", {}).get("infrastructure", {}).get("Research", 0)
		var build_time = research_base_build_time * pow(research_build_time_increment, current_research_bots)

		# Apply a 10% build time reduction for each Fabricator.
		var current_fabs = GameManager.player_data.systems.get("Sol", {}).get("infrastructure", {}).get("Fabricator", 0)
		build_time *= pow(0.9, current_fabs)

		GameManager.start_build("Research", build_time)

func _on_miner_build_complete() -> void:
	GameManager.complete_build("Miner")


func _on_fab_build_complete() -> void:
	GameManager.complete_build("Fabricator")

func _on_scout_build_complete() -> void:
	GameManager.complete_build("Scout")

func _on_research_build_complete() -> void:
	GameManager.complete_build("Research")


func _format_multi_resource_cost(costs: Dictionary) -> String:
	var cost_string_parts: Array[String] = []
	# Using keys() to ensure consistent order, though dictionary order is stable in Godot 4.
	for resource in costs.keys():
		var cost = costs[resource]
		cost_string_parts.append("%s %s" % [int(cost), resource.substr(0, 1).to_upper()])
	return ", ".join(cost_string_parts)
