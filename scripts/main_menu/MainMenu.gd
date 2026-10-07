extends Control
# Attach to the root Control of your MainMenu scene.
# Required children (names must match):
#   Background        (TextureRect)        - your PNG, Full Rect
#   PlayButton         (Button)
#   LeaderboardButton  (Button)
#   NamePopup          (Control/Panel, hidden by default)
#     NameLineEdit     (LineEdit)
#     ConfirmButton    (Button)
#   LeaderboardPanel   (Control/Panel, hidden by default)
#     EntriesList      (VBoxContainer, inside a ScrollContainer)
#     CloseButton      (Button)

@export var game_scene_path: String = "res://main.tscn"   # path to your gameplay scene

@onready var name_popup: Control = $NamePopup
@onready var name_edit: LineEdit = $NamePopup/NameLineEdit
@onready var play_button: Button = $PlayButton
@onready var leaderboard_button: Button = $LeaderboardButton
@onready var confirm_button: Button = $NamePopup/ConfirmButton

@onready var leaderboard_panel: Control = $LeaderboardPanel
@onready var entries_list: VBoxContainer = $LeaderboardPanel/ScrollContainer/EntriesList
@onready var close_button: Button = $LeaderboardPanel/CloseButton

func _ready() -> void:
	name_popup.hide()
	leaderboard_panel.hide()

	play_button.pressed.connect(_on_play_pressed)
	leaderboard_button.pressed.connect(_on_leaderboard_pressed)
	confirm_button.pressed.connect(_on_confirm_pressed)
	close_button.pressed.connect(_on_close_leaderboard_pressed)
	name_edit.text_submitted.connect(func(_text): _on_confirm_pressed())   # Enter key also confirms

func _on_play_pressed() -> void:
	name_popup.show()
	name_edit.grab_focus()

func _on_confirm_pressed() -> void:
	var entered := name_edit.text.strip_edges()
	if entered == "":
		return   # no name entered - do nothing, stay on the popup

	PlayerData.player_name = entered
	get_tree().change_scene_to_file(game_scene_path)

func _on_leaderboard_pressed() -> void:
	_populate_leaderboard()
	leaderboard_panel.show()

func _on_close_leaderboard_pressed() -> void:
	leaderboard_panel.hide()

func _populate_leaderboard() -> void:
	for child in entries_list.get_children():
		child.queue_free()

	var entries := LeaderboardManager.get_entries()

	if entries.is_empty():
		var empty_label := Label.new()
		empty_label.text = "No completions yet. Be the first to finish!"
		entries_list.add_child(empty_label)
		return

	for i in range(entries.size()):
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
