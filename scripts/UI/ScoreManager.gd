extends Node
#manages the score of the player

signal score_updated(new_score: int)

var score: int = 0

func add_score(amount: int) -> void:
	score += amount
	score_updated.emit(score)

func reset_score() -> void:
	score = 0
	score_updated.emit(score)
