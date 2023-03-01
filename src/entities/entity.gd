extends KinematicBody2D
class_name Entity

export var speed: = 200.0
export var max_hp: = 100.0
export var attack: = 10.0
export var attack_speed: = 1.0
export var defense: = 10.0
export var ability_regen: = 1.0
export var ability_strength: = 1.0

var hp = max_hp
var dead = false

onready var _sprite: Sprite = $Sprite
onready var _anim_player = $AnimationPlayer
onready var _movement_anims = $MovementAnimation
var velocity: = Vector2.ZERO

func _ready():
	print("New entity spawned! {0}".format([self]))

func _physics_process(_delta: float):
	var _movement: = move_and_slide(velocity)

func change_health(health: float):
	if dead: 
		return
		
	hp += health

	if hp > max_hp:
		hp = max_hp

	if hp <= 0:
		die()
	
	if health < 0 && !dead:
		_anim_player.play("hit")
	elif health > 0 && !dead:
		_anim_player.play("heal")
		
func die():
	dead = true
