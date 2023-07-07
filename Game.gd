extends Control

const KEY_SCENE = preload("res://Key.tscn")
const NEXT_PROGRESS = {
	128: 258,
	258: 388,
	388: 518,
	518: 648,
	648: 0,
	0: 128
}

var key_speed = 10
var words_dict = {}
var next_created_key_number = 0


func _create_key(path:Path2D, key_text:String, progress:int = 0):
	var new_key = KEY_SCENE.instantiate()
	new_key.call("set_label_text", key_text)
	new_key.rotation_degrees = -90
	new_key.position.y = 45
	var follow = PathFollow2D.new()
	follow.progress = progress
	follow.add_child(new_key)
	path.add_child(follow)


func _down_keys():
	for follow in $Container/Center/Keyboard/PathA.get_children():
		follow.progress = NEXT_PROGRESS.get(int(follow.progress))
	for follow in $Container/Center/Keyboard/PathB.get_children():
		follow.progress = NEXT_PROGRESS.get(int(follow.progress))
	for follow in $Container/Center/Keyboard/PathC.get_children():
		follow.progress = NEXT_PROGRESS.get(int(follow.progress))
	for follow in $Container/Center/Keyboard/PathD.get_children():
		follow.progress = NEXT_PROGRESS.get(int(follow.progress))


func _gen_path_pool():
	var follow_pool = [
		$Container/Center/Keyboard/PathA,
		$Container/Center/Keyboard/PathB,
		$Container/Center/Keyboard/PathC,
		$Container/Center/Keyboard/PathD
	]
	return follow_pool

# Called when the node enters the scene tree for the first time.
func _ready():
	var words_file = FileAccess.open("res://Assets/words.txt", FileAccess.READ)
	var words = words_file.get_as_text()
	for i in range(words.length()):
		words_dict[i] = words[i]
	words_file.close()
	
	var path_pool = _gen_path_pool()
	for i in range(5):
		if path_pool.is_empty():
			path_pool = _gen_path_pool()
		var path = path_pool.pick_random()
		var word_number = next_created_key_number
		var progress = 648 - (word_number * 130)
		print(progress)
		_create_key(path, words_dict.get(word_number), progress)
		path_pool.erase(path)
		next_created_key_number += 1
		
	$AnimationPlayer.play("Begin")
	


func _create_next_key():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_d_button_pressed():
	_down_keys()


func _on_f_button_pressed():
	pass # Replace with function body.


func _on_j_button_pressed():
	pass # Replace with function body.


func _on_k_button_pressed():
	pass # Replace with function body.
