extends CanvasLayer
#Script goes on the root CanvasLayer and opens when the player presses E at a trash can
signal closed #Announces "the minigame has closed" TrashCan.gd listens for it so the "Press E" prompt can come back

@export var points_correct: int = 10 #points added for a correct bin (default 1-)
@export var points_wrong: int = 5 #points deducted for a wrong bin (default +5)
@export var item_size: Vector2 = Vector2(72, 72) #The onscreen size of each draggable trash item
@export var item_spacing: Vector2 = Vector2(96, 96) #The gap between items in the grid layout
@export var columns: int = 6 # How many items fit per row before wrapping to the next row.

var _cat_a: int = -1 #The two trash categories this can accepts (set by trash can)
var _cat_b: int = -1
var _feedback_tween: Tween #Holds the fade animation of the feedback text, so a new one can cancel an old one

@onready var trash_area: Control = $TrashArea #The TrashArea node where trash items appear
@onready var feedback: Label = $FeedbackLabel #The FeedbackLabel showing "Correct +10" or "Wrong bin! -5"
@onready var done_button: Button = $DoneButton #The done button

#Is called by the trash can before the minigame appears. It stores which two categories this can accepts
func setup(cat_a: int, cat_b: int) -> void:
	_cat_a = cat_a
	_cat_b = cat_b

func _ready() -> void: #runs when the minigame opens
	layer = 10  #draws it above the HUD.
	process_mode = Node.PROCESS_MODE_ALWAYS   #Keeps it working while the game is paused
	get_tree().paused = true #True freezes the level behind it
	add_to_group("sorting_game") #lets LevelManager find it and close it if time runs out.

	done_button.pressed.connect(_close) #It connects the Done button and clears the feedback text
	feedback.text = ""

	# Loops throught every drop zone and turns only the two that match this can's categories 
	for zone in get_tree().get_nodes_in_group("drop_zone"):
		zone.active = (zone.category == _cat_a or zone.category == _cat_b)

	# Asks PickupManager for hte player's items in those two categories, then spawns one draggable item per unit carried. If there are none it shows "You have nothing to throw in these bins"
	var index := 0
	for item in PickupManager.get_items_in_categories([_cat_a, _cat_b]):
		for n in range(item["count"]):
			_spawn_trash(item, index)
			index += 1

	if index == 0:
		feedback.text = "You have nothing to throw in these bins."
#creates ibe draggable trash item in code
func _spawn_trash(item: Dictionary, index: int) -> void:
	var t := DraggableTrash.new() #Sets item ID, category, icon, and size
	t.item_id = item["id"]
	t.category = item["category"]
	t.texture = item["icon"]
	t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	t.custom_minimum_size = item_size
	t.size = item_size
	t.position = Vector2(index % columns, floori(index / float(columns))) * item_spacing #calculates its grid position from index and columns (index % columns for the column, index/ columns for the row), multiplied by item_spacing
	t.dropped.connect(_on_trash_dropped) #connects the item's dropped singal to _on_trash_dropped, then adds it to TrashArea
	trash_area.add_child(t)

func _on_trash_dropped(trash: DraggableTrash) -> void: #runs when the player releases a dragged item
	var mouse := trash.get_global_mouse_position()

	for zone in get_tree().get_nodes_in_group("drop_zone"):#loops through the drop scene and asks each one contains-point(mouse)
		if zone.contains_point(mouse):#if a zone says yes, the throw is resolved
			_resolve_throw(trash, zone)
			return

	trash.return_home()   # if non do, the items snaps back to its original spot

func _resolve_throw(trash: DraggableTrash, zone: DropZone) -> void: #decides the result of athrow.
	if trash.category == zone.category: #if the item;s category matches the bin's category: adds point_correct and shows green "Correct! +10"
		ScoreManager.add_score(points_correct)
		_show_feedback("Correct! +%d" % points_correct, Color.LIME_GREEN)
	else:  #else deducts points_wrong and shows red "Wrong bin! -5"
		ScoreManager.add_score(-points_wrong)
		_show_feedback("Wrong bin! -%d" % points_wrong, Color.TOMATO)

	PickupManager.remove_one(trash.item_id)   # HUD entry drops by 1 (disappears at 0)
	trash.queue_free()

func _show_feedback(text: String, color: Color) -> void: # shows the result message, it cancels any older fade, sets the text and color, waits half a second then fades the message out over 0.6 seconds using a tween
	if _feedback_tween:
		_feedback_tween.kill()
	feedback.text = text
	feedback.modulate = color
	_feedback_tween = create_tween()
	_feedback_tween.tween_interval(0.5)
	_feedback_tween.tween_property(feedback, "modulate:a", 0.0, 0.6)

func _unhandled_input(event: InputEvent) -> void: #lets the player press ESC to close the minigame
	if event.is_action_pressed("ui_cancel"):     # Esc also closes
		_close()

func _close() -> void: #closes the minigame
	get_tree().paused = false
	closed.emit()
	queue_free()

# Called by LevelManager when time runs out or the player wins while this is open
func force_close() -> void:
	_close()
