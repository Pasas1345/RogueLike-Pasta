extends Marker2D

@onready var parent = get_parent()

var atk_cooldown = 0.0
@export var bullet: PackedScene
@export var filter: Node2D

func _physics_process(delta):
	rotation = parent.rotation
	if atk_cooldown > 0:
		atk_cooldown -= delta

	if atk_cooldown <= 0:
		atk_cooldown = 1 / parent.attack_speed

		create_bullet(parent.attack_speed * 300, parent.attack, true)

func create_bullet(spd: float, dmg: float, oneshot: bool):
	var new_bullet = bullet.instantiate()

	new_bullet.set_speed(spd) 
	new_bullet.set_damage(dmg)
	new_bullet.set_one_shot(oneshot)
	if filter != null: 
		new_bullet.set_filter(filter)

	new_bullet.global_position = global_position
	new_bullet.rotation = rotation

	get_tree().current_scene.add_child(new_bullet)

	# new_bullet.expire()s
