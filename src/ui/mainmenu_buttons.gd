extends Control

@onready var play_button = $play
@onready var options_button = $options
@onready var quit_button = $quit
@onready var options_menu = get_parent().get_node("options_menu")

var options_enabled := false

func _on_play_pressed():
	main_game.stage_counter += 1
	get_tree().change_scene_to_file("res://levels/main_stages/stage_1.tscn")
	main_game.set_process(true)
	main_game.set_physics_process(true)


func _on_options_pressed():
	toggle_options()

func toggle_options():
	var tween := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	options_menu.update_settings()

	if options_enabled:
		options_enabled = false
	
		play_button.disabled = false
		quit_button.disabled = false
		options_button.text = "Options"
		
		# tween.set_parallel(true)
		tween.tween_property(options_menu, "modulate", Color(1.0, 1.0, 1.0, 0.0), 0.25)
		tween.tween_property(self, "position", Vector2(737.5, 340.5), 0.5)
		await tween.finished
		options_menu.visible = false
	else:
		options_enabled = true

		play_button.disabled = true
		quit_button.disabled = true
		options_button.text = "Close Options"
		options_menu.visible = true

		# tween.set_parallel(true)
		tween.tween_property(self, "position", Vector2(280, 340.5), 0.5)
		tween.tween_property(options_menu, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.25)


		
func _on_quit_pressed():
	get_tree().quit()
