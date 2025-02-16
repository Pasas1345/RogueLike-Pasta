extends Entity

@export var UP_Regen: = 1.0
@export var UP_EnergyRestore: = 10.0
@export var inv_slots: = 4 : set = set_inv_slots
@export var item_strength: = 1.0
@export var acceleration: = 0.1
@onready var max_acceleration: = acceleration
@onready var max_speed: = speed
var direction: = Vector2.ZERO
@onready var ui: = get_tree().get_nodes_in_group("ui")[0]
@onready var weapon: = $Weapon
@onready var items_effects: = $ItemAimer
@onready var stamina_bar: = $Stamina/StaminaBar

var max_stamina: float = 100
var stamina: float = max_stamina
var stamina_regen: float = 10.0
var stamina_consumtion: float = 20.0
var sprint_cooldown: bool = false

var is_using_item: bool = false
var is_attacking: bool = false
var bullet_invulnerable: bool = false

var attack_cooldown: float = 0.0
var ability_cooldown: float = 0.0

var casting_ability: bool = false

var inventory: Array = []

func _init() -> void:
	add_to_group("player")

func _ready() -> void:
	if main_game.stage_counter <= 1:
		player_stats.sync_player_to_global()
	else:
		player_stats.sync_global_to_player()


	weapon.player = self

func _process(_delta) -> void:
	# print(stamina)
	if dead:
		return
	
	var _mouse_pos = get_global_mouse_position()

	# Handle stamina here
	if sprint_cooldown:
		stamina_bar.material.set_shader_parameter('blinking', true)
		# material.set_shader_parameter("game_time", Time.get_ticks_msec() * _delta * 0.5)
	else:
		stamina_bar.material.set_shader_parameter('blinking', false)
		# material.set_shader_parameter("game_time", 0)

	if stamina <= 0:
		sprint_cooldown = true
	elif stamina >= max_stamina && sprint_cooldown:
		sprint_cooldown = false

	if stamina < max_stamina:
		var tween := create_tween().set_trans(Tween.TRANS_LINEAR)

		tween.set_parallel(true)
		tween.tween_property(stamina_bar, "modulate", Color(1, 1, 1, 1), 0.5)
		tween.tween_property(stamina_bar.get_parent(), "modulate", Color(1, 1, 1, 1), 0.5)
	else:
		var tween := create_tween().set_trans(Tween.TRANS_LINEAR)

		tween.set_parallel(true)
		tween.tween_property(stamina_bar, "modulate", Color(1, 1, 1, 0), 0.25)
		tween.tween_property(stamina_bar.get_parent(), "modulate", Color(1, 1, 1, 0), 0.25)


	stamina_bar.set_size(Vector2(7, remap(stamina, 0, max_stamina, 0, 57)))
	# stamina_bar.set_position(Vector2(1, (max_stamina / max_stamina) * 58))
	
	# Handle Sprite2D Orientation
	# if !is_attacking:
	if !casting_ability:
		if _mouse_pos.x - global_position.x < 0:
			weapon.position = Vector2(-25, 30)
			weapon.scale.y = -1
			_sprite.scale.x = -0.75
		else:
			weapon.position = Vector2(25, 30)
			weapon.scale.y = 1
			_sprite.scale.x = 0.75

	if Input.is_action_just_pressed("use_item"):
		if !inventory.is_empty() && !is_using_item:
			use_item(inventory[0])

	if Input.is_action_just_pressed("attack"):
		if attack_cooldown <= 0 && !casting_ability:
			# attack_cooldown = 1 / attack_speed
			weapon._anim_player.set_speed_scale(attack_speed)
			weapon.start_attack()

	if Input.is_action_just_pressed("ability"):
		if ability_cooldown <= 0:
			weapon.cast_ability(direction, get_physics_process_delta_time())

func _physics_process(_delta) -> void:
	if !dead:
		if attack_cooldown > 0:
			attack_cooldown -= _delta

		if ability_cooldown > 0:
			ability_cooldown -= _delta

		if !casting_ability:
			direction = get_direction()
			var sprinting: = Input.is_key_pressed(KEY_SHIFT)

			if sprint_cooldown:
				sprinting = false

			if !sprinting || direction == Vector2(0, 0):
				if stamina < max_stamina:
					stamina += _delta * stamina_regen
				if stamina >= max_stamina:
					stamina = max_stamina
		
			if direction != Vector2(0, 0):
				if sprinting && stamina > 0 && !sprint_cooldown:
					stamina -= _delta * stamina_consumtion
					max_speed = clamp(max_speed * 1.5, 0.0, speed * 1.5)
					acceleration = clamp(acceleration * 2.0, 0.0, max_acceleration * 2.0)
				else:
					max_speed = speed
					acceleration = max_acceleration
				
				velocity.x = lerp(velocity.x, direction.x * max_speed, acceleration)
				velocity.y = lerp(velocity.y, direction.y * max_speed, acceleration)
			else:
				velocity.x = lerp(velocity.x, 0.0, 0.25)
				velocity.y = lerp(velocity.y, 0.0, 0.25)
			
			velocity = velocity.limit_length(max_speed)
	else:
		velocity = Vector2.ZERO
		_sprite.modulate = Color(0.75, 0.25, 0.25)
		
	move_and_slide()


func get_direction() -> Vector2:
	return Vector2(Input.get_action_strength("move_right") - Input.get_action_strength("move_left"), Input.get_action_strength("move_down") - Input.get_action_strength("move_up"))

func add_item(item: Item) -> bool: 
	if inventory.size() >= inv_slots:
		return false

	var new_item = Item_Entry.new()
	new_item.item_id = item.item_id
	new_item.item_icon = item.item_icon

	inventory.push_back(new_item)
	ui.update_inventory()
	return true

func upgrade_player(upgrade: Upgrade) -> bool:
	match(upgrade.upgrade_id):
		"upgrade_backpack":
			if inv_slots >= 9:
				return false
			else:
				inv_slots += 1

	return true

func use_item(item: Item_Entry) -> void:
	var itemid = item.item_id
	# items_effects.visible = true
	is_using_item = true

	match(itemid):
		"item_healpot":
			change_health(floor(max_hp * (0.25 * item_strength)))
		"item_laser":
			items_effects.get_node("Laser_Item").set_is_casting(true)
			await get_tree().create_timer(5.0).timeout
			items_effects.get_node("Laser_Item").set_is_casting(false)

	inventory.pop_front()
	# items_effects.visible = false
	ui.update_inventory()
	is_using_item = false
	
func die() -> void:
	print("player death")
	_sprite.modulate = Color(0.75, 0.25, 0.25)
	dead = true
	ui.game_over()
	main_game.set_player_fighting(false)

func update_stats() -> void:
	max_speed = speed
	max_acceleration = acceleration

func _hp_changed(_health):
	hp = _health
	ui.update_health(_health, max_hp)

func set_inv_slots(_slots):
	inv_slots = _slots
	ui.update_invslots(inv_slots)

class Item_Entry:
	var item_id: String
	var item_icon: Texture2D
