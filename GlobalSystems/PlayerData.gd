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
