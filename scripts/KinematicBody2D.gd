extends KinematicBody2D

const DEBUG = true
onready var debug_label = get_tree().get_nodes_in_group("debug_label")[0]

#onready var animated_sprite = $AnimatedSprite

var msg_state

enum {
	IDLE,
	LEFT,
	RIGHT,
	ATTACK
}

var state = IDLE

var is_dashing = false

var velocity = Vector2.ZERO
var input = Vector2()

export var attributes = {
	"skill" : 5, "stamina" : 5, "luck" : 5, "speed" : 120.0, \
	"friction" : 0.15, "acceleration" : 0.1, "max_velocity" : 300
	}


## FUNCS
func enter_state(new_state):
	if state != new_state:
		match new_state:
			IDLE:
				state = IDLE
#				animated_sprite.set_animation("idle")
			LEFT:
				if state != ATTACK:
					state = LEFT
#					animated_sprite.set_flip_h(true)
			RIGHT:
				if state != ATTACK:
					state = RIGHT
#					animated_sprite.set_flip_h(false)
			ATTACK:
				state = ATTACK
#				animated_sprite.set_animation("attack")
				

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
	
	if Input.is_action_pressed("attack"):
		enter_state(ATTACK)
	
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
		velocity = lerp(velocity, direction * attributes.speed, attributes.acceleration)
#		velocity = lerp(velocity, direction.normalized() * attributes.speed, attributes.acceleration) # since we'll be using move_and_slide, no need to multiply by delta (or .normalize()) since the function already takes it into consideration.
	else:
		velocity = lerp(velocity, Vector2.ZERO, attributes.friction)
	
	velocity.x = clamp(velocity.x, -attributes.max_velocity, attributes.max_velocity)
	velocity.y = clamp(velocity.y, -attributes.max_velocity, attributes.max_velocity)
	
	velocity = move_and_slide(velocity)

func process_debug_label():
#	match state:
#				IDLE:
#					msg_state = "Character is idle"
#				LEFT:
#					msg_state = "Character is looking left"
#				RIGHT:
#					msg_state = "Character is looking right"
		
	debug_label.set_debug_message(
		"""Debug menu - F3
		
		Velocity: %s
		Input: %s
		State: %s
		Attributes: %s
		""" % [str(velocity), str(input), str(state), attributes]
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
