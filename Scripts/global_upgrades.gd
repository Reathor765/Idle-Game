extends Control

# --- Upgrade Data Structure ---
# This dictionary defines the entire upgrade tree.
# - key: A unique ID for the upgrade.
# - button_node: The button in the scene that corresponds to this upgrade.
# - cost: A dictionary of resource names and their amounts.
# - dependencies: An array of upgrade IDs that must be purchased first.
# - description: The text to display on the button.
var  upgrades: Dictionary = {}

@onready var tick_time_upgrade: Button = $GlobalUpgradePanel/ScrollListContainer/HBoxContainer/VBoxContainer/TickTimeUpgrade
@onready var tick_time_upgrade_2: Button = $GlobalUpgradePanel/ScrollListContainer/HBoxContainer/VBoxContainer/TickTimeUpgrade2
@onready var tick_time_upgrade_3: Button = $GlobalUpgradePanel/ScrollListContainer/HBoxContainer/VBoxContainer/TickTimeUpgrade3
@onready var tick_time_upgrade_4: Button = $GlobalUpgradePanel/ScrollListContainer/HBoxContainer/VBoxContainer/TickTimeUpgrade4
@onready var tick_time_upgrade_5: Button = $GlobalUpgradePanel/ScrollListContainer/HBoxContainer/VBoxContainer/TickTimeUpgrade5
@onready var tick_time_upgrade_6: Button = $GlobalUpgradePanel/ScrollListContainer/HBoxContainer/VBoxContainer/TickTimeUpgrade6
@onready var tick_time_upgrade_7: Button = $GlobalUpgradePanel/ScrollListContainer/HBoxContainer/VBoxContainer/TickTimeUpgrade7
@onready var tick_time_upgrade_8: Button = $GlobalUpgradePanel/ScrollListContainer/HBoxContainer/VBoxContainer/TickTimeUpgrade8
@onready var asteroid_upgrade: Button = $GlobalUpgradePanel/ScrollListContainer/HBoxContainer/VBoxContainer/AsteroidUpgrade
@onready var asteroid_upgrade_2: Button = $GlobalUpgradePanel/ScrollListContainer/HBoxContainer/VBoxContainer/AsteroidUpgrade2
@onready var asteroid_upgrade_3: Button = $GlobalUpgradePanel/ScrollListContainer/HBoxContainer/VBoxContainer/AsteroidUpgrade3
@onready var asteroid_upgrade_4: Button = $GlobalUpgradePanel/ScrollListContainer/HBoxContainer/VBoxContainer/AsteroidUpgrade4
@onready var asteroid_upgrade_5: Button = $GlobalUpgradePanel/ScrollListContainer/HBoxContainer/VBoxContainer/AsteroidUpgrade5
@onready var asteroid_upgrade_6: Button = $GlobalUpgradePanel/ScrollListContainer/HBoxContainer/VBoxContainer/AsteroidUpgrade6
@onready var asteroid_upgrade_7: Button = $GlobalUpgradePanel/ScrollListContainer/HBoxContainer/VBoxContainer/AsteroidUpgrade7
@onready var asteroid_upgrade_8: Button = $GlobalUpgradePanel/ScrollListContainer/HBoxContainer/VBoxContainer/AsteroidUpgrade8

