extends Control

# --- Upgrade Data Structure ---
# This dictionary defines the entire upgrade tree.
# - key: A unique ID for the upgrade.
# - button_node: The button in the scene that corresponds to this upgrade.
# - cost: A dictionary of resource names and their amounts.
# - dependencies: An array of upgrade IDs that must be purchased first.
# - description: The text to display on the button.
var  upgrades: Dictionary = {}

@onready var tick_time_upgrade: Button = $MarginContainer/HBoxContainer/VBoxContainer/TickTimeUpgrade
@onready var asteroid_upgrade: Button = $MarginContainer/HBoxContainer/VBoxContainer/AsteroidUpgrade
@onready var miner_upgrade: Button = $MarginContainer/HBoxContainer/VBoxContainer/MinerUpgrade
@onready var fabricator_upgrade: Button = $MarginContainer/HBoxContainer/VBoxContainer/FabricatorUpgrade
@onready var scout_upgrade: Button = $MarginContainer/HBoxContainer/VBoxContainer/ScoutUpgrade
@onready var research_upgrade: Button = $MarginContainer/HBoxContainer/VBoxContainer/ResearchUpgrade

@onready var tick_time_upgrade_2: Button = $MarginContainer/HBoxContainer/VBoxContainer2/TickTimeUpgrade2
@onready var asteroid_upgrade_2: Button = $MarginContainer/HBoxContainer/VBoxContainer2/AsteroidUpgrade2
@onready var miner_upgrade_2: Button = $MarginContainer/HBoxContainer/VBoxContainer2/MinerUpgrade2
@onready var fabricator_upgrade_2: Button = $MarginContainer/HBoxContainer/VBoxContainer2/FabricatorUpgrade2
@onready var scout_upgrade_2: Button = $MarginContainer/HBoxContainer/VBoxContainer2/ScoutUpgrade2
@onready var research_upgrade_2: Button = $MarginContainer/HBoxContainer/VBoxContainer2/ResearchUpgrade2

@onready var tick_time_upgrade_3: Button = $MarginContainer/HBoxContainer/VBoxContainer3/TickTimeUpgrade3
@onready var asteroid_upgrade_3: Button = $MarginContainer/HBoxContainer/VBoxContainer3/AsteroidUpgrade3
@onready var miner_upgrade_3: Button = $MarginContainer/HBoxContainer/VBoxContainer3/MinerUpgrade3
@onready var fabricator_upgrade_3: Button = $MarginContainer/HBoxContainer/VBoxContainer3/FabricatorUpgrade3
@onready var scout_upgrade_3: Button = $MarginContainer/HBoxContainer/VBoxContainer3/ScoutUpgrade3
@onready var research_upgrade_3: Button = $MarginContainer/HBoxContainer/VBoxContainer3/ResearchUpgrade3

@onready var tick_time_upgrade_4: Button = $MarginContainer/HBoxContainer/VBoxContainer4/TickTimeUpgrade4
@onready var asteroid_upgrade_4: Button = $MarginContainer/HBoxContainer/VBoxContainer4/AsteroidUpgrade4
@onready var miner_upgrade_4: Button = $MarginContainer/HBoxContainer/VBoxContainer4/MinerUpgrade4
@onready var fabricator_upgrade_4: Button = $MarginContainer/HBoxContainer/VBoxContainer4/FabricatorUpgrade4
@onready var scout_upgrade_4: Button = $MarginContainer/HBoxContainer/VBoxContainer4/ScoutUpgrade4
@onready var research_upgrade_4: Button = $MarginContainer/HBoxContainer/VBoxContainer4/ResearchUpgrade4

@onready var tick_time_upgrade_5: Button = $MarginContainer/HBoxContainer/VBoxContainer5/TickTimeUpgrade5
@onready var asteroid_upgrade_5: Button = $MarginContainer/HBoxContainer/VBoxContainer5/AsteroidUpgrade5
@onready var miner_upgrade_5: Button = $MarginContainer/HBoxContainer/VBoxContainer5/MinerUpgrade5
@onready var fabricator_upgrade_5: Button = $MarginContainer/HBoxContainer/VBoxContainer5/FabricatorUpgrade5
@onready var scout_upgrade_5: Button = $MarginContainer/HBoxContainer/VBoxContainer5/ScoutUpgrade5
@onready var research_upgrade_5: Button = $MarginContainer/HBoxContainer/VBoxContainer5/ResearchUpgrade5

@onready var tick_time_upgrade_6: Button = $MarginContainer/HBoxContainer/VBoxContainer6/TickTimeUpgrade6
@onready var asteroid_upgrade_6: Button = $MarginContainer/HBoxContainer/VBoxContainer6/AsteroidUpgrade6
@onready var miner_upgrade_6: Button = $MarginContainer/HBoxContainer/VBoxContainer6/MinerUpgrade6
@onready var fabricator_upgrade_6: Button = $MarginContainer/HBoxContainer/VBoxContainer6/FabricatorUpgrade6
@onready var scout_upgrade_6: Button = $MarginContainer/HBoxContainer/VBoxContainer6/ScoutUpgrade6
@onready var research_upgrade_6: Button = $MarginContainer/HBoxContainer/VBoxContainer6/ResearchUpgrade6

