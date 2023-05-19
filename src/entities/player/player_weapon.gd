extends Node2D
class_name Player_Weapon

@onready var _weapon_sprite := $Pivot/PecorineSword
@onready var _anim_player := $Pivot/AnimationPlayer
@onready var _pivot := $Pivot
@onready var _ability_hitbox := $ability_hitbox/ability_hitbox_collision
var player
# var attackable = []

@export var attack_sequence := 0
@export var can_next_sequence := false

@export var dash_length := 0.25
@export var ability_damage := 45
@export var ability_cooldown_duration := 8.5

var attack_seq_multipliers := [
	1.0,
	0.8,
	1.5,
	0.75,
	1.35
]

func _process(_delta):
	player.is_attacking = _anim_player.is_playing()
	
	if attack_sequence > 0 && !player.is_attacking:
		player.attack_cooldown = 1 / player.attack_speed
		attack_sequence = 0

func _physics_process(_delta):
	if !player.dead && !player.casting_ability:
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

func cast_ability(dash_direction: Vector2, _delta: float):
	if dash_direction == Vector2.ZERO:
		return

	player.invulnerable = true
	player.ability_cooldown = ability_cooldown_duration
	player.casting_ability = true
	_ability_hitbox.disabled = false

	player.direction = dash_direction
	player.velocity = dash_direction.normalized() * (player.speed * 1000) * _delta

	await get_tree().create_timer(0.1).timeout

	player.direction = Vector2.ZERO
	player.velocity = Vector2.ZERO
	_ability_hitbox.disabled = true

	_anim_player.play("ability")
	await _anim_player.animation_finished

	player.casting_ability = false
	await get_tree().create_timer(0.25).timeout
	player.invulnerable = false

func _on_hitbox_body_entered(body: Node):
	if body.has_method("change_health") && body != player:
		if !player.casting_ability:
			body.change_health(-player.attack * attack_seq_multipliers[attack_sequence - 1], false, true, self)
		else:
			body.change_health(-ability_damage * player.ability_strength, false, true, self)

func _on_ability_hitbox_body_entered(body: Node2D):
	if body.has_method("change_health") && body != player:
		body.change_health(-ability_damage * player.ability_strength, false, true, self)
