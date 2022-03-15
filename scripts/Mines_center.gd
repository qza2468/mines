extends Control

# TODO: i should set a uniform interface to get the item, and describe the item's place
# there are three options: 1. index, 2. x and y, 3. the item itself
# i pick `x and y`, thought using this seems to need to use a lot of `get_x` and `get_y`
# but every function has arguments `x` and `y`, and i could set them too.

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


onready var informational_container = $VBoxContainer/HBoxContainer
onready var count_timer = informational_container.get_node("time_now/Timer")
onready var Restart_Button = informational_container.get_node("Menu/Restart")
onready var Pause_Button = informational_container.get_node("Menu/Pause")
onready var Home_Button = informational_container.get_node("Menu/Home")
onready var Pause_Page = $Pause
onready var Win_Page = $Win
onready var Lose_Page = $Lose
onready var Grid_Container = $VBoxContainer/CenterContainer/GridContainer

func restart():
	flagged_mines = 0
	uncovered = 0
	time_count = 0
	first_click = true
	
	count_timer.disconnect("timeout", self, "_on_count_timer_timeout")
	for i in range(rows):
		for j in range(cols):
			fetch(i, j).restart()
			
	informational_container.set_mine_num(MINES_NUM)
	informational_container.set_time_text(0)	

func exit():
	get_tree().quit(0)
	
func on_win_page_clicked(event):
	if event is InputEventMouseButton and event.pressed == true:
		exit()

func on_lose_page_again_clicked():
	Lose_Page.visible = false
	restart()

export var rows = 22
export var cols = 40

export var RANDOM_SEED = 2468

export var MINES_NUM = 180
var grids_num = rows * cols
var flagged_mines = 0
var uncovered = 0

var time_count = 0

var first_click = true

var mine_item_template = preload("res://MineItem.tscn")

var mines_board = []

func xy_to_index(x, y):
	return x * cols + y
func index_to_x(i):
	return i / cols
func index_to_y(i):
	return i % cols
func xy_pair_to_index(xy_pair):
	return xy_to_index(xy_pair[0], xy_pair[1])
func fetch(x, y = null):
	if y == null:
		return mines_board[x]
	return mines_board[xy_to_index(x, y)]

func get_arounds_xy(x, y):
	var arounds_xy = []
	for i in range(-1, 2):
		for j in range(-1, 2):
			if x + i < 0 or x + i >= rows or y + j < 0 or y + j >= cols \
			or (i == 0 and j == 0): # out of range or include itself
				continue
			
			arounds_xy.append([x + i, y + j])
	
	return arounds_xy

func get_arounds(x, y):
	var arounds_xy_v = get_arounds_xy(x, y)
	var arounds = []
	for xy in arounds_xy_v:
		arounds.append(fetch(xy[0], xy[1]))
	
	return arounds

func get_around_mines_num(x, y = null):
	var arounds_items 
	if y == null:
		arounds_items = get_arounds(index_to_x(x), index_to_y(x))
	else:
		arounds_items = get_arounds(x, y)
	var count = 0
	for item in arounds_items:
		if item.is_mine():
			count += 1
	
	return count

func get_around_covered(x, y = null):
	var arounds_items 
	if y == null:
		arounds_items = get_arounds(index_to_x(x), index_to_y(x))
	else:
		arounds_items = get_arounds(x, y)
	var items = []
	for item in arounds_items:
		if not item.uncovered():
			items.append(item)
			
	return items

func get_around_flagged_mines(x, y = null):
	var arounds_items 
	if y == null:
		arounds_items = get_arounds(index_to_x(x), index_to_y(x))
	else:
		arounds_items = get_arounds(x, y)
	var items = []
	for item in arounds_items:
		if item.is_flagged():
			items.append(item)
			
	return items

