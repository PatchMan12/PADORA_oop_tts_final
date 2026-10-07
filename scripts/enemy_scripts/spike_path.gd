extends Path2D

@export var move_speed: float = 100.0
@export var ping_pong: bool = false  # Toggle in Inspector: ON = Ping-Pong, OFF = Continuous Loop

@onready var path_follow: PathFollow2D = $PathFollow2D

var direction: int = 1

func _ready() -> void:
	if curve:
		curve = curve.duplicate()
	if path_follow:
		# Loop=true makes PathFollow2D silently wrap progress past the curve's end,
		# which breaks the ping-pong boundary check below. Only wrap when NOT ping-ponging.
		path_follow.loop = not ping_pong

func _process(delta: float) -> void:
	if path_follow == null:
		return

	# Move forward or backward based on current direction
	path_follow.progress += move_speed * delta * direction

	if ping_pong:
		# Ping-Pong logic: reverse direction when reaching either end
		if path_follow.progress_ratio >= 1.0:
			path_follow.progress_ratio = 1.0
			direction = -1
		elif path_follow.progress_ratio <= 0.0:
			path_follow.progress_ratio = 0.0
			direction = 1
