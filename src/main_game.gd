extends Node2D

var game_time: int

var stage_counter = 0
var timer
var stage_cleared = false
var spawner_delay = 0.0
var stage
var enemies_left

var enemy_nodes = {
	"kyaru": preload("res://entities/enemies/enemy.tscn")
}

func update_stage():
	stage = get_tree().get_nodes_in_group("main_stage")[0]
	enemies_left = stage.enemies

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
			spawn_enemy("kyaru")
			spawner_delay = rand_range(1.2, 2.5)
			stage.enemies -= 1

	if enemies_left <= 0 && !stage_cleared:
		stage_cleared = true
		stage_clear()
		

func advance_time():
	game_time += 1


func spawn_enemy(enemy_type: String):
	if !get_tree().get_nodes_in_group("spawners"):
		print("Warning: No spawners in stage detected. Spawning an enemy has failed.")
		return

	var enemy_spawners = get_tree().get_nodes_in_group("spawners")[0].get_children()
	var enemy

	match(enemy_type):
		_:
			enemy = enemy_nodes.kyaru


	var new_enemy = enemy.instance()
	new_enemy.set_position(enemy_spawners[rand_range(0, enemy_spawners.size())].position)
	new_enemy.add_to_group("enemies")
	enemy_spawners[0].get_parent().get_parent().add_child(new_enemy)

func reset():
	game_time = 0
	

func stage_clear():
	print("stage clear!")
	get_tree().get_nodes_in_group("portal")[0].set_active(true)