# just do some preparation
func _ready():
	
	# init the environment
	randomize()
	Grid_Container.columns = cols
	informational_container.set_mine_num(MINES_NUM)	
	
	Pause_Button.connect("pressed", Pause_Page, "on_pause")
	Restart_Button.connect("pressed", self, "restart")
	
	# just add the mines to the board, they have no state yet.
	for i in range(rows):
		for j in range(cols):
			mines_board.append(mine_item_template.instance())
			fetch(i, j).init_xy(i, j)
			Grid_Container.add_child(fetch(i, j))
			
			fetch(i, j).connect("item_left_clicked", self, "_on_mine_left_clicked")
			fetch(i, j).connect("item_right_clicked", self, "_on_mine_right_clicked")


# this is the real begin of game	
func real_state_init(x, y):
	count_timer.start()
	count_timer.connect("timeout", self, "_on_count_timer_timeout")
	
	var vector_for_randomize = []
	
	var arounds_xy = get_arounds_xy(x, y)
	arounds_xy.append([x, y])
	
	var not_mines_num = arounds_xy.size()
	for i in range(grids_num - MINES_NUM - not_mines_num):
		vector_for_randomize.append(0)
	for i in range(MINES_NUM):
		vector_for_randomize.append(1)
	vector_for_randomize.shuffle()
	
	for xy_pair in arounds_xy:
		# to normal insert method will interact with inserted items.
		# which will result in mine in around items.
		# so i replace it with 0 and append the previous value at the end
		# it will not result any asymmetry(不对称性)
		# vector_for_randomize.insert(xy_pair_to_index(xy_pair), 0)
		vector_for_randomize.append(vector_for_randomize[xy_pair_to_index(xy_pair)])
		vector_for_randomize[xy_pair_to_index(xy_pair)] = 0
	
	for i in range(grids_num):
		if vector_for_randomize[i]:
			fetch(i).set_mine()
	
	for i in range(grids_num):	
		# store how many mines around an item, to avoid many search
		# though it's ok in the little project, but i don't like it.
		fetch(i).set_how_many_mines_around(get_around_mines_num(i))
		
func _on_mine_left_clicked(x, y):
	# when click an item first time, i should avoid he click the mine
	# the mine-board has no `state` before there
	if first_click:
		real_state_init(x, y)
		first_click = false

	var target = fetch(x, y)
	var mines_around = target.how_many_mines_around()
	
	if target.is_flagged():
		return
	elif target.is_mine():
		target.set_uncovered()
		target.left_click_transform()
		game_over()
		return
	elif target.uncovered():
		# implement click to uncover the around
		var around_flagged_mines_num = get_around_flagged_mines(x, y).size()
		if around_flagged_mines_num == mines_around:
			var around_items_should_click = get_around_covered(x, y)
			for i in around_items_should_click:
				_on_mine_left_clicked(i.get_x(), i.get_y())
		return
	
	# it's just an normal covered item.
	uncovered += 1
	target.set_uncovered()
	
	target.left_click_transform()
	if mines_around == 0:
		# no mines around, left-click them all. 
		var covered_items_around = get_around_covered(x, y)
		for item in covered_items_around:
			_on_mine_left_clicked(item.get_x(), item.get_y())
	
	if uncovered + MINES_NUM == grids_num:
		win()
		
func _on_mine_right_clicked(x, y):
	if first_click:
		return
		
	var target = fetch(x, y)
	if target.uncovered():
		return
		
	if target.is_flagged():
		target.remove_flagged()
		flagged_mines -= 1
	else:
		target.set_flagged()
		flagged_mines += 1
	target.right_click_transform()
	
	informational_container.set_mine_num(MINES_NUM - flagged_mines)
		
func _on_count_timer_timeout():
	time_count += 1
	
	informational_container.set_time_text(time_count)

func win():
	Win_Page.visible = true
	count_timer.disconnect("timeout", self, "_on_count_timer_timeout")
	
	
	Win_Page.connect("gui_input", self, "on_win_page_clicked")
		
func game_over():
	Lose_Page.visible = true
	count_timer.disconnect("timeout", self, "_on_count_timer_timeout")
	
	Lose_Page.get_node("Again").connect("pressed", self, "on_lose_page_again_clicked")
	Lose_Page.get_node("Exit").connect("pressed", self, "exit")
	
