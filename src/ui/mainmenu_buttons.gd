extends Control

@onready var play_button = $play
@onready var options_button = $options
@onready var quit_button = $quit


func _on_play_pressed():
	main_game.stage_counter += 1
	get_tree().change_scene_to_file("res://levels/main_stages/stage_1.tscn")
	main_game.set_process(true)
	main_game.set_physics_process(true)


func _on_options_pressed():
	pass # Replace with function body.


func _on_quit_pressed():
	get_tree().quit()
