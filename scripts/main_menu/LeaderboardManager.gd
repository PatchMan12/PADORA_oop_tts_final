extends Node
# Keeps the list of players who finished the game 
const SAVE_PATH := "user://leaderboard.json" #path of the json
const MAX_ENTRIES := 50 #max entries scores kept (50). Slower times beyond that are dropped

var entries: Array = []   #the leaderboard itself: a list where each item holds a player's name and time

func _ready() -> void: #runs once when the game starts. It calls _load(), so scores saved rrom earlier sessions are brought back into memory
	_load()

func add_entry(player_name: String, time_taken: float) -> void: #is called by LevelManager when the player wins.
	entries.append({"name": player_name, "time": time_taken})
	entries.sort_custom(func(a, b): return a["time"] < b["time"])
	if entries.size() > MAX_ENTRIES:
		entries.resize(MAX_ENTRIES)
	_save()

func get_entries() -> Array: #returns the list
	return entries

func _save() -> void: #writes the list to the file
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(entries))
		file.close()

func _load() -> void: #reads the file back when the game starts.
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var text := file.get_as_text()
		file.close()
		var parsed = JSON.parse_string(text)
		if parsed is Array:
			entries = parsed
