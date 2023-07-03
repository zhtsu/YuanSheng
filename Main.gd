extends Node

const game_scene = preload("res://Game.tscn")

var Words = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	var WordsFile = FileAccess.open("res://Assets/words.txt", FileAccess.READ)
	print_debug(WordsFile.get_as_text())
	WordsFile.close()
	# Create game main scene
	add_child(game_scene.instantiate())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
