extends Area2D

@export var death_screen_path: NodePath   # A slot in the inspector where you pick which node is your death/ end screen
@onready var death_screen: Node = get_node(death_screen_path) # The actual node found from that path, so the script can call functions on it.

var triggered: bool = false # A flrag that starts as false and becomes true after the first hit, so the death can only once

func _ready() -> void: # runs once when the scene loads. 
	body_entered.connect(_on_body_entered) #function runs whever something enters the kilzzone.

func _on_body_entered(body: Node2D) -> void: # runs when anything touches the killzone
	if triggered:# if triggerd: return ignores any extra touches once the play has already died.
		return
	if not body.is_in_group("player"): # if not bod. return ignores anything that isn't the player, such as tilemap or enemy
		return

	triggered = true # locks it so it cant fire twice
	death_screen.show_death_screen() # shows the "You died!" screen, pauses the game, hide the HUD, and stops the timer
