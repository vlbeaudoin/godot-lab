extends KinematicBody2D

const DEBUG = true
onready var debug_label = get_tree().get_nodes_in_group("debug_label")[0]
var debug_menu = false
var msg_state

enum {
	IDLE,
	LEFT,
	RIGHT
}

var state = IDLE
var new_state

var is_dashing = false

var velocity = Vector2.ZERO
var input = Vector2()

export var attributes = {"skill" : 5, "stamina" : 5, "luck" : 5, "speed" : 300.0}
export var friction = 0.15
export var acceleration = 0.2

## FUNCS
func enter_state(new_state):
	match new_state:
		IDLE:
			state = IDLE
			set_rotation(0)
		LEFT:
			state = LEFT
#			set_rotation(-45)
		RIGHT:
			state = RIGHT
#			set_rotation(45)

func get_input():
	input = Vector2.ZERO
	
	if Input.is_action_pressed("movement_left"):
		input.x += -1
	
	if Input.is_action_pressed("movement_right"):
		input.x += 1
	if Input.is_action_pressed("movement_up"):
		input.y += -1
	if Input.is_action_pressed("movement_down"):
		input.y += 1
	
	return input

func process_movement():
	var direction = get_input()
	
	if input.x < 0:
		enter_state(LEFT)
	elif input.x > 0:
		enter_state(RIGHT)
	else:
		enter_state(IDLE)
	
	
	if direction.length() > 0:
		velocity = lerp(velocity, direction.normalized() * attributes.speed, acceleration)
	else:
		velocity = lerp(velocity, Vector2.ZERO, friction)
	
	velocity = move_and_slide(velocity)

## DEBUG
func process_debug_label():
	if debug_label != null and DEBUG:
		if Input.is_action_just_pressed("debug"):
			debug_menu = !debug_menu
			
		if debug_menu:
			show_debug_menu()
		else:
			hide_debug_menu()

func show_debug_menu():
	match state:
				IDLE:
					msg_state = "Character is idle"
				LEFT:
					msg_state = "Character is looking left"
				RIGHT:
					msg_state = "Character is looking right"
		
	debug_label.set_text(
		"""
		Velocity: %s
		State: %s
		Attributes: %s
		""" % [str(velocity), msg_state, attributes])

func hide_debug_menu():
	debug_label.set_text("")


## SETGET
func get_attribute_skill():
	return attributes.skill

func set_attribute_acceleration(new_acceleration: float):
	attributes.acceleration = new_acceleration


## EXECUTION
func _physics_process(_delta):
	process_debug_label()
	process_movement()
