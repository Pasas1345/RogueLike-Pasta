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

var first_loop: bool = true
var loop: int = 0

enum EnemyTypes {
	KYARU,
}


var enemy_nodes = {
	EnemyTypes.KYARU: preload("res://entities/enemies/enemy.tscn")
}

var item_nodes = {
	"item_kokkoro": preload("res://entities/items/item_kokkoro.tscn"),
	"item_laser": preload("res://entities/items/item_laser.tscn")
}

func update_stage():
	stage = get_tree().get_nodes_in_group("main_stage")[0]
	enemies_left = stage.enemies
	stage_cleared = false
	randomize()

func _ready():
	main_game.set_process(false)
	main_game.set_physics_process(false)
	timer = Timer.new()

	timer.set_wait_time(1.0)
	timer.set_one_shot(false)
	timer.set_autostart(true)
	timer.connect("timeout", self, "advance_time")
	add_child(timer)

func _process(_delta):
	if !stage:
		return
	
	if spawner_delay > 0:
		spawner_delay -= _delta

	if stage.enemies > 0:
		if spawner_delay <= 0:
			spawn_enemy(EnemyTypes.KYARU)
			spawner_delay = rand_range(1.2, 2.5)
			stage.enemies -= 1

	if enemies_left <= 0 && !stage_cleared:
		stage_cleared = true
		stage_clear()
		

func advance_time():
	if !stage:
		return

	game_time += 1


func spawn_enemy(enemy_type):
	if !get_tree().get_nodes_in_group("spawners"):
		printerr("Warning: No spawners in stage detected. Spawning an enemy has failed.")
		return

	var enemy_spawners = get_tree().get_nodes_in_group("spawners")[0].get_children()
	var enemy

	match(enemy_type):
		_:
			enemy = enemy_nodes[EnemyTypes.KYARU]


	var new_enemy = enemy.instance()
	new_enemy.set_position(enemy_spawners[randi() % enemy_spawners.size()].position)
	new_enemy.add_to_group("enemies")
	get_tree().current_scene.add_child(new_enemy)

func spawn_item(item_type = "", position = null):
	if !get_tree().get_nodes_in_group("item_spawner"):
		printerr("Warning: No Item spawners in stage detecte. Item drops will not spawn.")
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

	var new_item = item.instance()
	var spawner_index = randi() % item_spawners.size() if position == null else position
	new_item.set_position(item_spawners[spawner_index].position)
	get_tree().current_scene.add_child(new_item)
	


func reset():
	stage = null
	stage_counter = 0
	game_time = 0

func stage_clear():
	print("stage clear!")

	if !get_tree().get_nodes_in_group("portal"):
		printerr("Warning: No portal location in stage. Can't progress to next stage.")
		return

	if get_tree().get_nodes_in_group("portal").size() > 1:
		print("Warning: Only one portal location can exist. Please delete the other one as it will be unused forever.")

	if get_tree().get_nodes_in_group("item_spawner"):
		# print("xd")
		for i in get_tree().get_nodes_in_group("item_spawner")[0].get_children().size():
			spawn_item("", i)
			

	get_tree().get_nodes_in_group("portal")[0].set_active(true)
