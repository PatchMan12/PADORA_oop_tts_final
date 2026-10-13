extends Area2D
# Script goes on the Area2D inside each trash can scene. It shows a press "E" to interact

@export var sorting_scene: PackedScene  #The sorting minigame scene
@export var category_a: PickupManager.Category = PickupManager.Category.RECYCLABLE #The two trash categores this can acceots (for example, recyclable and General for can 1)
@export var category_b: PickupManager.Category = PickupManager.Category.GENERAL
@export var prompt_text: String = "Press E to interact" #the text shown above the can
@export var prompt_offset: Vector2 = Vector2(-50, -70)  # where the prompt floats relative to this Area2D

var player_inside: bool = false #true while player is standing inside the can's area 
var game_open: bool = false #true while sorting
var prompt: Label #the label showing the prompt text. Its created in code, so you dont need to add it to scene

func _ready() -> void: #runs once when the scene loads
	
	prompt = Label.new() #creates the prompt labels sets it to text
	prompt.text = prompt_text
	prompt.position = prompt_offset
	prompt.visible = false
	add_child(prompt)

	# connects the area's body-entered and body-exited signals to the funnctions below. The is_connected checks prevent an "already connected"
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	if not body_exited.is_connected(_on_body_exited):
		body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node) -> void: #runs when something enters the area
	if body.is_in_group("player"):
		player_inside = true
		prompt.visible = not game_open

func _on_body_exited(body: Node) -> void: #runs when something leaves the area
	if body.is_in_group("player"):
		player_inside = false
		prompt.visible = false

func _unhandled_input(event: InputEvent) -> void: #runs on key presses
	if player_inside and not game_open and event.is_action_pressed("interact"):
		_open_sorting()

func _open_sorting() -> void: #opens the minigame
	if sorting_scene == null: #if no sorting scene was assigned it prints a warnign and stops
		push_warning("TrashCan: no sorting_scene assigned in the Inspector.")
		return

	var game = sorting_scene.instantiate() #creates a copy of a minigame scene
	game.setup(category_a, category_b)
	game.closed.connect(_on_sorting_closed)
	get_tree().current_scene.add_child(game)   # SortingGame pauses the tree itself

	game_open = true
	prompt.visible = false

func _on_sorting_closed() -> void: #runs when the minigame closes. it sets game open=false and shows the prompt again if the player is still standing next to the can.
	game_open = false
	prompt.visible = player_inside
