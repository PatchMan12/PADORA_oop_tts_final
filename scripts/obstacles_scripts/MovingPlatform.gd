extends AnimatableBody2D

@export var move_offset: Vector2 = Vector2(150, 0)   # how far and which direction it travels
@export var speed: float = 50.0                       # pixels per second

var point_a: Vector2 #The starting position
var point_b: Vector2 # The end position, calculated as point at move_offset
var moving_to_b: bool = true #True while the platform is heading toward point B, false while heading back to point A.

func _ready() -> void: #runs once when the scene leads. Saves the p;atfprm's starting position as point_a. then calculates point_b by adding the offset.
	point_a = global_position
	point_b = point_a + move_offset

func _physics_process(delta: float) -> void: #runs every physics fram and handles the movement.
	var target: Vector2 = point_b if moving_to_b else point_a #pickts the current target: point B if moving_to_b is true, else point A
	var direction: Vector2 = target - global_position #calculates the direction and the distance so that target.
	var distance: float = direction.length()

	if distance < 2.0:
		moving_to_b = not moving_to_b
	else:
		global_position += direction.normalized() * speed * delta #move toward the target
