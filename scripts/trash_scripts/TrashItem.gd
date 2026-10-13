extends Area2D
#Script goes on Area2D

@export var item_id: String = "potato_chip"  # A unique name for this kind of trash PickupManager uses it to count each type separately                                    # Set id of the trash
@export var category: PickupManager.Category = PickupManager.Category.GENERAL #When bin type this trash belongs to (Recyclable, Biodegradable, Genearal, Hazardous)
@export var icon: Texture2D #The small picture shows ni the HUD and in the sorting minigame
@export var points: int = 10 #How many points the player gets for picking it up                                                    

@export var pickup_sound: AudioStream #An optional sound that plays when its collected
@export var destroy_on_pickup: bool = true #If true, the item is removed from the level after pickup

func _ready() -> void: #runs once when the scene loads. It connects the are's built-in body-entered signal to _on_body_entered so that function runs whenever something touches the trash
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void: #runs when anything touches the item
	if not body.is_in_group("player"): #if not body.is_in_group("player") return
		return

	PickupManager.collect(item_id, icon, category) #PickupManager.collect(item_id, icon, category) records the pickup, which updates the inventory counts and the HUD.
	ScoreManager.add_score(points) #add the point to the score

	if pickup_sound: #if a pickup_sound was set, it creates a temporary AudioStreamPlayer2D at the item's position, plays the sound, and deletes itself when the sound finishes
		var player := AudioStreamPlayer2D.new()
		player.stream = pickup_sound
		player.global_position = global_position
		get_tree().current_scene.add_child(player)
		player.play()
		player.finished.connect(player.queue_free)

	if destroy_on_pickup: #is true, owner.queue_free() removes the whole trash scene
		owner.queue_free()
