extends Label

const DEBUG = true
var debug_menu = false
var debug_message = ""


var dynamic_font = DynamicFont.new()
var dynamic_font_size = 6

func ready_fonts():
	dynamic_font.font_data = load("res://fonts/FORCED SQUARE.ttf")
	dynamic_font.size = dynamic_font_size
	self.set("custom_fonts/font", dynamic_font)

func process_debug_label():
	if DEBUG:
		if Input.is_action_just_pressed("debug"):
			debug_menu = !debug_menu
			
		if debug_menu:
			show_debug_menu()
		else:
			hide_debug_menu()

func show_debug_menu():
	self.set_text(debug_message)

func hide_debug_menu():
	self.set_text("")

## SETGET
func set_debug_message(new_debug_message: String):
	debug_message = new_debug_message

## EXECUTION
func _ready():
	ready_fonts()
	self.add_to_group("debug_label")

func _process(_delta):
	process_debug_label()
