extends Control

signal destroy

@export var label_text:String = "原":
	set = set_label_text

func set_label_text(new_text):
	label_text = new_text
	$ColorRect/Label.text = label_text


# Called when the node enters the scene tree for the first time.
func _ready():
	$ColorRect.color = Color(
		randf_range(0, 0.6),
		randf_range(0, 0.6),
		randf_range(0.2, 0.5)
	)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

