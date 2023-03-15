extends Marker2D

@onready var parent = get_parent()

var atk_cooldown = 0.0
@export var bullet: PackedScene

func _physics_process(delta):
	if atk_cooldown > 0:
		atk_cooldown -= delta

	if atk_cooldown <= 0:
		atk_cooldown = 1 / parent.attack_speed

		create_bullet(parent.attack_speed * 300, parent.attack, true)

func create_bullet(spd: float, dmg: float, oneshot: bool):
	var new_bullet = bullet.instantiate()

	new_bullet.set_speed(spd) 
	new_bullet.set_damage(dmg)
	new_bullet.set_oneshot(oneshot)

	new_bullet.global_position = global_position

	get_tree().current_scene.add_child(new_bullet)
