class_name DraggableTrash #gives a global name
extends TextureRect
#This script is a trash item you can drag with the mouse.

signal dropped(trash: DraggableTrash) #fires when the player lets go of the item.

var item_id: String = "" #which kind of trash this is. Set by SortingGame when it creates the item
var category: int = 0 #Which bin type it belongs to. Also set by SortingGame
var home_position: Vector2 = Vector2.ZERO #Where the item started, so it can go back if dropped in the wrong place
var dragging: bool = false #true while the player is holding with the mouse
var grab_offset: Vector2 = Vector2.ZERO #gap

func _ready() -> void: #runs once when the item is creted. It makes the item respond to mouse clicks
	mouse_filter = Control.MOUSE_FILTER_STOP
	home_position = position

func _gui_input(event: InputEvent) -> void: #handles mouse clicks on this item
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			dragging = true
			z_index = 10   
			grab_offset = get_global_mouse_position() - global_position
		elif dragging:
			dragging = false
			z_index = 0
			dropped.emit(self)

func _process(_delta: float) -> void: #runs every fram. While dragging is true, it moves the item to follow the mouse, keeping the grab offset it moves smoothly.
	if dragging:
		global_position = get_global_mouse_position() - grab_offset

func return_home() -> void: #is called by SortingGame when the item is dropped outside every bin
	var tween := create_tween()
	tween.tween_property(self, "position", home_position, 0.15)
