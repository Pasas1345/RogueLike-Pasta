extends CharacterBody2D
class_name Entity

@export var speed: = 200.0
@export var max_hp: = 100.0
@export var attack: = 10.0
@export var attack_speed: = 1.0
@export var defense: = 10.0
@export var ability_regen: = 1.0
@export var ability_strength: = 1.0
@export var invulnerable: = false

var hp = max_hp
var dead = false

@onready var _sprite: Sprite2D = $Sprite2D
@onready var _anim_player = $AnimationPlayer
@onready var _movement_anims = $MovementAnimation
# var velocity: = Vector2.ZERO

func _ready():
	print("New entity spawned! {0}".format([self]))

func _physics_process(_delta: float):
	if !dead:
		set_velocity(velocity)
		move_and_slide()
		
	# var _movement: = velocity

func change_health(health: float, true_damage: bool = false, from_attacker: Node2D = null):
	if dead || invulnerable: 
		return
		
	var health_change = health
	if health < 0 && !true_damage:
		health_change = floor(health_change * (1 + defense / 100))

	hp += health_change

	if hp > max_hp:
		hp = max_hp
	
	if health < 0 && !dead:
		if _anim_player != null:
			_anim_player.play("hit")

		spawn_damage_notif(health)
		_on_damaged(from_attacker)
	elif health > 0 && !dead:
		if _anim_player != null:
			_anim_player.play("heal")

	if hp <= 0:
		die()

func spawn_damage_notif(dmg: float):
	var new_dmgNotif = main_game.damage_notif.instantiate()

	new_dmgNotif.set_damage(dmg)
	new_dmgNotif.global_position = global_position
	get_tree().current_scene.add_child(new_dmgNotif)
	new_dmgNotif.begin()

func _on_damaged(_attacker):
	pass
		
func die():
	dead = true
