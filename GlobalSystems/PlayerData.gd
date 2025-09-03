extends Resource
class_name PlayerData

# PlayerData is a custom Resource that holds all the persistent state of the game.
# Using a Resource is ideal for save data as Godot handles serialization for us.

# -- Player's Current Assets --

# A dictionary to store the current amount of each resource.
# Example: {"metals": 1050.5, "polymers": 300.0, "electronics": 50.0}
@export var resources: Dictionary = {}

# -- Galactic Empire State --

# A dictionary where each key is a system name (e.g., "Sol") and the value is
# another dictionary detailing the state of that system.
# Example: {"Sol": {"infrastructure": {"Fabricator": 2, "Scanner": 1}}}
@export var systems: Dictionary = {}

# -- Permanent Progression --

# A dictionary to store the levels of global upgrades purchased.
# Example: {"fabrication_speed": 3, "vessel_cost": 1}
@export var global_upgrades: Dictionary = {}
@export var research_upgrades: Dictionary = {}
@export var milestones_completed: Array[String] = []
@export var verified_iaps: Array[String] = []
# A dictionary to store active build jobs.
# Example: {"Miner": {"completion_timestamp": 1678886400, "total_build_time": 5.0}}
@export var build_queue: Dictionary = {}

# Holds all data related to scouting and discovered asteroids.
@export var scout_findings: ScoutFindings

# -- System Data --

# Stores the Unix timestamp of the last time the game was saved. Used for offline progress.
@export var last_save_timestamp: int = 0


# Helper function to easily check if an upgrade has been purchased.
func has_upgrade(upgrade_id: String) -> bool:
	return upgrade_id in global_upgrades


# Helper function to check if a milestone has been completed.
func has_milestone(milestone_id: String) -> bool:
	return milestone_id in milestones_completed


# Marks a milestone as complete. Returns true if it was newly completed.
func complete_milestone(milestone_id: String) -> bool:
	if not has_milestone(milestone_id):
		milestones_completed.append(milestone_id)
		return true
	return false

func get_incomplete_milestones() -> Array[String]:
	# This should be the single source of truth for all milestone IDs in the game.
	var all_milestones: Array[String] = [
		# Tier 1
		"gather_metals_1k",
		"build_miners_10",
		"gen_research_100",
		"purchase_tick_1",
		# Tier 2
		"gather_polymers_1k",
		"build_fabricators_10",
		"purchase_miner_1",
		"discover_asteroid_1",
		# Tier 3
		"gather_organics_1k",
		"build_scouts_10",
		"purchase_scout_1",
		"deplete_asteroid_1",
		# Tier 4
		"gather_crystals_1k",
		"build_research_10",
		"purchase_research_1",
		"purchase_tier_3_upg",
		# Tier 5
		"gather_metals_1m",
		"gen_research_10k",
		"discover_asteroids_5",
		"all_upgrades_t1"
	]
	var incomplete: Array[String] = []
	for milestone_id in all_milestones:
		if not has_milestone(milestone_id):
			incomplete.append(milestone_id)
	return incomplete


# Checks if the condition for a given milestone is met based on the current game state.
func is_milestone_condition_met(milestone_id: String) -> bool:
	match milestone_id:
		# --- Tier 1: The Basics ---
		"gather_metals_1k": return resources.get("metals", 0.0) >= 1000
		"build_miners_10": return systems.get("Sol", {}).get("robotics", {}).get("Miner", 0) >= 10
		"gen_research_100": return resources.get("research_points", 0.0) >= 100
		"purchase_tick_1": return has_upgrade("tick_time_1")
		# --- Tier 2: Expansion ---
		"gather_polymers_1k": return resources.get("polymers", 0.0) >= 1000
		"build_fabricators_10": return systems.get("Sol", {}).get("infrastructure", {}).get("Fabricator", 0) >= 10
		"purchase_miner_1": return has_upgrade("miner_1")
		"discover_asteroid_1": return scout_findings and not scout_findings.discovered_asteroids.is_empty()
		# --- Tier 3: Specialization ---
		"gather_organics_1k": return resources.get("organics", 0.0) >= 1000
		"build_scouts_10": return systems.get("Sol", {}).get("robotics", {}).get("Scout", 0) >= 10
		"purchase_scout_1": return has_upgrade("scout_1")
		"deplete_asteroid_1": return has_milestone("deplete_asteroid_1") # Special case: completed explicitly
		# --- Tier 4: Advanced Tech ---
		"gather_crystals_1k": return resources.get("crystals", 0.0) >= 1000
		"build_research_10": return systems.get("Sol", {}).get("infrastructure", {}).get("Research", 0) >= 10
		"purchase_research_1": return has_upgrade("research_1")
		"purchase_tier_3_upg": return _has_tier_3_upgrade()
		# --- Tier 5: Mastery ---
		"gather_metals_1m": return resources.get("metals", 0.0) >= 1000000
		"gen_research_10k": return resources.get("research_points", 0.0) >= 10000
		"discover_asteroids_5": return scout_findings and scout_findings.discovered_asteroids.size() >= 5
		"all_upgrades_t1": return _has_all_tier_1_upgrades()
	return false


func _has_tier_3_upgrade() -> bool:
	for upgrade_id in global_upgrades:
		if upgrade_id.ends_with("_3"):
			return true
	return false


func _has_all_tier_1_upgrades() -> bool:
	var tier_1_ids = ["tick_time_1", "asteroid_1", "miner_1", "fabricator_1", "scout_1", "research_1"]
	for id in tier_1_ids:
		if not has_upgrade(id):
			return false
	return true
	
func _has_all_tier_2_upgrades() -> bool:
	var tier_2_ids = ["tick_time_2", "asteroid_2", "miner_2", "fabricator_2", "scout_2", "research_2"]
	for id in tier_2_ids:
		if not has_upgrade(id):
			return false
	return true
	
