extends CharacterBody2D


const SPEED = 130.0 #How fast the player walks left and right
const JUMP_VELOCITY = -300.0#How strongly the player jumps (negative means upward)

const DASH_SPEED = 400.0       #How strongly the player moves during dash
const DASH_DURATION = 0.2      # how long the dash lasts, in seconds
const DASH_COOLDOWN = 0.5      # time before you can dash again

var is_dashing := false
var dash_timer := 0.0
var dash_cooldown_timer := 0.0
var last_direction := 1        # remembers which way to dash/face (1 = right, -1 = left)

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D


func _physics_process(delta: float) -> void:
	if dash_cooldown_timer > 0:
		dash_cooldown_timer -= delta

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction != 0:
		last_direction = direction   # keep facing/last-moved direction, even after you let go

	if is_dashing:
		# While dashing, the dash overrides normal movement and gravity
		dash_timer -= delta
		velocity.x = last_direction * DASH_SPEED
		velocity.y = 0
		if dash_timer <= 0:
			is_dashing = false
	else:
		# Add the gravity.
		if not is_on_floor():
			velocity += get_gravity() * delta

		# Handle jump.
		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			velocity.y = JUMP_VELOCITY

		# Handle dash: must already be moving (direction != 0) and off cooldown
		if Input.is_action_just_pressed("dash") and dash_cooldown_timer <= 0 and direction != 0:
			is_dashing = true
			dash_timer = DASH_DURATION
			dash_cooldown_timer = DASH_COOLDOWN

		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

	_update_animation()


func _update_animation() -> void:
	# Flip the sprite to face the last direction moved/dashed, sprites face right by default
	sprite.flip_h = last_direction < 0

	if not is_on_floor():
		sprite.play("jump")
	elif abs(velocity.x) > 1.0:
		sprite.play("move")
	else:
		sprite.play("idle")
