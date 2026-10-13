extends Path2D
#script goes on a Path2d that has a Pathfollow2d
@export var move_speed: float = 100.0#How fast the guard moves along the path in pixels per second
@export var ping_pong: bool = true #If true, the guard walks to the end, then turns around and walks back. If false it keep moving in one direction and loops

@onready var path_follow: PathFollow2D = $PathFollow2D #The PathFollow2D node, which is the "rider" that slides along the path
@onready var sprite: AnimatedSprite2D = $PathFollow2D/guard_enemy/AnimatedSprite2D #The guard's AnimatedSprite2d

var direction: int = 1 #1 means moving forward along the path, -1 means moving backward
var last_position: Vector2 #The guard's position on the previous frame, used to work out when way it is moving

func _ready() -> void: #runs once when the scene loads. It saves the guard's starting position as last_position
	if path_follow:
		last_position = path_follow.global_position

func _process(delta: float) -> void: #runs every frame
	if path_follow == null:
		return
		
	path_follow.progress += move_speed * delta * direction #move pusehes the guard along the path
	
	if ping_pong: #if ping_pong is on, it checks how far along the path guard is
		if path_follow.progress_ratio >= 1.0:
			direction = -1
		elif path_follow.progress_ratio <= 0.0:
			direction = 1
			
	var move_direction = path_follow.global_position.x - last_position.x #flips images right false left true
	if sprite:
		if move_direction > 0.01:
			sprite.flip_h = false
		elif move_direction < -0.01:
			sprite.flip_h = true
			
	last_position = path_follow.global_position
