extends Node

var song_list: Array
var current_playing_idx

func _ready():
	song_list = get_children()


func get_song_index(song):
	if typeof(song) == TYPE_STRING:
		var s = get_node(song)
		if s != null:
			return s.get_index()
	else:
		return song

func fade_out(song, fade: float):
	var song_idx = get_song_index(song)
	var target_song = song_list[song_idx]
	var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	tween.tween_property(target_song, "volume_db", -65.0, fade)
	yield(get_tree().create_timer(fade), "timeout")
	target_song.stop()

	return fade

func fade_in(song, fade: float):
	var song_idx = get_song_index(song)
	var target_song = song_list[song_idx]
	var tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	tween.tween_property(target_song, "volume_db", 0.0, fade)
	
	return fade

func change_song(song):
	var song_idx = get_song_index(song)

	if current_playing_idx == song_idx:
		return

	song_list[current_playing_idx].stop()
	play_song(song_idx)


func play_song(song):
	var song_idx = get_song_index(song)
	song_list[song_idx].play()
	current_playing_idx = song_idx

func create_transition(transition_song, song):
	var song_idx = get_song_index(song)
	var transition_song_idx = get_song_index(transition_song)

	play_song(transition_song_idx)
	# print(song_list[transition_song_idx].stream.get_length())
	yield(get_tree().create_timer(song_list[transition_song_idx].stream.get_length() + 0.055), "timeout")
	play_song(song_idx)

func stop_playing():
	if !current_playing_idx:
		return

	song_list[current_playing_idx].stop()
