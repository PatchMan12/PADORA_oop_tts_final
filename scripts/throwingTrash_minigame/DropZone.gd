class_name DropZone
extends Area2D
# Attach to each Area2D you place over a bin in your big sorting sprite.
# Give it a CollisionShape2D child (RectangleShape2D or CircleShape2D)
# covering the bin, and set Category to match that bin.

@export var category: PickupManager.Category = PickupManager.Category.RECYCLABLE

var active: bool = true   # SortingGame turns off the bins this trash can doesn't accept

func _ready() -> void:
	add_to_group("drop_zone")
	# Pure hit-testing: no physics interaction with the level underneath
	monitoring = false
	monitorable = false

# canvas_point = mouse position in the CanvasLayer's coordinates
func contains_point(canvas_point: Vector2) -> bool:
	if not active:
		return false

	for child in get_children():
		if child is CollisionShape2D and not child.disabled and child.shape != null:
			var local: Vector2 = child.to_local(canvas_point)
			var s: Shape2D = child.shape
			if s is RectangleShape2D:
				if Rect2(-s.size / 2.0, s.size).has_point(local):
					return true
			elif s is CircleShape2D:
				if local.length() <= s.radius:
					return true
	return false
