extends Node2D

onready var _weapon_sprite := $Pivot/PecorineSword
onready var _anim_player := $Pivot/AnimationPlayer
onready var _pivot := $Pivot
var player
var attackable = []
# TODO: Probably set up attack sequences...
# 		With that, we can probably have a variable handling attack animations.

export var attack_sequence := 0
export var can_next_sequence := false

var attack_seq_multipliers := [
	1.0,
	0.8,
	1.5,
	1.15,
	1.35
]

func _process(_delta):
	player.is_attacking = _anim_player.is_playing()
	
	if attack_sequence > 0 && !player.is_attacking:
		player.attack_cooldown = 1 / player.attack_speed
		attack_sequence = 0

func _physics_process(_delta):
	# if !player.is_attacking:
	look_at(get_global_mouse_position())

func start_attack():
	if attack_sequence >= attack_seq_multipliers.size():
		attack_sequence = attack_seq_multipliers.size()

	if attack_sequence <= 0:
		_anim_player.play("attack1")
		attack_sequence += 1

	if can_next_sequence:
		_anim_player.play("attack{0}".format([attack_sequence + 1]))
		attack_sequence += 1


func _on_hitbox_body_entered(body:Node):
	if body.has_method("change_health") && body != player:
		# print("hit")
		body.change_health(-player.attack * attack_seq_multipliers[attack_sequence - 1])
