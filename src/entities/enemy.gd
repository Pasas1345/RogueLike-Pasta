extends Entity

onready var player = get_tree().get_nodes_in_group("player")[0]
var attack_cooldown = 0.0
var attacking: Node

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
			attacking.change_health(-10)
	

func _on_PlayerDetector_body_entered(body:Node):
	if body == player:
		attacking = body

func _on_PlayerDetector_body_exited(_body:Node):
	attacking = null
