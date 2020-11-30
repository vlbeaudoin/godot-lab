extends KinematicBody2D

const DEBUG = true
onready var debug_label = get_tree().get_nodes_in_group("debug_label")[0]
var looking_left = false

#onready var animated_sprite = $AnimatedSprite
onready var sprite = $Sprite
onready var animation_player = $Sprite/AnimationPlayer

var msg_state

enum {
	IDLE,
	RUN,
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
				animation_player.play("idle")
			RUN:
				state = RUN
				animation_player.play("run")
			ATTACK:
				state = ATTACK
				animation_player.play("attack")
				

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
	
	# Flip (look direction)
	if input.x < 0:
		looking_left = true
	if input.x > 0:
		looking_left = false
	sprite.set_flip_h(looking_left)
	
#	if Input.is_action_pressed("attack"):
#		enter_state(ATTACK)
	
	return input

func process_movement():
	# State
	if input != Vector2.ZERO:
		enter_state(RUN)
	else:
		enter_state(IDLE)
	
	# Direction-controlled movement
	var direction = get_input()
	if direction.length() > 0:
		velocity = lerp(velocity, direction * attributes.speed, attributes.acceleration)# since we'll be using move_and_slide, no need to multiply by delta (or .normalize()) since the function already takes it into consideration.
	else:
		velocity = lerp(velocity, Vector2.ZERO, attributes.friction)
	
	velocity.x = clamp(velocity.x, -attributes.max_velocity, attributes.max_velocity)
	velocity.y = clamp(velocity.y, -attributes.max_velocity, attributes.max_velocity)
	
	velocity = move_and_slide(velocity)

func process_debug_label():
	debug_label.set_debug_message(
		"""Debug menu - F3
		
		Velocity: %s
		Attributes: %s
		State: %s
		
		Input: %s
		looking_left: %s
		""" % [str(velocity), attributes, str(state), str(input), looking_left]
		)

## SETGET
func set_attribute_acceleration(new_acceleration: float):
	attributes.acceleration = new_acceleration

## EXECUTION	
func _physics_process(_delta):
	process_debug_label()
	process_movement()
