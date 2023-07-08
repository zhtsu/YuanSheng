extends Control

signal game_over
signal game_start

const KEY_SCENE = preload("res://Key.tscn")
const NEXT_PROGRESS = {
	128: 258,
	258: 388,
	388: 518,
	518: 648,
	648: 0,
	0: 128
}
const MAX_WORD_COUNT = 134

var PATH_DICT

var key_speed = 10
var words_dict = {}
var next_created_follow_number = 0
var current_follow_queue = []
# A follow-path for every follow
var current_follow_path_queue = []


# Called when the node enters the scene tree for the first time.
func _ready():
	PATH_DICT = {
		"D": $Container/Center/Keyboard/PathD,
		"F": $Container/Center/Keyboard/PathF,
		"J": $Container/Center/Keyboard/PathJ,
		"K": $Container/Center/Keyboard/PathK
	}
	
	var words_file = FileAccess.open("res://Assets/words.txt", FileAccess.READ)
	var words = words_file.get_as_text()
	for i in range(words.length()):
		words_dict[i] = words[i]
	words_file.close()
	
	var path_key_pool = _gen_path_key_pool()
	for i in range(5):
		if path_key_pool.is_empty():
			path_key_pool = _gen_path_key_pool()
		var path_key = path_key_pool.pick_random()
		var path = PATH_DICT.get(path_key)
		var word_number = next_created_follow_number
		var progress = 648 - (word_number * 130)
		var new_follow = _create_key(path, words_dict.get(word_number), progress)
		current_follow_queue.append(new_follow)
		current_follow_path_queue.append(path_key)
		path_key_pool.erase(path_key)
		next_created_follow_number += 1
	
	$AnimationPlayer.play("Begin")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


# Create a new follow to include a new key scene, and return the new follow
func _create_key(path:Path2D, key_text:String, progress:int = 0):
	var new_key = KEY_SCENE.instantiate()
	new_key.call("set_label_text", key_text)
	new_key.rotation_degrees = -90
	new_key.position.y = 45
	var follow = PathFollow2D.new()
	follow.progress = progress
	follow.add_child(new_key)
	path.add_child(follow)
	return follow


func _down_keys():
	_destroy_bottom_key()
	if next_created_follow_number < MAX_WORD_COUNT:
		_create_next_follow()
	else:
		emit_signal("game_over")
	
	for follow in $Container/Center/Keyboard/PathD.get_children():
		follow.progress = NEXT_PROGRESS.get(int(follow.progress))
	for follow in $Container/Center/Keyboard/PathF.get_children():
		follow.progress = NEXT_PROGRESS.get(int(follow.progress))
	for follow in $Container/Center/Keyboard/PathJ.get_children():
		follow.progress = NEXT_PROGRESS.get(int(follow.progress))
	for follow in $Container/Center/Keyboard/PathK.get_children():
		follow.progress = NEXT_PROGRESS.get(int(follow.progress))


func _gen_path_key_pool():
	var path_key_pool = ["D", "F", "J", "K"]
	return path_key_pool


func _is_correct_keydown(path_key:String):
	if not current_follow_path_queue.is_empty():
		return current_follow_path_queue.front() == path_key
	return false


func _destroy_bottom_key():
	if not current_follow_queue.is_empty():
		var deleted_follow = current_follow_queue.front()
		current_follow_queue.erase(current_follow_queue.front())
		deleted_follow.queue_free()
		
	if not current_follow_path_queue.is_empty():
		current_follow_path_queue.erase(current_follow_path_queue.front())


func _create_next_follow():
	var path_key_pool = _gen_path_key_pool()
	var path_key = path_key_pool.pick_random()
	var word = words_dict.get(next_created_follow_number)
	var new_follow = _create_key(PATH_DICT.get(path_key), word)
	current_follow_queue.append(new_follow)
	current_follow_path_queue.append(path_key)
	next_created_follow_number += 1


func _on_d_button_pressed():
	if _is_correct_keydown("D"):
		pass
	_down_keys()


func _on_f_button_pressed():
	if _is_correct_keydown("F"):
		pass
	_down_keys()


func _on_j_button_pressed():
	if _is_correct_keydown("J"):
		pass
	_down_keys()


func _on_k_button_pressed():
	if _is_correct_keydown("K"):
		pass
	_down_keys()


func _game_over():
	pass
