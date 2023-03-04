extends NavigationAgent2D

var target
var target_pos
var path
var parent
var next_location

func _ready():
	parent = get_parent()
	target = get_tree().get_nodes_in_group("player")
	
func _process(_delta):
	target_pos = target[0].position
	target_position = target_pos
	

	if parent._movement_anims.has_animation("movement"):
		parent._movement_anims.play("movement")
	

func _physics_process(_delta):
	if is_target_reached():
		return
	
	parent.position = parent.position.move_toward(get_next_path_position(), _delta * parent.speed)

	if parent.position.direction_to(get_next_path_position()).x < 0:
		parent.get_node("Sprite2D").set_flip_h(true)
	elif parent.position.direction_to(get_next_path_position()).x > 0:
		parent.get_node("Sprite2D").set_flip_h(false)
	
