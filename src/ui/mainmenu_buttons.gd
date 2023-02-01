extends Control

onready var play_button = $play
onready var options_button = $options
onready var quit_button = $quit


func _on_play_pressed():
	get_tree().change_scene("res://levels/main_stages/stage_1.tscn")


func _on_options_pressed():
	pass # Replace with function body.


func _on_quit_pressed():
	get_tree().quit()
