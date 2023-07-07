extends Node

const game_scene = preload("res://Game.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	# Create game main scene
	add_child(game_scene.instantiate())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
