extends Node2D
class_name Stage

@export var enemies: int
@export var custom_spawns: bool

func _init():
	add_to_group("main_stage")

func _ready():
	var dungeon_gen: DungeonGrid = get_tree().get_first_node_in_group("dungeon_generator")
	if dungeon_gen != null:
		dungeon_gen.set_start(true)
		
	main_game.update_stage()
	
