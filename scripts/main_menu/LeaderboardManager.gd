extends Node
# Autoload this as "LeaderboardManager"
# Stores entries locally on this PC, in Godot's user data folder.

const SAVE_PATH := "user://leaderboard.json"
const MAX_ENTRIES := 50

var entries: Array = []   # [{ "name": String, "time": float }, ...] sorted fastest-first

func _ready() -> void:
	_load()

func add_entry(player_name: String, time_taken: float) -> void:
	entries.append({"name": player_name, "time": time_taken})
	entries.sort_custom(func(a, b): return a["time"] < b["time"])
	if entries.size() > MAX_ENTRIES:
		entries.resize(MAX_ENTRIES)
	_save()

func get_entries() -> Array:
	return entries

func _save() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(entries))
		file.close()

func _load() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var text := file.get_as_text()
		file.close()
		var parsed = JSON.parse_string(text)
		if parsed is Array:
			entries = parsed
