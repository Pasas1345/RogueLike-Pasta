extends Node2D
class_name Stage

export var enemies: int
export var custom_spawns: bool

func _init():
	add_to_group("main_stage")

func _ready():
	main_game.update_stage()