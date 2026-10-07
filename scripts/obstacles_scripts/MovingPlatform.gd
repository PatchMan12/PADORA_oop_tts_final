extends AnimatableBody2D
# Attach to your platform's root node. Change its type to AnimatableBody2D
# if it's currently StaticBody2D, so it correctly carries the player.

@export var move_offset: Vector2 = Vector2(150, 0)   # how far and which direction it travels
@export var speed: float = 50.0                       # pixels per second

var point_a: Vector2
var point_b: Vector2
var moving_to_b: bool = true

func _ready() -> void:
	point_a = global_position
	point_b = point_a + move_offset

func _physics_process(delta: float) -> void:
	var target: Vector2 = point_b if moving_to_b else point_a
	var direction: Vector2 = target - global_position
	var distance: float = direction.length()

	if distance < 2.0:
		moving_to_b = not moving_to_b
	else:
		global_position += direction.normalized() * speed * delta
