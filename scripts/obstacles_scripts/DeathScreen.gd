extends CanvasLayer
#The script has no variables of its own. It only uses Godot's built-in prperties and your global managers

func _ready() -> void: #runs once when the scene loads
	process_mode = Node.PROCESS_MODE_ALWAYS   # Keeps this screen working even while the game is paused. 
	hide()#makes the screen invisible until it's needed.

func show_death_screen() -> void: #show_death_screen() is called by killzone.gd when the player dies.
	show() # makes the overlay (dim background and "You Died" text) appear. 
	get_tree().paused = true #freezes the whole gam: player, enemis, platforms
	for node in get_tree().get_nodes_in_group("hud"):
		node.hide()
	for node in get_tree().get_nodes_in_group("game_timer"):
		node.stop_timer()

func _unhandled_input(event: InputEvent) -> void: # runs whenever the player presses something.
	if visible and event.is_action_pressed("ui_accept"):  # checks the death screen is actually showing. event is_action_pressed("ui_accept") checks for space or enter
		_restart() #if both are true, it calls _restart()

func _restart() -> void: #resets everything and start over
	get_tree().paused = false # unfreezes the game
	PickupManager.reset() # clears the collected trash and counters
	ScoreManager.reset_score() # sets the score back to 0
	get_tree().reload_current_scene() # reloads the leve. which also resets the timer and HUD because they are recreated with the scene.
