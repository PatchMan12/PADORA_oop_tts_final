extends Area2D
# Set item_id, category, icon, and points per instance in the Inspector.

@export var item_id: String = "potato_chip" # Set id of the trash
@export var category: PickupManager.Category = PickupManager.Category.GENERAL
@export var icon: Texture2D
@export var points: int = 10 # Score of the trash when picked up 

@export var pickup_sound: AudioStream
@export var destroy_on_pickup: bool = true

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return

	PickupManager.collect(item_id, icon, category)
	ScoreManager.add_score(points)

	if pickup_sound:
		var player := AudioStreamPlayer2D.new()
		player.stream = pickup_sound
		player.global_position = global_position
		get_tree().current_scene.add_child(player)
		player.play()
		player.finished.connect(player.queue_free)

	if destroy_on_pickup:
		owner.queue_free()
