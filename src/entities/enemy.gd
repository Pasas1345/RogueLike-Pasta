extends Entity
class_name Enemy

@export var player: Node2D
@onready var sprite := $Sprite2D
@onready var hit_particles := $HitParticles
var death_particle := preload("res://entities/death_particle.tscn")
var attack_cooldown: = 0.0
var attacking: Node
var area: Battle_Area
var bullet_shooter: Marker2D

func _ready():
	if player == null:
		player = get_tree().get_nodes_in_group("player")[0]
	if get_node_or_null("BulletShooter") != null:
		bullet_shooter = get_node_or_null("BulletShooter")
		
func _physics_process(delta):
	if !dead:
		# print(delta)
		if attack_cooldown > 0:
			attack_cooldown -= delta
	
		if attacking != null:
			if attack_cooldown <= 0:
				attack_cooldown = 1 / attack_speed
				attacking.change_health(-attack)
	
		move_and_slide()

	else:
		sprite.material.set_shader_parameter("solid_color", Color(1.0, 0, 0, 0.75))
		sprite.material.set_shader_parameter("flash", true)
	
func _on_PlayerDetector_body_entered(body:Node):
	if body == player:
		attacking = body

func _on_PlayerDetector_body_exited(_body:Node):
	attacking = null

func die():
	main_game.enemies_left -= 1
	# print(area)
	if area:
		area.enemies_left_area -= 1

	dead = true

	var tween = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "scale", Vector2(0.0, 0.0), 1.0)

	await tween.finished
	randomize()
	var rand_chance = randf_range(0, 100)

	if rand_chance <= 5:
		var rand = randf_range(0, 100)
		if rand <= 50:
			drop_item()
		else:
			drop_upgrade()
	
	var new_deathparticle = death_particle.instantiate()
	new_deathparticle.global_position = self.global_position
	get_tree().current_scene.add_child(new_deathparticle)
	queue_free()

func _on_damaged(_attacker):
	if _attacker == null:
		return

	if hit_particles != null:
		hit_particles.rotation = get_angle_to(_attacker.global_position) + PI
		hit_particles.emitting = true

func drop_item():
	main_game.spawn_item("", self)

func drop_upgrade():
	main_game.spawn_upgrade("", self)
