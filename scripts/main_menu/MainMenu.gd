extends Control
# This script goes on the root control of your main menu scene. It handles the Playbutton, the name popup, and the leaderboard panel

@export var game_scene_path: String = "res://main.tscn"   # The file path of your gameplay scene which loads after the playe enters a name  (set in the inspector)

@onready var name_popup: Control = $NamePopup # the panel where the player types their name
@onready var name_edit: LineEdit = $NamePopup/NameLineEdit #the textbox inside the popup
@onready var play_button: Button = $PlayButton # The play button
@onready var leaderboard_button: Button = $LeaderboardButton # The leaderboard button
@onready var confirm_button: Button = $NamePopup/ConfirmButton # The start button inside the name pop up

@onready var leaderboard_panel: Control = $LeaderboardPanel # the planel that shows the leadrboard 
@onready var entries_list: VBoxContainer = $LeaderboardPanel/ScrollContainer/EntriesList #The empty list inside the panel that gets filled with name and time rows
@onready var close_button: Button = $LeaderboardPanel/CloseButton #The close button on the leaderboard panel

#The @onready keyowrd means each variable finds its node as soon as the scene is ready. Those node names must match your scene exactly, or Godot throws a "Node not found" error.
func _ready() -> void: #runs once when the menu loads
	name_popup.hide() #It hides the name popup and the leaderboard panel so only the main button show.
	leaderboard_panel.hide() #It connects each button's pressed signal to its function. Pressing Enter inside the text box also confirms the name

	play_button.pressed.connect(_on_play_pressed) 
	leaderboard_button.pressed.connect(_on_leaderboard_pressed)
	confirm_button.pressed.connect(_on_confirm_pressed)
	close_button.pressed.connect(_on_close_leaderboard_pressed)
	name_edit.text_submitted.connect(func(_text): _on_confirm_pressed())   

func _on_play_pressed() -> void: #shows the name popup and puts the cursor in the text box (grab_focus) so the player can type right away.
	name_popup.show()
	name_edit.grab_focus()

func _on_confirm_pressed() -> void: #runs when the player presses start or Enter.
	var entered := name_edit.text.strip_edges() #removes extra spaces from the typed name
	if entered == "": #if the name is empty, return stops the function, so nothing happens and the player can't enter the game without a name
		return   

	PlayerData.player_name = entered #Else the name is saved to PlayerData.player_name, and change_scene_to_file() loads your gameplay scene
	get_tree().change_scene_to_file(game_scene_path)

func _on_leaderboard_pressed() -> void: #fills the list with the latest scores (_populate_leaderboard()), then shows the leaderboard panel.
	_populate_leaderboard() 
	leaderboard_panel.show()

func _on_close_leaderboard_pressed() -> void:
	leaderboard_panel.hide()

func _populate_leaderboard() -> void: #builds the leaderboard display in code
	for child in entries_list.get_children(): #it deletes the old rows (queue_free()) so entries don't pile up each time the pabel opens
		child.queue_free() 

	var entries := LeaderboardManager.get_entries() #it asks leaderboardManager.get_entries() for the saved scores.

	if entries.is_empty(): #if there are none, it shows "No completions yet. Be the first to finish!"
		var empty_label := Label.new()
		empty_label.text = "No completions yet. Be the first to finish!"
		entries_list.add_child(empty_label)
		return

	for i in range(entries.size()): #it loops through the entries and creates one row per player, containing a rank label (1.), a name kabek, abd a time label (like 42.59s). The entries are already sorted fastest first, so the order follows the list. 
		var entry: Dictionary = entries[i]
		var row := HBoxContainer.new()

		var rank_label := Label.new()
		rank_label.text = "%d." % (i + 1)
		rank_label.custom_minimum_size = Vector2(32, 0)

		var name_label := Label.new()
		name_label.text = str(entry.get("name", "Player"))
		name_label.custom_minimum_size = Vector2(160, 0)

		var time_label := Label.new()
		time_label.text = "%.2fs" % float(entry.get("time", 0))

		row.add_child(rank_label)
		row.add_child(name_label)
		row.add_child(time_label)
		entries_list.add_child(row)
