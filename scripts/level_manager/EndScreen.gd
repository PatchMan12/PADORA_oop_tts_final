extends CanvasLayer


@onready var title_label: Label = $TitleLabel #Text changes depending on which ending happens
@onready var score_label: Label = get_node_or_null("ScoreLabel") # Optional node that shows the final score

func _ready() -> void: #runs once when the scene loads
	process_mode = Node.PROCESS_MODE_ALWAYS   #keeps the screen working while the game is paused. Without it, Space would do nothing because everything is frozen
	hide() #keeps the screen invisible until an ending triggers

func show_end(title: String) -> void: #is the main function, called when the game ends 
	title_label.text = title #sets titlabel to the text it reveived, like "Time's Up!"
	if score_label: #If a ScoreLabel exists it displays Score: followed by the current score from ScoreManager
		score_label.text = "Score: %d" % ScoreManager.score

	show() #makes the creen appear, and get_tree().paused = true freezes the game
	get_tree().paused = true

	for node in get_tree().get_nodes_in_group("hud"): #second loop calls stop_timer() on every node in the "game_timer" group, so the countodwn doesn't keep running behind the screen.
		node.hide()
	for node in get_tree().get_nodes_in_group("game_timer"):
		node.stop_timer()

# is a shortcut that calls show_end("You Died!"). Exists so killzine.gd can keep using its orignal function name without changes
func show_death_screen() -> void:
	show_end("You Died!")

func _unhandled_input(event: InputEvent) -> void: #runs whenever the player presses a key. If the screen is visible and the player presses a key. If the screen is visible and the player presses Space or Enter(ui_accept). it calls _restart()
	if visible and event.is_action_pressed("ui_accept"):
		_restart()

func _restart() -> void: #resets the game
	get_tree().paused = false
	PickupManager.reset()
	ScoreManager.reset_score()
	get_tree().reload_current_scene()
