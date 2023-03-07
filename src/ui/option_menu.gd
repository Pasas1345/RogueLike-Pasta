extends Control

var to_apply_settings = {
	vsync = true,
	sfx_volume = 100,
	music_volume = 100
}

func update_settings():
	$TabContainer/Video/vsync.button_pressed = main_game.settings.vsync
	$TabContainer/Audio/sfx/HSlider.set_value_no_signal(main_game.settings.sfx_volume)
	$TabContainer/Audio/music/HSlider.set_value_no_signal(main_game.settings.music_volume)

func apply_settings():
	DisplayServer.window_set_vsync_mode(to_apply_settings.vsync)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), remap(to_apply_settings.sfx_volume, 0, 100, -36.0, 0))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), remap(to_apply_settings.music_volume, 0, 100, -36.0, 0))

	main_game.settings = to_apply_settings



###########
# BUTTONS #
###########
func _on_vsync_toggled(button_pressed: bool):
	to_apply_settings.vsync = button_pressed

func _on_apply_video_pressed():
	apply_settings()

func _on_sfx_value_changed(value: float):
	to_apply_settings.sfx_volume = value
	apply_settings()

func _on_music_value_changed(value: float):
	to_apply_settings.music_volume = value
	apply_settings()
