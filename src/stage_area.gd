extends Area2D
class_name Battle_Area

var enemy_spawners: Array
@export var area_spawners_group: String
@export var item_spawner: NodePath
@export var door: NodePath
@export var enemy_count: int
@onready var enemies_left_area: int = enemy_count
var cleared: bool = false

func _ready():
	for d in get_node(door).get_children():
		d.collision_node.set_deferred("disabled", true)

	get_node(door).visible = false

	if get_tree().get_nodes_in_group(area_spawners_group).size() <= 0:
		printerr("Warning: Group name doesn't have any spawners. No spawning.")

	connect("body_entered",Callable(self,"_on_area1_body_entered"))

func _on_area1_body_entered(body:Node):
	if body == main_game.player && !cleared && !main_game.player_fighting:
		initiate_fight()

func _process(_delta):
	if enemies_left_area <= 0 && !cleared:
		print("area cleared")
		end_fight()
		cleared = true

func initiate_fight():
	main_game.set_player_fighting(true)
	for d in get_node(door).get_children():
		d.collision_node.set_deferred("disabled", false)
	get_node(door).visible = true
	
	for _i in enemy_count:
		var e = main_game.spawn_enemy(null, get_tree().get_nodes_in_group(area_spawners_group))
		await get_tree().create_timer(0.25).timeout
		e.area = self

func end_fight():
	main_game.set_player_fighting(false)
	for d in get_node(door).get_children():
		d.collision_node.set_deferred("disabled", true)
	get_node(door).visible = false

	main_game.spawn_item("", get_node(item_spawner))
