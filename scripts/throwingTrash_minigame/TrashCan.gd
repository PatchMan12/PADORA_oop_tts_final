extends Area2D
# Attach to the Area2D inside each trash can scene.
# Can 1: Category A = Recyclable, Category B = General
# Can 2: Category A = Hazardous,  Category B = Biodegradable

@export var sorting_scene: PackedScene                       # drag SortingGame.tscn here
@export var category_a: PickupManager.Category = PickupManager.Category.RECYCLABLE
@export var category_b: PickupManager.Category = PickupManager.Category.GENERAL
@export var prompt_text: String = "Press E to interact"
@export var prompt_offset: Vector2 = Vector2(-50, -70)      # where the prompt floats relative to this Area2D

var player_inside: bool = false
var game_open: bool = false
var prompt: Label

func _ready() -> void:
	# Prompt label is created in code, so no extra node setup is needed
	prompt = Label.new()
	prompt.text = prompt_text
	prompt.position = prompt_offset
	prompt.visible = false
	add_child(prompt)

	# is_connected checks avoid the "already connected" error if you also connected in the editor
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	if not body_exited.is_connected(_on_body_exited):
		body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		player_inside = true
		prompt.visible = not game_open

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		player_inside = false
		prompt.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if player_inside and not game_open and event.is_action_pressed("interact"):
		_open_sorting()

func _open_sorting() -> void:
	if sorting_scene == null:
		push_warning("TrashCan: no sorting_scene assigned in the Inspector.")
		return

	var game = sorting_scene.instantiate()
	game.setup(category_a, category_b)
	game.closed.connect(_on_sorting_closed)
	get_tree().current_scene.add_child(game)   # SortingGame pauses the tree itself

	game_open = true
	prompt.visible = false

func _on_sorting_closed() -> void:
	game_open = false
	prompt.visible = player_inside
