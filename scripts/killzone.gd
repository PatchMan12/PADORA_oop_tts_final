extends Area2D

@export var death_screen_path: NodePath   # drag your DeathScreen node here in the Inspector
@onready var death_screen: Node = get_node(death_screen_path)

var triggered: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if triggered:
		return
	if not body.is_in_group("player"):
		return

	triggered = true
	death_screen.show_death_screen()
