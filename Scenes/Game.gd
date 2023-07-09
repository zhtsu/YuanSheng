extends Control

signal game_over
signal game_start

const KEY_SCENE = preload("res://Scenes/Key.tscn")
const END_SCENE = preload("res://Scenes/End.tscn")
const NEXT_PROGRESS = {
	128: 258,
	258: 388,
	388: 518,
	518: 648,
	648: 0,
	0: 128
}
const MAX_WORD_COUNT = 134

var path_dict = {}
var words_dict = {}
var pinyin_dict = {}

var game_timer = 0
var start_timer = 3
var next_created_follow_number = 0
var keydown_count = 0
var correct_word_count = 0
var current_follow_queue = []
# A follow-path for every follow
var current_follow_path_queue = []


# Called when the node enters the scene tree for the first time.
func _ready():
	var words_file = FileAccess.open("res://Assets/words.txt", FileAccess.READ)
	var words = words_file.get_as_text()
	for i in range(words.length()):
		words_dict[i] = words[i]
	words_file.close()
	
	var pinyin_file = FileAccess.open("res://Assets/pinyin.json", FileAccess.READ)
	pinyin_dict = JSON.parse_string(pinyin_file.get_as_text())
	words_file.close()
	
	_reset_game()
	
	$AnimationPlayer.play("Begin")


func _clear_follows():
	for follow in $Container/Center/Keyboard/PathD.get_children():
		follow.queue_free()
	for follow in $Container/Center/Keyboard/PathF.get_children():
		follow.queue_free()
	for follow in $Container/Center/Keyboard/PathJ.get_children():
		follow.queue_free()
	for follow in $Container/Center/Keyboard/PathK.get_children():
		follow.queue_free()


func _reset_game():
	$Container/Right/Collection/Words.clear()
	
	_disable_buttons()
	
	path_dict = {
		"D": $Container/Center/Keyboard/PathD,
		"F": $Container/Center/Keyboard/PathF,
		"J": $Container/Center/Keyboard/PathJ,
		"K": $Container/Center/Keyboard/PathK
	}
	game_timer = 0
	start_timer = 3
	next_created_follow_number = 0
	keydown_count = 0
	correct_word_count = 0
	
	_clear_follows()
	current_follow_queue = []
	current_follow_path_queue = []
	
	var path_key_pool = _gen_path_key_pool()
	for i in range(5):
		if path_key_pool.is_empty():
			path_key_pool = _gen_path_key_pool()
		var path_key = path_key_pool.pick_random()
		var path = path_dict.get(path_key)
		var word_number = next_created_follow_number
		var progress = 648 - (word_number * 130)
		var new_follow = _create_key(path, words_dict.get(word_number), progress)
		current_follow_queue.append(new_follow)
		current_follow_path_queue.append(path_key)
		path_key_pool.erase(path_key)
		next_created_follow_number += 1


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
	var new_follow = _create_key(path_dict.get(path_key), word)
	current_follow_queue.append(new_follow)
	current_follow_path_queue.append(path_key)
	next_created_follow_number += 1


func _is_correct_keydown(path_key:String):
	if not current_follow_path_queue.is_empty():
		return current_follow_path_queue.front() == path_key
	return false


func _handle_keydown(path_key:String):
	if _is_correct_keydown(path_key):
		var word = words_dict.get(keydown_count)
		var pinyin = pinyin_dict.get(word)
		$Container/Right/Collection/Words.append_text(word)
		await $PinyinPlayer.play_pinyin_audio(pinyin)
		correct_word_count += 1
	else:
		$Container/Right/Collection/Words.append_text("X")
		await $PinyinPlayer.play_pinyin_audio("error")
	
	keydown_count += 1
	
	if keydown_count == MAX_WORD_COUNT:
		emit_signal("game_over")
		
	# Update accuracy
	var format_string = "%d%%"
	var rate
	if correct_word_count == 0:
		rate = 0
	else:
		rate = float(correct_word_count) / float(keydown_count)
	$Container/Right/Accuracy.text = format_string % [int(rate * 100)]
	

func _on_d_button_pressed():
	_handle_keydown("D")
	_down_keys()


func _on_f_button_pressed():
	_handle_keydown("F")
	_down_keys()


func _on_j_button_pressed():
	_handle_keydown("J")
	_down_keys()


func _on_k_button_pressed():
	_handle_keydown("K")
	_down_keys()


func _disable_buttons():
	$Container/Left/Power/VBoxContainer2/RestartButton.disabled = true
	$Container/Left/Power/VBoxContainer2/ButtonBar/DButton.disabled = true
	$Container/Left/Power/VBoxContainer2/ButtonBar/FButton.disabled = true
	$Container/Left/Power/VBoxContainer2/ButtonBar/JButton.disabled = true
	$Container/Left/Power/VBoxContainer2/ButtonBar/KButton.disabled = true


func _enable_buttons():
	$Container/Left/Power/VBoxContainer2/RestartButton.disabled = false
	$Container/Left/Power/VBoxContainer2/ButtonBar/DButton.disabled = false
	$Container/Left/Power/VBoxContainer2/ButtonBar/FButton.disabled = false
	$Container/Left/Power/VBoxContainer2/ButtonBar/JButton.disabled = false
	$Container/Left/Power/VBoxContainer2/ButtonBar/KButton.disabled = false


func _game_over():
	_disable_buttons()
	$GameTimer.stop()
	$AnimationPlayer.play("End")
	var game_over_scene = END_SCENE.instantiate()
	game_over_scene.connect("restart", _on_restart_button_pressed)
	add_child(game_over_scene)
	

func _game_start():
	_enable_buttons()
	$StartMask.hide()
	$GameTimer.start()


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "Begin":
		$StartTimer.start()


func _on_start_timer_timeout():
	start_timer -= 1
	$StartMask/Count.text = str(start_timer)
	if start_timer == 0:
		emit_signal("game_start")
		$StartMask/Count.text = "3"
		$StartTimer.stop()


func _on_game_timer_timeout():
	game_timer += 1
	var minute = game_timer / 60
	var second = game_timer - (minute * 60)
	var format_string = "%02d:%02d"
	$Container/Right/Timer.text = format_string % [minute, second]


func _on_restart_button_pressed():
	_reset_game()
	$StartMask.show()
	$AnimationPlayer.play("Begin")
