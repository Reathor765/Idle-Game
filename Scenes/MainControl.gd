extends Control

@onready var save_button: Button = $SaveButton
@onready var exit_game: Button = $ExitGame

func _ready() -> void:
	save_button.pressed.connect(_on_save_button_pressed)
	exit_game.pressed.connect(_on_exit_game_pressed)

func _on_save_button_pressed() -> void:
	print("Save button pressed!")
	GameManager.save_game()
	SaveManager.save_game(GameManager.player_data.scout_findings)

func _on_exit_game_pressed() -> void:
	_on_save_button_pressed()
	get_tree().quit()
