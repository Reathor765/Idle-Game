extends ProgressBar

var bar_value: float = 0.0


func _ready() -> void:
	TickManager.tick.connect(_on_tick)

func _on_tick(_delta: float) -> void:
	# Reset the bar value when a tick occurs
	bar_value = 0.0

func _process(delta: float) -> void:
	# Increment the bar value based on delta and the tick interval
	bar_value += delta / TickManager._tick_timer.wait_time
	value = bar_value * 100 # Assuming ProgressBar value is 0-100
