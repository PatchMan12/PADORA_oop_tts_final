extends Label

@export var trash_container_path: NodePath   # path

var total: int = 0 #total number of trash

func _ready() -> void:
	var container := get_node(trash_container_path) #path of the that tells the program that the player throws something
	total = container.get_child_count()

	PickupManager.thrown_updated.connect(_update) #update when thrown
	_update(PickupManager.total_thrown)

func _update(total_thrown: int) -> void: #update format
	text = "Thrown: %d/%d" % [min(total_thrown, total), total]
