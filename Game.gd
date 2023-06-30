extends Control

const key_scene = preload("res://Key.tscn")

func create_key(path_follow:PathFollow2D, key_text:String):
	var new_key = key_scene.instantiate()
	new_key.call("set_button_text", key_text)
	new_key.rotation_degrees = -90
	new_key.position.y = 45
	path_follow.add_child(new_key)


# Called when the node enters the scene tree for the first time.
func _ready():
	create_key($Container/Center/Keyboard/PathA/KeyA, "原")
	create_key($Container/Center/Keyboard/PathB/KeyB, "神")
	create_key($Container/Center/Keyboard/PathC/KeyC, "启")
	create_key($Container/Center/Keyboard/PathD/KeyD, "动")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Container/Center/Keyboard/PathA/KeyA.progress_ratio += randi_range(0.5, 1) * delta
	$Container/Center/Keyboard/PathB/KeyB.progress_ratio += randi_range(0.5, 1) * delta
	$Container/Center/Keyboard/PathC/KeyC.progress_ratio += randi_range(0.5, 1) * delta
	$Container/Center/Keyboard/PathD/KeyD.progress_ratio += randi_range(0.5, 1) * delta
