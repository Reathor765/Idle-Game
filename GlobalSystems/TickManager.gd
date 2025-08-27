extends Node
# This autoload will manage the global tick, and keep track of related stats

# Emitted on every game tick. The delta is the time since the last tick.
# Other systems (like resource generators) should connect to this signal.
signal tick(delta: float)

# The base time between ticks, in seconds. This can be modified by upgrades.
const BASE_TICK_INTERVAL: float = 10.0
# The minimum time between ticks, to prevent performance issues at high upgrade levels.
const MIN_TICK_INTERVAL: float = 1.0

var _tick_timer: Timer


func _ready() -> void:
	_tick_timer = Timer.new()
	_tick_timer.name = "TickTimer"
	_tick_timer.timeout.connect(_on_tick_timer_timeout)
	add_child(_tick_timer)

	# Connect to the GameManager's signal to know when to update our tick speed.
	# This is crucial for when the player buys an upgrade that affects tick speed.
	if GameManager:
		GameManager.player_data_updated.connect(_update_tick_interval)
		# Perform an initial update in case the game is already loaded.
		_update_tick_interval()

	_tick_timer.start()


func _on_tick_timer_timeout() -> void:
	# When the timer finishes, we emit our global tick signal.
	# We pass the duration of the tick (the timer's wait_time) as the delta.
	tick.emit(_tick_timer.wait_time)


func _update_tick_interval() -> void:
	"""
	Calculates and applies the new tick interval based on player progression.
	This is called when the game loads and whenever player data is updated.
	"""
	var new_interval : float = _calculate_tick_interval()
	if not is_equal_approx(new_interval, _tick_timer.wait_time):
		_tick_timer.wait_time = new_interval
		print("Tick interval updated to: %s seconds" % new_interval)


func _calculate_tick_interval() -> float:
	"""Determines the tick interval based on global upgrades."""
	if not GameManager.player_data:
		return BASE_TICK_INTERVAL

	var tick_speed_level: int = GameManager.player_data.global_upgrades.get("tick_speed", 0)
	var new_interval := BASE_TICK_INTERVAL / pow(1.1, tick_speed_level)

	return max(new_interval, MIN_TICK_INTERVAL)
