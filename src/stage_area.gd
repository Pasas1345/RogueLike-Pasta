extends Area2D

export var enemy_spawners: Array
export var item_spawners: Array
export var enemy_count: int

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_area1_body_entered(body:Node):
	if body == main_game.player:
		initiate_fight()


func initiate_fight():
	main_game.set_player_fighting(true)