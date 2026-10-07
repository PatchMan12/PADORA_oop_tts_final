extends CanvasLayer
# Attach to a CanvasLayer node. Give it children:
#   ColorRect (full-screen, semi-transparent black) for the dim overlay
#   Label "You Died"
#   Label "Press SPACE to Restart"
# Leave this CanvasLayer's visibility OFF by default in the editor.

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS   # so this still works while the tree is paused
	hide()

func show_death_screen() -> void:
	show()
	get_tree().paused = true
	for node in get_tree().get_nodes_in_group("hud"):
		node.hide()
	for node in get_tree().get_nodes_in_group("game_timer"):
		node.stop_timer()

func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_accept"):  # Space / Enter by default
		_restart()

func _restart() -> void:
	get_tree().paused = false
	PickupManager.reset()
	ScoreManager.reset_score()
	get_tree().reload_current_scene()