@onready var miner_upgrade: Button = $GlobalUpgradePanel/ScrollListContainer/HBoxContainer/VBoxContainer8/MinerUpgrade
@onready var miner_upgrade_2: Button = $GlobalUpgradePanel/ScrollListContainer/HBoxContainer/VBoxContainer8/MinerUpgrade2
@onready var miner_upgrade_3: Button = $GlobalUpgradePanel/ScrollListContainer/HBoxContainer/VBoxContainer8/MinerUpgrade3
@onready var miner_upgrade_4: Button = $GlobalUpgradePanel/ScrollListContainer/HBoxContainer/VBoxContainer8/MinerUpgrade4
@onready var miner_upgrade_5: Button = $GlobalUpgradePanel/ScrollListContainer/HBoxContainer/VBoxContainer8/MinerUpgrade5
@onready var miner_upgrade_6: Button = $GlobalUpgradePanel/ScrollListContainer/HBoxContainer/VBoxContainer8/MinerUpgrade6
@onready var miner_upgrade_7: Button = $GlobalUpgradePanel/ScrollListContainer/HBoxContainer/VBoxContainer8/MinerUpgrade7
@onready var miner_upgrade_8: Button = $GlobalUpgradePanel/ScrollListContainer/HBoxContainer/VBoxContainer8/MinerUpgrade8
@onready var fabricator_upgrade: Button = $GlobalUpgradePanel/ScrollListContainer/HBoxContainer/VBoxContainer8/FabricatorUpgrade
@onready var fabricator_upgrade_2: Button = $GlobalUpgradePanel/ScrollListContainer/HBoxContainer/VBoxContainer8/FabricatorUpgrade2
@onready var fabricator_upgrade_3: Button = $GlobalUpgradePanel/ScrollListContainer/HBoxContainer/VBoxContainer8/FabricatorUpgrade3
@onready var fabricator_upgrade_4: Button = $GlobalUpgradePanel/ScrollListContainer/HBoxContainer/VBoxContainer8/FabricatorUpgrade4
@onready var fabricator_upgrade_5: Button = $GlobalUpgradePanel/ScrollListContainer/HBoxContainer/VBoxContainer8/FabricatorUpgrade5
@onready var fabricator_upgrade_6: Button = $GlobalUpgradePanel/ScrollListContainer/HBoxContainer/VBoxContainer8/FabricatorUpgrade6
@onready var fabricator_upgrade_7: Button = $GlobalUpgradePanel/ScrollListContainer/HBoxContainer/VBoxContainer8/FabricatorUpgrade7
@onready var fabricator_upgrade_8: Button = $GlobalUpgradePanel/ScrollListContainer/HBoxContainer/VBoxContainer8/FabricatorUpgrade8


@onready var scout_upgrade: Button = $GlobalUpgradePanel/ScrollListContainer/HBoxContainer/VBoxContainer2/ScoutUpgrade
@onready var scout_upgrade_2: Button = $GlobalUpgradePanel/ScrollListContainer/HBoxContainer/VBoxContainer2/ScoutUpgrade2
@onready var scout_upgrade_3: Button = $GlobalUpgradePanel/ScrollListContainer/HBoxContainer/VBoxContainer2/ScoutUpgrade3
@onready var scout_upgrade_4: Button = $GlobalUpgradePanel/ScrollListContainer/HBoxContainer/VBoxContainer2/ScoutUpgrade4
@onready var scout_upgrade_5: Button = $GlobalUpgradePanel/ScrollListContainer/HBoxContainer/VBoxContainer2/ScoutUpgrade5
@onready var scout_upgrade_6: Button = $GlobalUpgradePanel/ScrollListContainer/HBoxContainer/VBoxContainer2/ScoutUpgrade6
@onready var scout_upgrade_7: Button = $GlobalUpgradePanel/ScrollListContainer/HBoxContainer/VBoxContainer2/ScoutUpgrade7
@onready var scout_upgrade_8: Button = $GlobalUpgradePanel/ScrollListContainer/HBoxContainer/VBoxContainer2/ScoutUpgrade8
@onready var research_upgrade: Button = $GlobalUpgradePanel/ScrollListContainer/HBoxContainer/VBoxContainer2/ResearchUpgrade
@onready var research_upgrade_2: Button = $GlobalUpgradePanel/ScrollListContainer/HBoxContainer/VBoxContainer2/ResearchUpgrade2
@onready var research_upgrade_3: Button = $GlobalUpgradePanel/ScrollListContainer/HBoxContainer/VBoxContainer2/ResearchUpgrade3
@onready var research_upgrade_4: Button = $GlobalUpgradePanel/ScrollListContainer/HBoxContainer/VBoxContainer2/ResearchUpgrade4
@onready var research_upgrade_5: Button = $GlobalUpgradePanel/ScrollListContainer/HBoxContainer/VBoxContainer2/ResearchUpgrade5
@onready var research_upgrade_6: Button = $GlobalUpgradePanel/ScrollListContainer/HBoxContainer/VBoxContainer2/ResearchUpgrade6
@onready var research_upgrade_7: Button = $GlobalUpgradePanel/ScrollListContainer/HBoxContainer/VBoxContainer2/ResearchUpgrade7
@onready var research_upgrade_8: Button = $GlobalUpgradePanel/ScrollListContainer/HBoxContainer/VBoxContainer2/ResearchUpgrade8

@onready var return_button: Button = $GlobalUpgradePanel/ScrollListContainer/ReturnButton
@onready var toggle_button: CheckButton = $GlobalUpgradePanel/ScrollListContainer/ReturnButton/CheckButton
enum ButtonState {
	LOCKED,
	AVAILABLE,
	PURCHASED
}

