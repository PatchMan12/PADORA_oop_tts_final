extends CanvasLayer
# Attach to your single EndScreens CanvasLayer, used for death, time's up, AND the win screen.
# Required child: TitleLabel (Label) - text is set in code (e.g. "You Died!", "Time's Up!", "Congratulations!")
# Optional child: ScoreLabel (Label) - if present, shows "Score: X"

@onready var title_label: Label = $TitleLabel
@onready var score_label: Label = get_node_or_null("ScoreLabel")

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS   # so this still works while the tree is paused
	hide()

func show_end(title: String) -> void:
	title_label.text = title
	if score_label:
		score_label.text = "Score: %d" % ScoreManager.score

	show()
	get_tree().paused = true

	for node in get_tree().get_nodes_in_group("hud"):
		node.hide()
	for node in get_tree().get_nodes_in_group("game_timer"):
		node.stop_timer()

# Kept so killzone.gd's existing call still works without changes
func show_death_screen() -> void:
	show_end("You Died!")

func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_accept"):
		_restart()

func _restart() -> void:
	get_tree().paused = false
	PickupManager.reset()
	ScoreManager.reset_score()
	get_tree().reload_current_scene()
