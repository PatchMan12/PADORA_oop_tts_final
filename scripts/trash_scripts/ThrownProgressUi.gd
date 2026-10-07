extends Label
# Attach to a Label in your HUD, next to your collected counter.
# Shows how many trash items have been thrown into bins, out of the total in the level.

@export var trash_container_path: NodePath   # same "trash" node you used for TrashProgressUI

var total: int = 0

func _ready() -> void:
	var container := get_node(trash_container_path)
	total = container.get_child_count()

	PickupManager.thrown_updated.connect(_update)
	_update(PickupManager.total_thrown)

func _update(total_thrown: int) -> void:
	text = "Thrown: %d/%d" % [min(total_thrown, total), total]
