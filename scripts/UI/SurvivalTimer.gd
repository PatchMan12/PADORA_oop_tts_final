extends Label
# timer display format

signal time_up #announce "the timer reached zero"

@export var time_limit: float = 120.0   # seconds the player starts

var time_left: float = 0.0 #seconds remaining
var finished: bool = false #true once the timer has hit zero

func _ready() -> void: #runs once when the scene loads
	process_mode = Node.PROCESS_MODE_ALWAYS   #keeps the timer counting even when the game is paused
	time_left = time_limit
	_update_text() 

func _process(delta: float) -> void: #runs every frame
	if finished: #stops the game and finishes
		return

	time_left -= delta #subtacts (the time since the last frame)
	if time_left <= 0.0:
		time_left = 0.0
		finished = true
		time_up.emit()

	_update_text()

func _update_text() -> void: #updates the time text and enforces the time format
	var minutes := int(time_left) / 60
	var seconds := int(time_left) % 60
	text = "Time: %02d:%02d" % [minutes, seconds]

# stops the time = finished
func stop_timer() -> void:
	finished = true
