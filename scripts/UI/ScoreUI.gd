extends Label
# Attach to a Label placed top-middle in a CanvasLayer.

func _ready() -> void:
	ScoreManager.score_updated.connect(_on_score_updated)
	text = "Score: 0"

func _on_score_updated(new_score: int) -> void:
	text = "Score: %d" % new_score
