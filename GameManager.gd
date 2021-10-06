extends Node

signal score_update

var is_dead = false
var is_paused = false
var is_idle = true

var score = 0

func _ready():
	pass

func _should_ignore_physics() -> bool:
	return is_idle || is_paused
	
func _should_ignore_game_input() -> bool:
	return is_dead || is_paused
	
func _should_ignore_movement() -> bool:
	return is_idle || is_paused || is_dead
	
func increment_score() -> void:
	score += 1
	print("increment_score: %s" % score)
	emit_signal("score_update")
	
func reset() -> void:
	is_dead = false
	is_paused = false
	is_idle = true
	score = 0
