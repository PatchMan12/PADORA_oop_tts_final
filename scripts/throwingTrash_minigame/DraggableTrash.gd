class_name DraggableTrash
extends TextureRect


signal dropped(trash: DraggableTrash)

var item_id: String = ""
var category: int = 0
var home_position: Vector2 = Vector2.ZERO
var dragging: bool = false
var grab_offset: Vector2 = Vector2.ZERO

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	home_position = position

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			dragging = true
			z_index = 10   # draw above other items while dragging
			grab_offset = get_global_mouse_position() - global_position
		elif dragging:
			dragging = false
			z_index = 0
			dropped.emit(self)

func _process(_delta: float) -> void:
	if dragging:
		global_position = get_global_mouse_position() - grab_offset

func return_home() -> void:
	var tween := create_tween()
	tween.tween_property(self, "position", home_position, 0.15)
