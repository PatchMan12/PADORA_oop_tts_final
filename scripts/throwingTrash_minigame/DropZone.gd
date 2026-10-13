class_name DropZone 
extends Area2D
#acts as an invisble target that answers one question "Was the trash dropped?"
@export var category: PickupManager.Category = PickupManager.Category.RECYCLABLE
#which type of trash this bin accepts (Recyclable, Biodegradable, General, or Hazardous)
#set it in the inspector to match the bin's picture

var active: bool = true   # true if this bin is in the use for the current trash can, false if it should be ignored SortingGeme turns of the bins that the current can doesn't accept

func _ready() -> void: # runs once when the scene loads
	add_to_group("drop_zone") #tags this node so SortingGame can find every drop zone with one search
	
	monitoring = false #monitoring = false and monitorable = false turn off Godot's physics detection. This zone only needs a simple checks so it doesn't need physics
	monitorable = false


func contains_point(canvas_point: Vector2) -> bool: #returns true if the given point (the mouse position when the trash was dropped) is inside this zone.
	if not active: #if the zone isn't active, it returns true if the given point (the mouse position when the trash was dropped) is inside the zone
		return false

	for child in get_children(): #loops through the node's children looking for a CollisionShape2D that is enabled and has a shape
		if child is CollisionShape2D and not child.disabled and child.shape != null:
			var local: Vector2 = child.to_local(canvas_point) #converts the mosuse position into shape's own coordinate system. so math works even if the zone is moved or positioned anywhere
			var s: Shape2D = child.shape #builds a matching Rect2 Centered on the sha[e amd checks whether the point falls inside.
			if s is RectangleShape2D:
				if Rect2(-s.size / 2.0, s.size).has_point(local):
					return true
			elif s is CircleShape2D: #if cirlce chekcs the points distance
				if local.length() <= s.radius:
					return true
	return false #false if none is matched
