extends Node2D

var game_time: int

var stage_counter = 0
var timer: Timer
var stage_cleared: bool = false
var stage_custom_spawns: bool
var spawner_delay = 0.0
var stage: Stage
var enemies_left: int
var can_pause: bool = true
var player: Entity
var player_fighting: bool = false : set = set_player_fighting

var first_loop: bool = true
var loop: int = 0

enum EnemyTypes {
	KYARU,
	SLIME,
}


var enemy_nodes = {
	EnemyTypes.KYARU: preload("res://entities/enemies/enemy.tscn"),
	EnemyTypes.SLIME: preload("res://entities/enemies/slime.tscn")
}

var item_nodes = {
	"item_healpot": preload("res://entities/items/item_healpot.tscn"),
	"item_laser": preload("res://entities/items/item_laser.tscn")
}

func update_stage():
	stage = get_tree().get_nodes_in_group("main_stage")[0]
	player = get_tree().get_nodes_in_group("player")[0]
	enemies_left = stage.enemies
	stage_cleared = false
	stage_custom_spawns = stage.custom_spawns

	# print(player.music_player.playing_tracks.size())

	# await get_tree().create_timer(2.0).timeout

	# MusicController.music.init_song("transition")
	# MusicController.music.play("transition")

	if stage_custom_spawns:
		set_player_fighting(false)
	else:
		set_player_fighting(true)

	randomize()

func _ready():
	main_game.set_process(false)
	main_game.set_physics_process(false)
	timer = Timer.new()

	timer.set_wait_time(1.0)
	timer.set_one_shot(false)
	timer.set_autostart(true)
	timer.connect("timeout",Callable(self,"advance_time"))
	add_child(timer)

func _process(_delta):
	if !stage:
		return
	
	if !stage_custom_spawns:
		if spawner_delay > 0:
			spawner_delay -= _delta
	
		if stage.enemies > 0:
			if spawner_delay <= 0:
				spawn_enemy()
				spawner_delay = randf_range(1.2, 2.5)
				stage.enemies -= 1

	if enemies_left <= 0 && !stage_cleared:
		stage_cleared = true
		stage_clear()
		

func advance_time():
	if !stage:
		return

	game_time += 1


func spawn_enemy(enemy_type = null, spawner_array = null):
	if get_tree().get_nodes_in_group("spawners") == null:
		printerr("Warning: No spawners in stage detected. Spawning an enemy has failed.")
		return

	var enemy_spawners = get_tree().get_nodes_in_group("spawners")[0].get_children() if spawner_array == null else spawner_array
	var enemy

	match(enemy_type):
		EnemyTypes.KYARU:
			enemy = enemy_nodes[EnemyTypes.KYARU]
		EnemyTypes.SLIME:
			enemy = enemy_nodes[EnemyTypes.SLIME]
		_:
			randomize()
			var enemy_keys: Array = enemy_nodes.keys()
		
			enemy = enemy_nodes[enemy_keys[randi() % enemy_keys.size()]]


	var new_enemy = enemy.instantiate()
	new_enemy.set_position(enemy_spawners[randi() % enemy_spawners.size()].global_position)
	new_enemy.add_to_group("enemies")
	get_tree().current_scene.add_child(new_enemy)

	return new_enemy

func spawn_item(item_type = "", position: Node = null):
	if get_tree().get_nodes_in_group("item_spawner") == null && !position:
		printerr("Warning: No Item spawners in stage detected. No custom position added. Item drops will not spawn.")
		return

	var item_spawners = get_tree().get_nodes_in_group("item_spawner")[0].get_children()
	var item

	match(item_type):
		"item_kokkoro":
			item = item_nodes["item_kokkoro"]
		"item_laser":
			item = item_nodes["item_laser"]
		_:
			randomize()
			var item_keys: Array = main_game.item_nodes.keys()
		
			item = item_nodes[item_keys[randi() % item_keys.size()]]

	var new_item = item.instantiate()
	var spawner_index = randi() % item_spawners.size()

	if position:
		new_item.set_position(position.global_position)
	else:
		new_item.set_position(item_spawners[spawner_index].global_position)
		
	get_tree().current_scene.add_child(new_item)
	


func reset():
	stage = null
	player = null
	stage_counter = 0
	game_time = 0
	can_pause = true
	MusicController.stop_playing()

func stage_clear():
	print("stage clear!")

	if get_tree().get_nodes_in_group("portal") == null:
		printerr("Warning: No portal location in stage. Can't progress to next stage.")
		return

	if get_tree().get_nodes_in_group("portal").size() > 1:
		print("Warning: Only one portal location can exist. Please delete the other one as it will be unused forever.")

	if get_tree().get_nodes_in_group("item_spawner"):
		# print("xd")
		for i in get_tree().get_nodes_in_group("item_spawner")[0].get_children():
			spawn_item("", i)
	
	set_player_fighting(false)

	get_tree().get_nodes_in_group("portal")[0].set_active(true)

# TODO: Make the music blend in seamlessly. probably have to figure that out.
func set_player_fighting(fight):
	player_fighting = fight

	print("player fighting? {0}".format([player_fighting]))

	if player_fighting:
		print("playing battle music")
		# MusicController.stop_playing()
		# MusicController.create_transition("transition", "battle")
		MusicController.change_song("battle_full")
	else:
		print("playing chill music")
		MusicController.change_song("chill_full")
		
