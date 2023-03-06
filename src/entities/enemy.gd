extends Entity

@onready var player = get_tree().get_nodes_in_group("player")[0]
var attack_cooldown = 0.0
var attacking: Node
var area: Battle_Area

func _process(_delta):
	if dead:
		queue_free()

func _physics_process(delta):
	# print(delta)
	if attack_cooldown > 0:
		attack_cooldown -= delta

	if attacking != null:
		if attack_cooldown <= 0:
			attack_cooldown = 1 / attack_speed
			attacking.change_health(-attack)

	move_and_slide()
	

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
	
	randomize()
	var rand_chance = randf_range(0, 100)

	if rand_chance <= 5:
		var rand = randf_range(1, 2)
		if rand == 1:
			drop_item()
		else:
			drop_upgrade()


func drop_item():
	main_game.spawn_item("", self)

func drop_upgrade():
	main_game.spawn_upgrade("", self)