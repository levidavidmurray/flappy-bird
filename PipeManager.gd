extends Node2D

var PipePair = preload("res://PipePair.tscn")

export var pipe_speed = 135
export var min_y_interval = 80
var current_pipe_speed = 0

var last_pipe_y_pos = -40

func _ready():
	randomize()
	
	for child in $Pipes.get_children():
		child.add_to_group("obstacle")

func _process(_delta):
	var should_ignore_movement = GameManager._should_ignore_movement()
	
	if Input.is_action_just_pressed("spawn"):
		_spawn_pipe()
	
	# Stop pipe movement
	if should_ignore_movement && current_pipe_speed == -pipe_speed:
		$SpawnTimer.stop()
		_set_pipe_speed(0)
		return
		
	# Start pipe movement	
	if !should_ignore_movement && current_pipe_speed == 0:
		_spawn_pipe()
		$SpawnTimer.start()
		_set_pipe_speed(-pipe_speed)

func _set_pipe_speed(speed):
	for child in $Pipes.get_children():
		(child as RigidBody2D).linear_velocity.x = speed
	current_pipe_speed = speed
	
func get_spawn_position() -> Vector2:
	var limit1_pos = $SpawnLimit_Y1.position
	var limit2_pos = $SpawnLimit_Y2.position
	var y_pos = lerp(limit1_pos.y, limit2_pos.y, randf())
	return Vector2($SpawnLimit_X.position.x, y_pos)

func _spawn_pipe():
	var pipe_pair = PipePair.instance()
	pipe_pair.add_to_group("obstacle")
	(pipe_pair as RigidBody2D).linear_velocity.x = -pipe_speed
	var spawn_position = get_spawn_position()
	
	while abs(spawn_position.y - last_pipe_y_pos) < min_y_interval:
		print("""
		spawn_position.y: %s,
		last_pipe_y_pos: %s,
		diff: %s
		""" % [spawn_position.y, last_pipe_y_pos, abs(spawn_position.y - last_pipe_y_pos)])
		spawn_position = get_spawn_position()
	
	last_pipe_y_pos = spawn_position.y
	pipe_pair.position = spawn_position
	$Pipes.add_child(pipe_pair)
	print("Pipe spawned at %s" % pipe_pair.position)


func _on_SpawnTimer_timeout():
	_spawn_pipe()
