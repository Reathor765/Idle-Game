# Example in a UI script
func _ready():
	# Connect to the signal to automatically update when data changes
	GameManager.player_data_updated.connect(update_labels)
	# Initial update
	update_labels()

func update_labels():
	var metals = GameManager.player_data.resources.get("metals", 0.0)
	$MetalsLabel.text = "Metals: %s" % int(metals)
