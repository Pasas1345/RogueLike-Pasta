extends Entity

export var UP_Regen: = 1.0
export var UP_EnergyRestore: = 10.0
export var inv_slots: = 4
export var item_strength = 1.0
export var acceleration: = 3.0
onready var max_acceleration: = acceleration
onready var max_speed: = speed
var direction: = Vector2.ZERO
onready var ui = get_tree().get_nodes_in_group("ui")[0]
onready var weapon = $Weapon

var attack_cooldown = 0.0

var inventory: = []

func _init():
	add_to_group("player")

func _ready():
	player_stats.sync_player_to_global()
	weapon.player = self

func _process(_delta):
	var _mouse_pos = get_global_mouse_position()
	if attack_cooldown > 0:
		attack_cooldown -= _delta
	# Handle Sprite Orientation
	if _mouse_pos.x - global_position.x < 0:
		weapon.position = Vector2(-25, 30)
		weapon.scale.y = -1
		_sprite.set_flip_h(true)
	else:
		weapon.position = Vector2(25, 30)
		weapon.scale.y = 1
		_sprite.set_flip_h(false)

	if Input.is_action_just_pressed("use_item"):
		if !inventory.empty():
			use_item(inventory[0])

	if Input.is_action_just_pressed("attack"):
		if attack_cooldown <= 0:
			attack_cooldown = 1 / attack_speed
			weapon._anim_player.set_speed_scale(attack_speed)
			weapon.start_attack()


func _physics_process(_delta):
	if !dead:
		direction = Vector2(Input.get_action_strength("move_right") - Input.get_action_strength("move_left"), Input.get_action_strength("move_down") - Input.get_action_strength("move_up"))
		var sprinting: = Input.is_key_pressed(KEY_SHIFT)
	
		if direction != Vector2(0, 0):
			if sprinting:
				max_speed = clamp(max_speed * 1.5, 0.0, speed * 1.5)
				acceleration = clamp(acceleration * 2.0, 0.0, max_acceleration * 2.0)
			else:
				max_speed = speed
				acceleration = max_acceleration
			
			velocity = velocity + (speed * (direction * (acceleration * _delta)))
			velocity = velocity.limit_length(max_speed)
		else:
			velocity = velocity.limit_length(0.0)
	else:
		velocity = Vector2.ZERO
		_sprite.modulate = Color(0.75, 0.25, 0.25)



func add_item(item: Item): 
	if inventory.size() >= inv_slots:
		return false

	var new_item = Item_Entry.new()
	new_item.item_id = item.item_id
	new_item.item_icon = item.item_icon

	inventory.push_back(new_item)
	ui.update_inventory()
	return true

func use_item(item: Item_Entry):
	var itemid = item.item_id

	match(itemid):
		"item_kokkoro":
			change_health(25)

	inventory.pop_front()
	ui.update_inventory()
	
func die():
	print("player death")
	_sprite.modulate = Color(0.75, 0.25, 0.25)
	dead = true

func update_stats():
	max_speed = speed
	max_acceleration = acceleration

class Item_Entry:
	var item_id: String
	var item_icon: Texture
