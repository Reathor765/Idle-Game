extends Control
class_name ResourceControl

# This script is responsible for displaying resource totals on the UI.
# It listens for updates from the GameManager and refreshes the labels.

# --- UI Node References ---
# Assign your RichTextLabel nodes from the editor.
# You should have 4 name labels and 4 value labels.
@export var resource_name_labels: Array[RichTextLabel]
@export var resource_value_labels: Array[RichTextLabel]
@export var robotics_name_labels: Array[RichTextLabel]
@export var robotics_value_labels: Array[RichTextLabel]


# --- Configuration ---
# Define which resources these labels should display, in order.
# IMPORTANT: These names must match the keys in GameManager.player_data.resources
@export var displayed_resources: Array[String] = ["hydrogen", "carbon", "oxygen", "nitrogen"]

@export var displayed_systems: Array[String] = ["Miner", "Fabricator"]


func _ready() -> void:
	# Ensure GameManager is ready before connecting.
	await get_tree().process_frame
	
	if not GameManager:
		push_error("GameManager not found. This script requires the GameManager autoload.")
		return

	# Connect to the signal that tells us the data has changed.
	GameManager.player_data_updated.connect(update_display)
	
	# Perform an initial update to show the starting values.
	update_display()


# Updates the text of the labels with the current resource values from GameManager.
func update_display() -> void:
	if not GameManager.player_data:
		return # Don't try to update if data isn't loaded yet.

	var player_resources: Dictionary = GameManager.player_data.resources
	var player_robotics: Dictionary = GameManager.player_data.systems

	# Loop through the labels and update them.
	var num_labels_to_update = min(displayed_resources.size(), resource_name_labels.size(), resource_value_labels.size())
	var num_labels_to_update2 = min(displayed_systems.size(), robotics_name_labels.size(), robotics_value_labels.size())
	for i in range(num_labels_to_update):
		var resource_name: String = displayed_resources[i]
		var name_label: RichTextLabel = resource_name_labels[i]
		var value_label: RichTextLabel = resource_value_labels[i]

		if name_label:
			# Capitalize the first letter for display.
			name_label.text = resource_name.capitalize() + ":"

		if value_label:
			# Get the resource value, defaulting to 0 if it doesn't exist.
			var resource_value: float = player_resources.get(resource_name, 0.0)
			# Format the number to show 1 decimal place. Adjust as needed.
			value_label.text = "%.1f" % resource_value
	for i in range (num_labels_to_update2):
		var system_name: String = displayed_systems[i]
		var name_label: RichTextLabel = robotics_name_labels[i]
		var value_label: RichTextLabel = robotics_value_labels[i]

		if name_label:
			name_label.text = system_name.capitalize() + ":"

		if value_label:
			# Access the nested dictionary for system units
			# Assuming "Sol" is the system and "robotics" or "infrastructure" are categories
			var system_value: int = 0
			if system_name == "Miner":
				system_value = player_robotics.get("Sol", {}).get("robotics", {}).get("Miner", 0)
			elif system_name == "Fabricator":
				system_value = player_robotics.get("Sol", {}).get("infrastructure", {}).get("Fabricator", 0)
			elif system_name == "Scout":
				system_value = player_robotics.get("Sol", {}).get("robotics", {}).get("Scout", 0)
			elif system_name == "Research":
				system_value = player_robotics.get("Sol", {}).get("infrastructure", {}).get("Research", 0)
			# Add more elifs for other systems as needed
			
			value_label.text = "%d" % system_value