@onready var tick_time_upgrade_7: Button = $MarginContainer/HBoxContainer/VBoxContainer7/TickTimeUpgrade7
@onready var asteroid_upgrade_7: Button = $MarginContainer/HBoxContainer/VBoxContainer7/AsteroidUpgrade7
@onready var miner_upgrade_7: Button = $MarginContainer/HBoxContainer/VBoxContainer7/MinerUpgrade7
@onready var fabricator_upgrade_7: Button = $MarginContainer/HBoxContainer/VBoxContainer7/FabricatorUpgrade7
@onready var scout_upgrade_7: Button = $MarginContainer/HBoxContainer/VBoxContainer7/ScoutUpgrade7
@onready var research_upgrade_7: Button = $MarginContainer/HBoxContainer/VBoxContainer7/ResearchUpgrade7


func _ready() -> void:
	# It's good practice to wait a frame for autoloads like GameManager to be fully ready.
	await get_tree().process_frame
	
	_initialize_upgrades()
	
	GameManager.player_data_updated.connect(update_ui)
	update_ui()


func _initialize_upgrades() -> void:
	upgrades = {
		"tick_time_1": {
			"button_node": tick_time_upgrade,
			"cost": {"research_points": 10},
			"dependencies": [],
			"description": "Tick Faster I\nTicks are 5% faster."
		},
		"asteroid_1": {
			"button_node": asteroid_upgrade,
			"cost": {"research_points": 20},
			"dependencies": [],
			"description": "Asteroid Mining I\nAsteroid resources 2X."
		},
		"miner_1": {
			"button_node": miner_upgrade,
			"cost": {"research_points": 25},
			"dependencies": ["tick_time_1"],
			"description": "Efficient Miners I\nMiners are 50% better."
		},
		"fabricator_1": {
			"button_node": fabricator_upgrade,
			"cost": {"research_points": 25},
			"dependencies": ["tick_time_1"],
			"description": "Efficient Fabs I\nFabricators are 10% cheaper."
		},
		"scout_1": {
			"button_node": scout_upgrade,
			"cost": {"research_points": 50},
			"dependencies": ["miner_1", "fabricator_1"],
			"description": "Efficient Scouts I\nScouts are 10% cheaper."
		},
		"research_1": {
			"button_node": research_upgrade,
			"cost": {"research_points": 100},
			"dependencies": ["scout_1"],
			"description": "Efficient Research I\nResearch Bots are 10% cheaper."
		},
		# --- Tier 2 Example ---
		# To add more upgrades, just follow this pattern.
		# "tick_time_2": {
		# 	"button_node": tick_time_upgrade_2,
		# 	"cost": {"research_points": 200},
		# 	"dependencies": ["research_1"],
		# 	"description": "Tick Faster II\nTicks are another 5% faster."
		# },
	}
	
	# Connect all buttons to the generic handler
	for upgrade_id in upgrades:
		var upgrade_data = upgrades[upgrade_id]
		if upgrade_data.button_node:
			upgrade_data.button_node.pressed.connect(_on_upgrade_pressed.bind(upgrade_id))
		else:
			printerr("Upgrade button not found for: ", upgrade_id)


func update_ui() -> void:
	if not GameManager.player_data: return

	for upgrade_id in upgrades:
		var data = upgrades[upgrade_id]
		var button: Button = data.button_node
		
		if GameManager.player_data.has_upgrade(upgrade_id):
			button.disabled = true
			button.text = data.description + "\n(Purchased)"
			button.modulate = Color.DARK_GRAY
			continue

		# Check dependencies
		var dependencies_met = true
		for dep_id in data.dependencies:
			if not GameManager.player_data.has_upgrade(dep_id):
				dependencies_met = false
				break
		
		if not dependencies_met:
			button.disabled = true
			button.text = data.description + "\n(Locked)"
			button.modulate = Color.WHITE # Reset color
			continue

		# Check cost
		var can_afford = true
		var cost_string = "Cost: "
		var cost_parts = []
		for resource in data.cost:
			var cost_amount = data.cost[resource]
			cost_parts.append("%s %s" % [cost_amount, resource.replace("_points", "").capitalize()])
			if GameManager.player_data.resources.get(resource, 0.0) < cost_amount:
				can_afford = false
		cost_string += ", ".join(cost_parts)
		
		button.text = data.description + "\n" + cost_string
		button.disabled = not can_afford
		button.modulate = Color.WHITE # Reset color


func _on_upgrade_pressed(upgrade_id: String) -> void:
	if not upgrades.has(upgrade_id): return
	
	var upgrade_data = upgrades[upgrade_id]
	var success = GameManager.purchase_global_upgrade(upgrade_id, upgrade_data.cost)
	
	if success:
		print("Successfully purchased upgrade: ", upgrade_id)
	else:
		print("Failed to purchase upgrade: ", upgrade_id)
