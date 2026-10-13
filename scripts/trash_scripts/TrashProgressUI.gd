extends Label

@export var trash_container_path: NodePath   # slot in the inspector whre you pick your trash node (the one holding all the trash scene)

var total: int = 0 #The total number of trash items placed in the level. It's counted oce when the game starts

func _ready() -> void: 
	var container := get_node(trash_container_path) #fins the trash container using the path
	total = container.get_child_count() #counts how many trash items are inside it and saves that as total

	PickupManager.progress_updated.connect(_update) #label is notified every time the player picks up an item
	_update(PickupManager.total_ever_collected)

func _update(total_ever_collected: int) -> void: #format
	text = "Collected: %d/%d" % [min(total_ever_collected, total), total]
