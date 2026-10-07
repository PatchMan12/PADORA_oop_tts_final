extends Path2D

@export var move_speed: float = 100.0
@export var ping_pong: bool = true

@onready var path_follow: PathFollow2D = $PathFollow2D
@onready var sprite: AnimatedSprite2D = $PathFollow2D/angel_guard/AnimatedSprite2D

var direction: int = 1
var last_position: Vector2

func _ready() -> void:
	if path_follow:
		last_position = path_follow.global_position
		# Loop=true makes progress silently wrap past the curve's end, which breaks
		# the ping-pong boundary check below. Only let it wrap when NOT ping-ponging.
		path_follow.loop = not ping_pong

func _process(delta: float) -> void:
	if path_follow == null:
		return

	path_follow.progress += move_speed * delta * direction

	if ping_pong:
		if path_follow.progress_ratio >= 1.0:
			path_follow.progress_ratio = 1.0
			direction = -1
		elif path_follow.progress_ratio <= 0.0:
			path_follow.progress_ratio = 0.0
			direction = 1

	var move_direction = path_follow.global_position.x - last_position.x
	if sprite:
		if move_direction > 0.01:
			sprite.flip_h = false
		elif move_direction < -0.01:
			sprite.flip_h = true

	last_position = path_follow.global_position
