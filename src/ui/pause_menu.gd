extends Container

@onready var parent := get_parent()

# Pause Menu Buttons.
func _on_resume_pressed():
	parent.pause()

func _on_main_menu_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://levels/main_menu.tscn")
	parent.get_node("Pause_Menu/title").text = "Game Paused"
	main_game.reset()

func _on_quit_pressed():
	get_tree().quit()
