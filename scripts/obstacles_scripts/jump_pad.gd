extends Node2D
# Attach to the root of jump_pad. Moves back and forth AND launches the player on touch.

@export var jump_velocity: float = -1000.0            # more negative = higher jump
@export var move_offset: Vector2 = Vector2(150, 0)     # how far and which direction it travels
@export var speed: float = 50.0                        # pixels per second

var point_a: Vector2
var point_b: Vector2
var moving_to_b := true

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

func _on_area_2d_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	body.velocity.y = jump_velocity
