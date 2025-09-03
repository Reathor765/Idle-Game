extends Control
# This script controls the milestone list that must be completed before the player
# can move to the next section of the game.

# A dictionary to hold all milestone data, populated at runtime.
# Key: milestone_id (String)
# Value: Dictionary { "description": String, "label_node": Label, "checkbox_node": CheckBox, "check_function": Callable }
var milestones: Dictionary = {}

# We will populate this array programmatically instead of using 40 @onready vars.
var milestone_nodes: Array[Dictionary] = []

# A list of milestone IDs currently being animated to prevent UI updates from interfering.
var animating_milestones: Array[String] = []

# @onready var ftl_jump_button: Button = $FTLJumpButton # Uncomment when you add this button
@onready var hide_completed_checkbox: CheckButton = $HideCompletedCheckbutton

func _ready() -> void:
	# Wait a frame for autoloads like GameManager to be fully ready.
	await get_tree().process_frame
	
	hide_completed_checkbox.toggled.connect(update_milestone_ui)
	
	_initialize_nodes()
	_initialize_milestones()
	
	# Connect to the GameManager signal to react to data changes.
	GameManager.player_data_updated.connect(check_milestones)
	
	# Run the checks and set the initial UI state.
	check_milestones()
	update_milestone_ui()

# This function gets all the Label and CheckBox nodes from the scene.
# It assumes you have nodes named "Milestone1", "Milestone2", etc. inside "AchievementList".
func _initialize_nodes() -> void:
	var achievement_list = $ScrollListContainer/AchievementList
	for i in range(1, 21):
		var milestone_node = achievement_list.get_node_or_null("Milestone%d" % i)
		if milestone_node:
			milestone_nodes.append({
				"container": milestone_node,
				"label": milestone_node.get_node("Label"),
				"checkbox": milestone_node.get_node("CheckBox")
			})
		else:
			printerr("Milestone node not found: Milestone%d" % i)

# This is where you define all your milestones.
# The order in this array MUST match the order of Milestone nodes (1-20) in your scene.
func _initialize_milestones() -> void:
	var milestone_definitions = [
		# --- Tier 1: The Basics ---
		{"id": "gather_metals_1k", "desc": "Gather 1,000 Metals"},
		{"id": "build_miners_10", "desc": "Build 10 Miners"},
		{"id": "gen_research_100", "desc": "Generate 100 Research Points"},
		{"id": "purchase_tick_1", "desc": "Purchase 'Tick Faster I'"},
		
		# --- Tier 2: Expansion ---
		{"id": "gather_polymers_1k", "desc": "Gather 1,000 Polymers"},
		{"id": "build_fabricators_10", "desc": "Build 10 Fabricators"},
		{"id": "purchase_miner_1", "desc": "Purchase 'Efficient Miners I'"},
		{"id": "discover_asteroid_1", "desc": "Discover a new asteroid"},
		
		# --- Tier 3: Specialization ---
		{"id": "gather_organics_1k", "desc": "Gather 1,000 Organics"},
		{"id": "build_scouts_10", "desc": "Build 10 Scouts"},
		{"id": "purchase_scout_1", "desc": "Purchase 'Efficient Scouts I'"},
		{"id": "deplete_asteroid_1", "desc": "Deplete an asteroid"},
		
		# --- Tier 4: Advanced Tech ---
		{"id": "gather_crystals_1k", "desc": "Gather 1,000 Crystals"},
		{"id": "build_research_10", "desc": "Build 10 Research Bots"},
		{"id": "purchase_research_1", "desc": "Purchase 'Efficient Research I'"},
		{"id": "purchase_tier_3_upg", "desc": "Purchase any Tier 3 upgrade"},
		
		# --- Tier 5: Mastery ---
		{"id": "gather_metals_1m", "desc": "Gather 1,000,000 Metals"},
		{"id": "gen_research_10k", "desc": "Generate 10,000 Research Points"},
		{"id": "discover_asteroids_5", "desc": "Have 5 asteroids in queue"},
		{"id": "all_upgrades_t1", "desc": "Purchase all Tier 1 upgrades"},
	]

	# Make sure we have enough nodes for our definitions
	if milestone_nodes.size() < milestone_definitions.size():
		printerr("Not enough milestone nodes in the scene for all definitions!")
		return

	for i in range(milestone_definitions.size()):
		var definition = milestone_definitions[i]
		var nodes = milestone_nodes[i]
		
		milestones[definition.id] = {
			"description": definition.desc,
			"container_node": nodes.container,
			"label_node": nodes.label,
			"checkbox_node": nodes.checkbox,
			"check_function": func(): return GameManager.player_data.is_milestone_condition_met(definition.id)
		}

# Checks for any newly completed milestones whenever player data is updated.
func check_milestones() -> void:
	if not GameManager.player_data: return
	
	var hide_when_completed = hide_completed_checkbox.button_pressed
	
	for id in milestones:
		# Skip if already completed
		if GameManager.player_data.has_milestone(id):
			continue
		
		# Check if the condition is now met
		var milestone = milestones[id]
		if milestone.check_function.call():
			GameManager.complete_milestone(id)
			# If the hide checkbox is active, trigger the completion animation.
			if hide_when_completed:
				_animate_milestone_completion(id)
	
	# After checking, update the UI to reflect any changes.
	update_milestone_ui()

# Sets the text and checkbox state for all milestones based on current player data.
func update_milestone_ui(_is_toggled: bool = false) -> void:
	if not GameManager.player_data: return
	
	@warning_ignore("unused_variable")
	var all_completed = true
	var hide_completed = hide_completed_checkbox.button_pressed
	
	for id in milestones:
		# If a milestone is currently animating, skip its UI update to avoid conflicts.
		if id in animating_milestones:
			continue
			
		var milestone = milestones[id]
		milestone.label_node.text = milestone.description
		
		var is_completed = GameManager.player_data.has_milestone(id)
		milestone.checkbox_node.button_pressed = is_completed
		
		if is_completed:
			milestone.container_node.visible = not hide_completed
			# Ensure it's fully opaque if we are showing it.
			if not hide_completed:
				milestone.container_node.modulate.a = 1.0
		else:
			all_completed = false
			milestone.container_node.visible = true
			milestone.container_node.modulate.a = 1.0
			
	# This is where you would enable the FTL jump button.
	# if ftl_jump_button:
	# 	ftl_jump_button.disabled = not all_completed

# --- Helper functions for complex milestone checks ---

func _animate_milestone_completion(milestone_id: String) -> void:
	if not milestones.has(milestone_id): return
	
	var milestone_data = milestones[milestone_id]
	var container = milestone_data.container_node
	
	# Add to the list to prevent update_milestone_ui from interfering.
	animating_milestones.append(milestone_id)
	
	# Create a sequential tween for the animation.
	var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	# 1. Flash to yellow by tweening self_modulate
	tween.tween_property(container, "self_modulate", Color.YELLOW, 0.2)
	# 2. Flash back to white
	tween.tween_property(container, "self_modulate", Color.WHITE, 0.3)
	# 3. Fade out over 2 seconds by tweening modulate alpha
	tween.tween_property(container, "modulate:a", 0.0, 2.0)
	
	# 4. After the tween finishes, hide the node and remove it from the animating list.
	tween.tween_callback(func(): container.visible = false; animating_milestones.erase(milestone_id))
