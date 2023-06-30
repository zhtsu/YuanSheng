extends Control

@export var button_text:String = "原":
	set = set_button_text
		

func set_button_text(new_text):
	button_text = new_text
	$Button.text = button_text


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
