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
	set_target_location(target_pos)
	

func _physics_process(_delta):
	if is_navigation_finished():
		return
	
	parent.position = parent.position.move_toward(get_next_location(), _delta * parent.speed)

	if parent.position.direction_to(get_next_location()).x < 0:
		parent.get_node("Sprite").set_flip_h(true)
	elif parent.position.direction_to(get_next_location()).x > 0:
		parent.get_node("Sprite").set_flip_h(false)
	
