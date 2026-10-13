extends Node2D


@export var jump_velocity: float = -1000.0            # more negative = higher jump
@export var move_offset: Vector2 = Vector2(150, 0)     # how far and which direction it travels
@export var speed: float = 50.0                        # pixels per second

var point_a: Vector2 #starting position
var point_b: Vector2 # the end position
var moving_to_b := true # true while the pad is heading toward point B, false while heading back to point A.

func _ready() -> void: #runs once whne the scene leads. It saves the pad's starting position as point_a, then calculates point_b by adding the offset
	point_a = global_position
	point_b = point_a + move_offset

func _physics_process(delta: float) -> void: #runs every physics frame and handles the movement
	var target: Vector2 = point_b if moving_to_b else point_a #picks the current target: point B if move_to_b, otherwise point point a
	var direction: Vector2 = target - global_position #calculates the direcction and distance to the target.
	var distance: float = direction.length() 

	if distance < 2.0: #if the pad is within 2 pixels of the target, it flips moving_to_b, so the pad turns around.
		moving_to_b = not moving_to_b
	else: #otherwise it moves toward that target by speed * delta which keeps the speed the same regardless of frame rate
		global_position += direction.normalized() * speed * delta

func _on_area_2d_body_entered(body: Node2D) -> void: #runs when anything enters the pad's Area2D
	if not body.is_in_group("player"): #ignores anything that isn't the player example tile map
		return
	body.velocity.y = jump_velocity  #Jump.velocity sets the player's vertical speed to the launch value, which sends the player upward/
