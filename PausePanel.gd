extends Panel


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var Resume_Button = $Button

var quotes

# Called when the node enters the scene tree for the first time.
func _ready():
	var f = File.new()
	f.open("res://assets/quotes.txt", File.READ)
	var quotes_s = f.get_as_text()
	f.close()
	quotes = quotes_s.rsplit("\n", false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func on_pause():
	get_tree().paused = true
	visible = true
	$Saying.text = quotes[rand_range(0, quotes.size() - 1)]
	Resume_Button.connect("pressed", self, "on_resume")
	
func on_resume():
	get_tree().paused = false
	visible = false
	Resume_Button.disconnect("pressed", self, "on_resume")
