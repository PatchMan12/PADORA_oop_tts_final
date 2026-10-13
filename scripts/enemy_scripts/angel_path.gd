extends Path2D
#script goes on Path2d that has a Pathfollow2d
@export var move_speed: float = 100.0 #how fast
@export var ping_pong: bool = true #ping pong = loop the path

@onready var path_follow: PathFollow2D = $PathFollow2D #the node which is the "rider" slides along the path
@onready var sprite: AnimatedSprite2D = $PathFollow2D/angel_guard/AnimatedSprite2D #image

var direction: int = 1 #1 forward -1 = backward
var last_position: Vector2 #the guard's position on the previous frame

func _ready() -> void: #runs once when the scene loads
	if path_follow:
		last_position = path_follow.global_position
		
		path_follow.loop = not ping_pong

func _process(delta: float) -> void: #runs every frame
	if path_follow == null:
		return

	path_follow.progress += move_speed * delta * direction #moves the guard along the path

	if ping_pong: #checks how far along the path guard is
		if path_follow.progress_ratio >= 1.0:
			path_follow.progress_ratio = 1.0
			direction = -1
		elif path_follow.progress_ratio <= 0.0:
			path_follow.progress_ratio = 0.0
			direction = 1

	var move_direction = path_follow.global_position.x - last_position.x #flips the image right false left true
	if sprite:
		if move_direction > 0.01:
			sprite.flip_h = false
		elif move_direction < -0.01:
			sprite.flip_h = true

	last_position = path_follow.global_position
