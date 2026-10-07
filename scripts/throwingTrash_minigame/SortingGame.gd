extends CanvasLayer
# Root of SortingGame.tscn. Required nodes (names must match exactly):
#   TrashArea     (Control)  where the draggable trash spawns
#   FeedbackLabel (Label)    shows "Correct! +10" / "Wrong bin! -5"
#   DoneButton    (Button)   closes the screen
# Plus your big background Sprite2D and one DropZone (Area2D) per bin.

signal closed

@export var points_correct: int = 10
@export var points_wrong: int = 5
@export var item_size: Vector2 = Vector2(72, 72)
@export var item_spacing: Vector2 = Vector2(96, 96)
@export var columns: int = 6

var _cat_a: int = -1
var _cat_b: int = -1
var _feedback_tween: Tween

@onready var trash_area: Control = $TrashArea
@onready var feedback: Label = $FeedbackLabel
@onready var done_button: Button = $DoneButton

# Called by the trash can BEFORE this node is added to the scene
func setup(cat_a: int, cat_b: int) -> void:
	_cat_a = cat_a
	_cat_b = cat_b

func _ready() -> void:
	layer = 10                                    # draw above the HUD
	process_mode = Node.PROCESS_MODE_ALWAYS       # keep working while the game is paused
	get_tree().paused = true
	add_to_group("sorting_game")

	done_button.pressed.connect(_close)
	feedback.text = ""

	# Only the two bins this trash can accepts are active drop targets
	for zone in get_tree().get_nodes_in_group("drop_zone"):
		zone.active = (zone.category == _cat_a or zone.category == _cat_b)

	# One draggable per unit of trash the player is carrying for these bins
	var index := 0
	for item in PickupManager.get_items_in_categories([_cat_a, _cat_b]):
		for n in range(item["count"]):
			_spawn_trash(item, index)
			index += 1

	if index == 0:
		feedback.text = "You have nothing to throw in these bins."

func _spawn_trash(item: Dictionary, index: int) -> void:
	var t := DraggableTrash.new()
	t.item_id = item["id"]
	t.category = item["category"]
	t.texture = item["icon"]
	t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	t.custom_minimum_size = item_size
	t.size = item_size
	t.position = Vector2(index % columns, floori(index / float(columns))) * item_spacing
	t.dropped.connect(_on_trash_dropped)
	trash_area.add_child(t)

func _on_trash_dropped(trash: DraggableTrash) -> void:
	var mouse := trash.get_global_mouse_position()

	for zone in get_tree().get_nodes_in_group("drop_zone"):
		if zone.contains_point(mouse):
			_resolve_throw(trash, zone)
			return

	trash.return_home()   # dropped outside any zone -> snap back

func _resolve_throw(trash: DraggableTrash, zone: DropZone) -> void:
	if trash.category == zone.category:
		ScoreManager.add_score(points_correct)
		_show_feedback("Correct! +%d" % points_correct, Color.LIME_GREEN)
	else:
		ScoreManager.add_score(-points_wrong)
		_show_feedback("Wrong bin! -%d" % points_wrong, Color.TOMATO)

	PickupManager.remove_one(trash.item_id)   # HUD entry drops by 1 (disappears at 0)
	trash.queue_free()

func _show_feedback(text: String, color: Color) -> void:
	if _feedback_tween:
		_feedback_tween.kill()
	feedback.text = text
	feedback.modulate = color
	_feedback_tween = create_tween()
	_feedback_tween.tween_interval(0.5)
	_feedback_tween.tween_property(feedback, "modulate:a", 0.0, 0.6)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):     # Esc also closes
		_close()

func _close() -> void:
	get_tree().paused = false
	closed.emit()
	queue_free()

# Called by LevelManager when time runs out or the player wins while this is open
func force_close() -> void:
	_close()
