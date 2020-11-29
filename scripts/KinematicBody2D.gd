extends KinematicBody2D

const DEBUG = true
onready var debug_label = get_tree().get_nodes_in_group("debug_label")[0]

onready var animated_sprite = $AnimatedSprite

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

export var attributes = {
	"skill" : 5, "stamina" : 5, "luck" : 5, \
	"speed" : 150.0, "friction" : 0.15, "acceleration" : 0.1
	}


## FUNCS
func enter_state(new_state):
	match new_state:
		IDLE:
			state = IDLE
		LEFT:
			state = LEFT
			animated_sprite.set_flip_h(true)
		RIGHT:
			state = RIGHT
			animated_sprite.set_flip_h(false)

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
	# State
	if input.x < 0:
		enter_state(LEFT)
	elif input.x > 0:
		enter_state(RIGHT)
	else:
		enter_state(IDLE)
	
	# Direction-controlled movement
	var direction = get_input()
	if direction.length() > 0:
		velocity = lerp(velocity, direction.normalized() * attributes.speed, attributes.acceleration)
	else:
		velocity = lerp(velocity, Vector2.ZERO, attributes.friction)
	
	velocity = move_and_slide(velocity)

func process_debug_label():
	match state:
				IDLE:
					msg_state = "Character is idle"
				LEFT:
					msg_state = "Character is looking left"
				RIGHT:
					msg_state = "Character is looking right"
		
	debug_label.set_debug_message(
		"""Velocity: %s
		State: %s
		Attributes: %s
		""" % [str(velocity), msg_state, attributes]
		)

## SETGET
func get_attribute_skill():
	return attributes.skill

func set_attribute_acceleration(new_acceleration: float):
	attributes.acceleration = new_acceleration


## EXECUTION
func _ready():
	pass
	
func _physics_process(_delta):
	process_debug_label()
	process_movement()
