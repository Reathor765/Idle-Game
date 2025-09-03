extends Resource
class_name ScoutFindings
# This script is the control for what the scouting missions discover.
# The player will need to choose missions discover new asteroids to mine.
# Each asteroid will have a limited amount of resources. 
# Upgrades later on will allow for more than one asteroid to be mined at a time.

# The currently active asteroid being mined.
# Format: {"metals": 10000, "polymers": 5000}
@export var active_asteroid: Dictionary = {}

# A list of other discovered asteroids waiting to be mined.
@export var discovered_asteroids: Array[Dictionary] = []

# Timestamp for when the current scouting mission will complete. 0 if no mission is active.
@export var mission_completion_timestamp: int = 0

# Index of the active mission. Corresponds to the mission list in a UI Panel.
# This is needed to determine the reward upon completion.
# -1 means no mission is active.
@export var active_mission_index: int = -1

# The scout count modifier for the active mission, used for reward calculation.
@export var active_mission_reward_scouts: int = 0

enum ScoutMission {
	SHORT_RANGE,
	LONG_RANGE,
	DEEP_SPACE
}

# --- Rarity Configuration ---
# Defines the chance for each resource to appear on a new asteroid.
var RESOURCE_CHANCES : Dictionary= {
	"metals": 1.0,    # Always appears
	"polymers": 0.75, # 75% chance
	"organics": 0.40, # 40% chance
	"crystals": 0.15  # 15% chance
}

# Defines the base amount range for each resource if it appears.
const RESOURCE_AMOUNTS : Dictionary= {
	"metals": Vector2(5000, 20000),
	"polymers": Vector2(2500, 10000),
	"organics": Vector2(1000, 5000),
	"crystals": Vector2(100, 1000)
}


func is_mission_active() -> bool:
	return mission_completion_timestamp > 0


# This can be called by your future UI to display discovery probabilities.
func get_discovery_chances() -> Dictionary:
	return RESOURCE_CHANCES.duplicate()


# Generates a new asteroid. The number of scouts can influence the result.
func generate_new_asteroid(scout_count: int) -> Dictionary:
	var new_asteroid: Dictionary = {}
	var rng := RandomNumberGenerator.new()

	# Create a local copy of the chances to avoid modifying the class constant.
	var current_chances = RESOURCE_CHANCES.duplicate()
	# Each scout increases the chance of finding rarer resources by a small amount.
	for _i in range(scout_count):
		for res_name in current_chances:
			# Cap the chance at 100%
			current_chances[res_name] = min(current_chances[res_name] + 0.05, 1.0)

	# Start with a base quantity bonus from scouts (e.g., 5% more resources per scout).
	var quantity_multiplier = 1.0 + (scout_count * 0.05)
	
	# Get the powerful multiplier from global upgrades and apply it.
	# This correctly handles the doubling effect for each purchased "Asteroid" tier.
	quantity_multiplier *= GameManager.get_asteroid_resource_multiplier()

	for res_name in current_chances:
		if rng.randf() < current_chances[res_name]:
			var amount_range: Vector2 = RESOURCE_AMOUNTS[res_name]
			var amount = rng.randf_range(amount_range.x, amount_range.y) * quantity_multiplier
			new_asteroid[res_name] = int(amount)
	
	return new_asteroid


# Mines resources from the active asteroid. Returns the dictionary of resources that were actually mined.
func mine_resources(requested_amounts: Dictionary) -> Dictionary:
	var mined_resources : Dictionary = {}
	for res_key in requested_amounts:
		if active_asteroid.has(res_key):
			var requested = requested_amounts[res_key]
			var available = active_asteroid[res_key]
			var amount_to_mine = min(requested, available)
			
			if amount_to_mine > 0:
				mined_resources[res_key] = amount_to_mine
				active_asteroid[res_key] -= amount_to_mine
		
	return mined_resources


func is_active_asteroid_depleted() -> bool:
	if active_asteroid.is_empty():
		return true
	var total_resources: float = 0.0
	for resource_amount in active_asteroid.values():
		total_resources += resource_amount
	return total_resources <= 0
	
# Promotes the next asteroid from the discovered list to be the active one.
# Returns true if a new asteroid was promoted, false otherwise.
func promote_next_asteroid() -> bool:
	active_asteroid.clear()
	if not discovered_asteroids.is_empty():
		active_asteroid = discovered_asteroids.pop_front()
		return true
	return false
