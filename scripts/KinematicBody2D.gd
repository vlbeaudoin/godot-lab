extends KinematicBody2D

const DEBUG = true
onready var debug_label = get_tree().get_nodes_in_group("debug_label")[0]

onready var sprite = $Sprite
onready var animation_player = $Sprite/AnimationPlayer

enum {
	IDLE,
	RUN,
	ATTACK
}

var state = IDLE
var is_dashing = false
var is_looking_left = false
var is_attacking = false

var velocity = Vector2.ZERO
var input = Vector2()
var direction

export var attributes = {
	"skill" : 5, "stamina" : 5, "luck" : 5, "speed" : 120.0, \
	"friction" : 0.15, "acceleration" : 0.1, "max_velocity" : 300
	}


## FUNCS
func enter_state(new_state):
	if state != new_state and !is_attacking:
		if new_state == IDLE:
			state = IDLE
			animation_player.play("idle")
		if new_state == RUN:
			state = RUN
			animation_player.play("run")
		if new_state == ATTACK:
			is_attacking = true
			state = ATTACK
			animation_player.play("attack")


func process_controls_input() -> void:
	if Input.is_action_just_pressed("toggle_fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen

func get_input():
	input = Vector2.ZERO
	
	# Get directions input
	if Input.is_action_pressed("movement_left"):
		input.x += -1
	if Input.is_action_pressed("movement_right"):
		input.x += 1
	if Input.is_action_pressed("movement_up"):
		input.y += -1
	if Input.is_action_pressed("movement_down"):
		input.y += 1
	
	if Input.is_action_pressed("attack"):
		process_attack()
	
	return input

func process_movement():
	# State
	if input != Vector2.ZERO:
		enter_state(RUN)
	else:
		enter_state(IDLE)
		
	# Direction-controlled movement
	direction = get_input()

	if direction.length() > 0 and !is_attacking:
		velocity = lerp(velocity, direction * attributes.speed, attributes.acceleration)# since we'll be using move_and_slide, no need to multiply by delta (or .normalize()) since the function already takes it into consideration.

	if direction.length() == 0 or is_attacking:
		velocity = lerp(velocity, Vector2.ZERO, attributes.friction)
	
	velocity.x = clamp(velocity.x, -attributes.max_velocity, attributes.max_velocity)
	velocity.y = clamp(velocity.y, -attributes.max_velocity, attributes.max_velocity)
	
	velocity = move_and_slide(velocity)

func process_look_direction():
	if !is_attacking:
		if input.x < 0:
			is_looking_left = true
		if input.x > 0:
			is_looking_left = false
		sprite.set_flip_h(is_looking_left)

func process_debug_label():
	debug_label.set_debug_message(
		"""Debug menu - F3
		
		Velocity: %s
		Attributes: %s
		State: %s
		
		Input: %s
		is_looking_left: %s
		Attacking: %s
		""" % [str(velocity), attributes, str(state), str(input), is_looking_left, is_attacking]
		)

func process_attack():
	if is_looking_left:
		sprite.position.x = -22
	else:
		sprite.position.x = 37
	enter_state(ATTACK)

## SETGET
func set_attribute_acceleration(new_acceleration: float):
	attributes.acceleration = new_acceleration

## SIGNALS
func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "attack":
		is_attacking = false

## EXECUTION	
func _ready():
	animation_player.connect("animation_finished", self, "_on_AnimationPlayer_animation_finished")
	
func _physics_process(_delta):
	process_debug_label()
	process_controls_input()
	process_look_direction()
	process_movement()
