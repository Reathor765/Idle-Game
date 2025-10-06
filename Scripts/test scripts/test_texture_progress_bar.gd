extends TextureProgressBar


@export var progress_offset: Vector2 = Vector2.ZERO
@export var progress_size: Vector2 = Vector2(100, 20)
@export var progress_opacity: float = 1.0

var bar_value: float = 0.0


func _ready() -> void:
	TickManager.tick.connect(_on_tick)

func _on_tick(_delta: float) -> void:
	# Reset the bar value when a tick occurs
	bar_value = 0.0

func _process(delta: float) -> void:
	# Increment the bar value based on delta and the tick interval
	bar_value += delta / TickManager.get_tick_interval()
	value = bar_value * 100 # Assuming ProgressBar value is 0-100

	# Apply the exported variables
	texture_progress_offset = progress_offset
	size = progress_size
	self_modulate.a = progress_opacity
