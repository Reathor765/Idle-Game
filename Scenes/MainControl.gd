extends Control

@onready var save_button: Button = $SaveButton

func _ready() -> void:
	save_button.pressed.connect(_on_save_button_pressed)

func _on_save_button_pressed() -> void:
	print("Save button pressed!")
	GameManager.save_game()
