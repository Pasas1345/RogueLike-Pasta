extends Node2D

onready var _weapon_sprite = $Pivot/PecorineSword
onready var _anim_player = $Pivot/AnimationPlayer
onready var _pivot = $Pivot
var player
var attackable = []

func _physics_process(_delta):
	look_at(get_global_mouse_position())

func start_attack():
	_anim_player.play("attack")


func _on_hitbox_body_entered(body:Node):
	if body.has_method("change_health") && body != player:
		# print("hit")
		body.change_health(-player.attack)
