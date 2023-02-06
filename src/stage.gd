extends Node2D
class_name Stage

export var enemies: int

func _init():
	add_to_group("main_stage")

func _ready():
	main_game.update_stage()