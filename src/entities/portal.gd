extends Node2D

export var next_stage: int
export var stage_path: String

var active setget set_active

func set_active(act):
	active = act
	if act:
		visible = true
	else:
		visible = false

func _init():
	add_to_group("portal")

func _on_Area2D_body_entered(body: Node):
	if body == get_tree().get_nodes_in_group("player")[0] && active:
		main_game.stage_counter = next_stage
		print("portal entered")
		player_stats.sync_player_to_global()
		get_tree().change_scene("res://levels/{0}_{1}.tscn".format([stage_path, next_stage]))