func _ready() -> void:
	# It's good practice to wait a frame for autoloads like GameManager to be fully ready.
	await get_tree().process_frame
	
	_initialize_upgrades()
	
	GameManager.player_data_updated.connect(update_ui)
	update_ui()
	return_button.pressed.connect(_on_return_pressed)
	toggle_button.toggled.connect(_on_toggle_button_toggled)
func _on_toggle_button_toggled(_toggled: bool) -> void:
	update_ui()

func _initialize_upgrades() -> void:
	upgrades = {
		# --- Tier 1 Upgrades ---
		"tick_time_1": {
			"button_node": tick_time_upgrade,
			"cost": {"research_points": 10},
			"dependencies": [],
			"description": "Tick Faster I\nTicks are \n5% faster."
		},
		"asteroid_1": {
			"button_node": asteroid_upgrade,
			"cost": {"research_points": 20},
			"dependencies": [],
			"description": "Asteroid Mining I\nAsteroid resources \n2X."
		},
		"miner_1": {
			"button_node": miner_upgrade,
			"cost": {"research_points": 25},
			"dependencies": ["tick_time_1"],
			"description": "Efficient Miners I\nMiners are \n50% better."
		},
		"fabricator_1": {
			"button_node": fabricator_upgrade,
			"cost": {"research_points": 25},
			"dependencies": ["tick_time_1"],
			"description": "Efficient Fabs I\nFabricators are \n10% cheaper."
		},
		"scout_1": {
			"button_node": scout_upgrade,
			"cost": {"research_points": 50},
			"dependencies": ["miner_1", "fabricator_1"],
			"description": "Efficient Scouts I\nScouts are \n10% cheaper."
		},
		"research_1": {
			"button_node": research_upgrade,
			"cost": {"research_points": 100},
			"dependencies": ["scout_1"],
			"description": "Efficient Research I\nResearch Bots are\n10% cheaper."
		},
		# --- Tier 2 Upgrades ---
		"tick_time_2": {
			"button_node": tick_time_upgrade_2,
			"cost": {"research_points": 200},
			"dependencies": ["research_1"],
			"description": "Tick Faster II\nTicks are another \n5% faster."
		},
		"asteroid_2": {
			"button_node": asteroid_upgrade_2,
			"cost": {"research_points": 400},
			"dependencies": ["research_1"],
			"description": "Asteroid Mining II\nAsteroid resources \n2X ."
		},
		"miner_2": {
			"button_node": miner_upgrade_2,
			"cost": {"research_points": 500},
			"dependencies": ["miner_1", "tick_time_2"],
			"description": "Efficient Miners II\nMiners are \n50% better."
		},
		"fabricator_2": {
			"button_node": fabricator_upgrade_2,
			"cost": {"research_points": 500},
			"dependencies": ["fabricator_1", "tick_time_2"],
			"description": "Efficient Fabs II\nFabricators are \n10% cheaper."
		},
		"scout_2": {
			"button_node": scout_upgrade_2,
			"cost": {"research_points": 1000},
			"dependencies": ["scout_1", "miner_2", "fabricator_2"],
			"description": "Efficient Scouts II\nScouts are \n10% cheaper."
		},
		"research_2": {
			"button_node": research_upgrade_2,
			"cost": {"research_points": 2000},
			"dependencies": ["research_1", "scout_2"],
			"description": "Efficient Research II\nResearch Bots are\n10% cheaper."
		},
		# --- Tier 3 Upgrades ---
		"tick_time_3": {
			"button_node": tick_time_upgrade_3,
			"cost": {"research_points": 4000},
			"dependencies": ["research_2"],
			"description": "Tick Faster III\nTicks are another \n5% faster."
		},
		"asteroid_3": {
			"button_node": asteroid_upgrade_3,
			"cost": {"research_points": 8000},
			"dependencies": ["research_2"],
			"description": "Asteroid Mining III\nAsteroid resources \n2X ."
		},
		"miner_3": {
			"button_node": miner_upgrade_3,
			"cost": {"research_points": 10000},
			"dependencies": ["miner_2", "tick_time_3"],
			"description": "Efficient Miners III\nMiners are \n50% better."
		},
		"fabricator_3": {
			"button_node": fabricator_upgrade_3,
			"cost": {"research_points": 10000},
			"dependencies": ["fabricator_2", "tick_time_3"],
			"description": "Efficient Fabs III\nFabricators are \n10% cheaper."
		},
		"scout_3": {
			"button_node": scout_upgrade_3,
			"cost": {"research_points": 20000},
			"dependencies": ["scout_2", "miner_3", "fabricator_3"],
			"description": "Efficient Scouts III\nScouts are \n10% cheaper."
		},
		"research_3": {
			"button_node": research_upgrade_3,
			"cost": {"research_points": 40000},
			"dependencies": ["research_2", "scout_3"],
			"description": "Efficient Research III\nResearch Bots are\n10% cheaper."
		},
		# --- Tier 4 Upgrades ---
		"tick_time_4": {
			"button_node": tick_time_upgrade_4,
			"cost": {"research_points": 80000},
			"dependencies": ["research_3"],
			"description": "Tick Faster IV\nTicks are another \n5% faster."
		},
		"asteroid_4": {
			"button_node": asteroid_upgrade_4,
			"cost": {"research_points": 160000},
			"dependencies": ["research_3"],
			"description": "Asteroid Mining IV\nAsteroid resources \n2X."
		},
		"miner_4": {
			"button_node": miner_upgrade_4,
			"cost": {"research_points": 200000},
			"dependencies": ["miner_3", "tick_time_4"],
			"description": "Efficient Miners IV\nMiners are \n50% better."
		},
		"fabricator_4": {
			"button_node": fabricator_upgrade_4,
			"cost": {"research_points": 200000},
			"dependencies": ["fabricator_3", "tick_time_4"],
			"description": "Efficient Fabs IV\nFabricators are \n10% cheaper."
		},
		"scout_4": {
			"button_node": scout_upgrade_4,
			"cost": {"research_points": 400000},
			"dependencies": ["scout_3", "miner_4", "fabricator_4"],
			"description": "Efficient Scouts IV\nScouts are \n10% cheaper."
		},
		"research_4": {
			"button_node": research_upgrade_4,
			"cost": {"research_points": 800000},
			"dependencies": ["research_3", "scout_4"],
			"description": "Efficient Research IV\nResearch Bots are\n10% cheaper."
		},
		# --- Tier 5 Upgrades ---
		"tick_time_5": {
			"button_node": tick_time_upgrade_5,
			"cost": {"research_points": 1600000},
			"dependencies": ["research_4"],
			"description": "Tick Faster V\nTicks are another \n5% faster."
		},
		"asteroid_5": {
			"button_node": asteroid_upgrade_5,
			"cost": {"research_points": 3200000},
			"dependencies": ["research_4"],
			"description": "Asteroid Mining V\nAsteroid resources \n2X."
		},
		"miner_5": {
			"button_node": miner_upgrade_5,
			"cost": {"research_points": 4000000},
			"dependencies": ["miner_4", "tick_time_5"],
			"description": "Efficient Miners V\nMiners are \n50% better."
		},
		"fabricator_5": {
			"button_node": fabricator_upgrade_5,
			"cost": {"research_points": 4000000},
			"dependencies": ["fabricator_4", "tick_time_5"],
			"description": "Efficient Fabs V\nFabricators are \n10% cheaper."
		},
		"scout_5": {
			"button_node": scout_upgrade_5,
			"cost": {"research_points": 8000000},
			"dependencies": ["scout_4", "miner_5", "fabricator_5"],
			"description": "Efficient Scouts V\nScouts are \n10% cheaper."
		},
		"research_5": {
			"button_node": research_upgrade_5,
			"cost": {"research_points": 16000000},
			"dependencies": ["research_4", "scout_5"],
			"description": "Efficient Research V\nResearch Bots are\n10% cheaper."
		},
		# --- Tier 6 Upgrades ---
		"tick_time_6": {
			"button_node": tick_time_upgrade_6,
			"cost": {"research_points": 32000000},
			"dependencies": ["research_5"],
			"description": "Tick Faster VI\nTicks are another \n5% faster."
		},
		"asteroid_6": {
			"button_node": asteroid_upgrade_6,
			"cost": {"research_points": 64000000},
			"dependencies": ["research_5"],
			"description": "Asteroid Mining VI\nAsteroid resources \n2X."
		},
		"miner_6": {
			"button_node": miner_upgrade_6,
			"cost": {"research_points": 80000000},
			"dependencies": ["miner_5", "tick_time_6"],
			"description": "Efficient Miners VI\nMiners are \n50% better."
		},
		"fabricator_6": {
			"button_node": fabricator_upgrade_6,
			"cost": {"research_points": 80000000},
			"dependencies": ["fabricator_5", "tick_time_6"],
			"description": "Efficient Fabs VI\nFabricators are \n10% cheaper."
		},
		"scout_6": {
			"button_node": scout_upgrade_6,
			"cost": {"research_points": 160000000},
			"dependencies": ["scout_5", "miner_6", "fabricator_6"],
			"description": "Efficient Scouts VI\nScouts are \n10% cheaper."
		},
		"research_6": {
			"button_node": research_upgrade_6,
			"cost": {"research_points": 320000000},
			"dependencies": ["research_5", "scout_6"],
			"description": "Efficient Research VI\nResearch Bots are\n10% cheaper."
		},
		# --- Tier 7 Upgrades ---
		"tick_time_7": {
			"button_node": tick_time_upgrade_7,
			"cost": {"research_points": 640000000},
			"dependencies": ["research_6"],
			"description": "Tick Faster VII\nTicks are another \n5% faster."
		},
		"asteroid_7": {
			"button_node": asteroid_upgrade_7,
			"cost": {"research_points": 1280000000},
			"dependencies": ["research_6"],
			"description": "Asteroid Mining VII\nAsteroid resources \n2X."
		},
		"miner_7": {
			"button_node": miner_upgrade_7,
			"cost": {"research_points": 1600000000},
			"dependencies": ["miner_6", "tick_time_7"],
			"description": "Efficient Miners VII\nMiners are \n50% better."
		},
		"fabricator_7": {
			"button_node": fabricator_upgrade_7,
			"cost": {"research_points": 1600000000},
			"dependencies": ["fabricator_6", "tick_time_7"],
			"description": "Efficient Fabs VII\nFabricators are \n10% cheaper."
		},
		"scout_7": {
			"button_node": scout_upgrade_7,
			"cost": {"research_points": 3200000000},
			"dependencies": ["scout_6", "miner_7", "fabricator_7"],
			"description": "Efficient Scouts VII\nScouts are \n10% cheaper."
		},
		"research_7": {
			"button_node": research_upgrade_7,
			"cost": {"research_points": 6400000000},
			"dependencies": ["research_6", "scout_7"],
			"description": "Efficient Research VII\nResearch Bots are\n10% cheaper."
		},
		# --- Tier 8 Upgrades ---
		"tick_time_8": {
			"button_node": tick_time_upgrade_8,
			"cost": {"research_points": 12800000000},
			"dependencies": ["research_7"],
			"description": "Tick Faster VIII\nTicks are another \n5% faster."
		},
		"asteroid_8": {
			"button_node": asteroid_upgrade_8,
			"cost": {"research_points": 25600000000},
			"dependencies": ["research_7"],
			"description": "Asteroid Mining VIII\nAsteroid resources \n2X."
		},
		"miner_8": {
			"button_node": miner_upgrade_8,
			"cost": {"research_points": 32000000000},
			"dependencies": ["miner_7", "tick_time_8"],
			"description": "Efficient Miners VIII\nMiners are \n50% better."
		},
		"fabricator_8": {
			"button_node": fabricator_upgrade_8,
			"cost": {"research_points": 32000000000},
			"dependencies": ["fabricator_7", "tick_time_8"],
			"description": "Efficient Fabs VIII\nFabricators are \n10% cheaper."
		},
		"scout_8": {
			"button_node": scout_upgrade_8,
			"cost": {"research_points": 64000000000},
			"dependencies": ["scout_7", "miner_8", "fabricator_8"],
			"description": "Efficient Scouts VIII\nScouts are \n10% cheaper."
		},
		"research_8": {
			"button_node": research_upgrade_8,
			"cost": {"research_points": 128000000000},
			"dependencies": ["research_7", "scout_8"],
			"description": "Efficient Research VIII\nResearch Bots are\n10% cheaper."
		},
		# To add more upgrades, just follow this pattern.
		# "tick_time_2": {
		# 	"button_node": tick_time_upgrade_2,
		# 	"cost": {"research_points": 200},
		# 	"dependencies": ["research_1"],
		# 	"description": "Tick Faster II\nTicks are another \n5% faster."
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
			button.visible = not toggle_button.toggled
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
			button.visible = true
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
		button.visible = true


func _on_upgrade_pressed(upgrade_id: String) -> void:
	if not upgrades.has(upgrade_id): return
	
	var upgrade_data = upgrades[upgrade_id]
	var success = GameManager.purchase_global_upgrade(upgrade_id, upgrade_data.cost)
	
	if success:
		print("Successfully purchased upgrade: ", upgrade_id)
		update_ui()
	else:
		print("Failed to purchase upgrade: ", upgrade_id)
	
	


func _on_return_pressed()-> void:
	self.visible = false
	
