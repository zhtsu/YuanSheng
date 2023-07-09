extends Control

signal reset
signal restart


func _on_restart_button_pressed():
	emit_signal("restart")
	queue_free()


func _on_quit_button_pressed():
	get_tree().quit()
