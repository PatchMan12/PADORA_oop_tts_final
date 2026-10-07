extends Node
# Attach to any Node in your main scene (e.g. a plain "LevelManager" node at the root).

@export var trash_container_path: NodePath    # your "trash" node
@export var timer_label_path: NodePath        # the Label with SurvivalTimer.gd
@export var end_screen_path: NodePath         # ONE EndScreen instance, reused for both outcomes

var total_trash: int = 0
var ended: bool = false

@onready var timer_label = get_node(timer_label_path)
@onready var end_screen = get_node(end_screen_path)

func _ready() -> void:
	var container := get_node(trash_container_path)
	total_trash = container.get_child_count()

	timer_label.time_up.connect(_on_time_up)
	PickupManager.progress_updated.connect(_check_win)
	PickupManager.thrown_updated.connect(_check_win)

func _on_time_up() -> void:
	if ended:
		return
	ended = true
	_close_any_open_sorting_screen()
	end_screen.show_end("Time's Up!")

func _check_win(_value: int = 0) -> void:
	if ended:
		return
	if PickupManager.total_ever_collected >= total_trash and PickupManager.total_thrown >= total_trash:
		ended = true
		_close_any_open_sorting_screen()

		var time_taken: float = timer_label.time_limit - timer_label.time_left
		LeaderboardManager.add_entry(PlayerData.player_name, time_taken)

		end_screen.show_end("Congratulations!")

func _close_any_open_sorting_screen() -> void:
	for node in get_tree().get_nodes_in_group("sorting_game"):
		node.force_close()
