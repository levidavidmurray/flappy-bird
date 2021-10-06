extends KinematicBody2D

signal hit

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var screen_size

export var vertical_speed = 550
export var gravity_min = 350
export var gravity_max = 550
export var gravity_time = 0.6
export var jump_time_max = 0.2

export var jump_rotation_time = 0.05
export var fall_rotation_time = 0.4
export var max_jump_rotation = -0.5
export var max_fall_rotation = 1.4
export var fall_rotation_delay = 0.25

var last_jump_time = 0
var last_fall_time = 0
var jump_count = 0
var jump_time = jump_time_max
var gravity = gravity_min

var is_jumping = false
var was_jumping_last_frame = false
var last_point_effector_id = null

var velocity = Vector2.ZERO
var lock_position

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	last_fall_time = OS.get_ticks_msec()
	lock_position = position

func _physics_process(delta):
	
	if GameManager._should_ignore_physics():
		rotation = 0
		return
	
	var collision = move_and_collide(velocity * delta)
	position.x = lock_position.x

	if collision:
		var collider_parent = collision.collider.get_parent()
		if collider_parent.is_in_group("obstacle"):
			print("Collided with: %s" % collider_parent.name)
			GameManager.is_dead = true

	check_gravity()
	check_rotation()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	
	if Input.is_action_just_pressed("ui_right"):
		GameManager.increment_score()
		
		rotation -= 0.03
	if Input.is_action_pressed("ui_down"):
		rotation += 0.03
	
	if Input.is_action_just_pressed("pause"):
		GameManager.is_paused = !GameManager.is_paused
		
	if Input.is_action_just_pressed("restart"):
		GameManager.reset()
		get_tree().reload_current_scene()
		
	if is_jumping:
		velocity = Vector2.UP * vertical_speed
	else:
		velocity = Vector2.DOWN * gravity

	if GameManager._should_ignore_game_input():
		$AnimatedSprite.animation = "idle"
		return
	
	# velocity = Vector2.ZERO

	if Input.is_action_pressed("ui_up"):
		rotation -= 0.03
	if Input.is_action_pressed("ui_down"):
		rotation += 0.03

	# print("velocity: %s, rotation: %s" % [velocity, rotation])

	if Input.is_action_just_pressed("jump"):
		GameManager.is_idle = false
		var gravity_percent = (gravity - gravity_min) / (gravity_max - gravity_min)
		# jump_time = jump_time_max * gravity_percent
		gravity = gravity_min
		jump_count += 1
		last_jump_time = OS.get_ticks_msec()
		is_jumping = true
		
	#if Input.is_action_pressed("jump"):
		# if !is_jumping && was_jumping_last_frame:
		#	velocity = Vector2.UP * vertical_speed
		
	# was_jumping_last_frame = is_jumping
		
	
func _on_PipeCollider_body_entered(body):
	print("Area2D enterted %s" % body.name)
	var body_parent = body.get_parent()
	if body_parent.is_in_group("obstacle") || body.is_in_group("obstacle"):
		gravity = gravity_max
		GameManager.is_dead = true
	
func _on_PointCollider_area_exited(area):
	if area.name == "PointEffector":
		if GameManager.is_dead: return
		var point_effector_id = area.get_instance_id()
		if point_effector_id == last_point_effector_id: return
		last_point_effector_id = point_effector_id
		GameManager.increment_score()
	
	pass # Replace with function body.

func check_gravity():
	if !is_jumping:
		# var t = clamp(time_since_fall() / gravity_time, 0, 1)
		# gravity = lerp(gravity, gravity_max, t)
		return
	if time_since_jump() >= jump_time:
		last_fall_time = OS.get_ticks_msec()
		is_jumping = false

func check_rotation():
	if is_jumping || (jump_count > 0 && time_since_fall() < fall_rotation_delay):
		var t = clamp(time_since_jump() / jump_rotation_time, 0, 1)
		rotation = lerp(rotation, max_jump_rotation, t)
	else:
		var time_since_fall_rotation = time_since_fall() - fall_rotation_delay
		var t = clamp(time_since_fall_rotation / fall_rotation_time, 0, 1)
		rotation = lerp(rotation, max_fall_rotation, t)
		# print("""
		# 	time_since_fall: %s,

		# """ % [])

func time_since_jump():
	return (OS.get_ticks_msec() - last_jump_time) / 1000.0

func time_since_fall():
	return (OS.get_ticks_msec() - last_fall_time) / 1000.0
