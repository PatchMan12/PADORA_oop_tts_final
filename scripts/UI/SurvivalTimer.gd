extends Label
# Attach to a Label placed top-left (below PickupUI). Now a COUNTDOWN timer.
# Resets automatically on scene reload, since this Label is recreated fresh each time.

signal time_up

@export var time_limit: float = 120.0   # seconds on the clock, adjust to taste

var time_left: float = 0.0
var finished: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS   # keeps counting during the sorting overlay's pause
	time_left = time_limit
	_update_text()

func _process(delta: float) -> void:
	if finished:
		return

	time_left -= delta
	if time_left <= 0.0:
		time_left = 0.0
		finished = true
		time_up.emit()

	_update_text()

func _update_text() -> void:
	var minutes := int(time_left) / 60
	var seconds := int(time_left) % 60
	text = "Time: %02d:%02d" % [minutes, seconds]

# Called by DeathScreen so the countdown actually stops (not just visually hidden)
func stop_timer() -> void:
	finished = true
