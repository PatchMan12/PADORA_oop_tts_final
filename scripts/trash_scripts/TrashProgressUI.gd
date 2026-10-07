extends Label
# Attach to a Label in your HUD. Counts how many trash scenes are placed
# under your "trash" container node at the start, and how many the player
# has ever picked up (from PickupManager.total_ever_collected).

@export var trash_container_path: NodePath   # drag your "trash" node here

var total: int = 0

func _ready() -> void:
	var container := get_node(trash_container_path)
	total = container.get_child_count()

	PickupManager.progress_updated.connect(_update)
	_update(PickupManager.total_ever_collected)

func _update(total_ever_collected: int) -> void:
	text = "Collected: %d/%d" % [min(total_ever_collected, total), total]
