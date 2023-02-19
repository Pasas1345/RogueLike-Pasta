extends Area2D
class_name Battle_Area

var enemy_spawners: Array
export var area_spawners_group: String
export var item_spawner: NodePath
export var door: NodePath
export var enemy_count: int
onready var enemies_left_area: int = enemy_count
var cleared: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	get_node(door).call_deferred("set_collision_layer_bit", 0, false)
	get_node(door).call_deferred("set_collision_mask_bit", 0, false)
	get_node(door).visible = false

	if get_tree().get_nodes_in_group(area_spawners_group).size() <= 0:
		printerr("Warning: Group name doesn't have any spawners. No spawning.")

	connect("body_entered", self, "_on_area1_body_entered")


func _on_area1_body_entered(body:Node):
	if body == main_game.player:
		initiate_fight()

func _process(_delta):
	if enemies_left_area <= 0 && !cleared:
		print("area cleared")
		end_fight()
		cleared = true
		

func initiate_fight():
	main_game.set_player_fighting(true)
	get_node(door).call_deferred("set_collision_layer_bit", 0, true)
	get_node(door).call_deferred("set_collision_mask_bit", 0, true)
	get_node(door).visible = true
	
	for _i in enemy_count:
		var e = main_game.spawn_enemy(null, get_tree().get_nodes_in_group(area_spawners_group))
		yield(get_tree().create_timer(0.25), "timeout")
		e.area = self

func end_fight():
	main_game.set_player_fighting(false)
	get_node(door).call_deferred("set_collision_layer_bit", 0, false)
	get_node(door).call_deferred("set_collision_mask_bit", 0, false)
	get_node(door).visible = false

	main_game.spawn_item("", get_node(item_spawner))
