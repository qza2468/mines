extends HBoxContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var time_now = $time_now
onready var mines_num = $mines_num


func _ready():
	pass

func set_time_text(seconds):
	var time_text = ""
	if seconds >= 3600:
		time_text += str(seconds / 3600)
		time_text += ":"
		seconds %= 3600
		
		if seconds / 60 < 10:
			time_text += "0"
		time_text += str(seconds / 60)
		time_text += ":"
		seconds %= 60
		
		if seconds / 60 < 10:
			time_text += "0"
		time_text += str(seconds)
	elif seconds >= 60:
		if seconds / 60 < 10:
			time_text += "0"
		time_text += str(seconds / 60)
		time_text += ":"
		seconds %= 60
		
		if seconds < 10:
			time_text += "0"
		time_text += str(seconds)
	else:
		time_text += str(seconds)
		
		
	time_now.text = str(time_text)
	
func set_mine_num(num):
	mines_num.text = str(num)
