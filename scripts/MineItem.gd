extends Button


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var x = 0
var y = 0

var mine_around_num

enum {
	NOTHING = 0,
	MINE = 1,
	FLAGGED = 2,
	UNCOVERED = 4
}

var state = NOTHING

signal item_left_clicked(_x, _y)
signal item_right_clicked(_x, _y)

var button_mine_click_style = preload("res://styles/mine_clicked_style.tres")
var button_normal_click_style = preload("res://styles/item_clicked.tres")
var item_hover_style = preload("res://styles/item_hover_style.tres")
var item_pressed_style = preload("res://styles/item_pressed_style.tres")
var item_style = preload("res://styles/item_style.tres")

var mine_icon = preload("res://assets/new_releases_white_24dp.svg")
var flag_icon = preload("res://assets/outlined_flag_white_24dp.svg")


func get_x():
	return x
func get_y():
	return y
func get_state():
	return state
func set_mine():
	state |= MINE
func is_mine():
	return state & MINE
func uncovered():
	return state & UNCOVERED
func set_uncovered():
	state |= UNCOVERED
func is_flagged():
	return state & FLAGGED
func set_flagged():
	state |= FLAGGED
func remove_flagged():
	state &= ~FLAGGED
	
func how_many_mines_around():
	return mine_around_num
func set_how_many_mines_around(num):
	mine_around_num = num

func init_xy(_x, _y):
	x = _x
	y = _y
func init_state(_state):
	state = _state

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("gui_input", self, "_on_button_clicked")

func set_text(s):
	text = str(s)

func get_pos():
	pass

func _on_button_clicked(event):
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			BUTTON_LEFT:
				emit_signal("item_left_clicked", x, y)
			BUTTON_RIGHT:
				emit_signal("item_right_clicked", x, y)

func left_click_transform():
	if is_mine():
		set("custom_styles/normal", button_mine_click_style)
		set("custom_styles/pressed", button_mine_click_style)
		set("custom_styles/hover", button_mine_click_style)
		set("custom_styles/focus", button_mine_click_style)
		
		set_text("")
		set("icon", mine_icon)
	else:
		set("custom_styles/normal", button_normal_click_style)
		set("custom_styles/pressed", button_normal_click_style)
		set("custom_styles/hover", button_normal_click_style)
		set("custom_styles/focus", button_normal_click_style)
		if how_many_mines_around():
			set_text(how_many_mines_around())
		else:
			set_text("")

func right_click_transform():
	if uncovered():
		return
		
	if is_flagged():
		set_text("")
		set("icon", flag_icon)
	else:
		set_text("")
		set("icon", null)

func restart():
	state = NOTHING
	set_text("")
	set("icon", null)
	
	set("custom_styles/normal", item_style)
	set("custom_styles/pressed", item_pressed_style)
	set("custom_styles/hover", item_hover_style)
