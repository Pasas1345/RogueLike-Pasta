extends Control

var player

@onready var health: = $health_bar/health_label_bg/health_label
@onready var health_bar := $health_bar/health_bar_bg
@onready var backpack_slots = $backpack_slots
@onready var fps := $fps_counter
@onready var pause_menu := $Pause_Menu
@onready var stage_label := $loop_stage_container/stage_label
@onready var loop_label := $loop_stage_container/loop_label
@onready var time_label := $time_label
@onready var loading_screen = $loading_screen
@onready var abiltiy_bar := $ability_bar/ability_bar_bg

func _init():
	add_to_group("ui")

func _ready() -> void:
	player = get_tree().get_nodes_in_group("player")[0]
	update_inventory()

	$loading_screen.visible = true
	var tween = create_tween().set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(loading_screen, "modulate", Color(0, 0, 0, 0), 0.4)
	await tween.finished
	$loading_screen.visible = false
	
# TODO : Move all the tweens in a seperate function. This is so that it doesn't go ballistic.

func _process(_delta) -> void:
	health.text = "{0}/{1}".format([clamp(player.hp, 0, player.max_hp), player.max_hp])

	fps.text = "FPS: {0}".format([Engine.get_frames_per_second()])
	
	if main_game.loop <= 0:
		loop_label.text = ""
		stage_label.text = "Stage {0}".format([main_game.stage_counter])
	else:
		loop_label.text = "Loop {0}".format([main_game.loop])
		stage_label.text = "Stage {0}".format([main_game.stage_counter])

	var time = main_game.game_time

	var seconds = time % 60
	var minutes = (time / 60) % 60

	time_label.text = "Elapsed Time:\n%02d:%02d" % [minutes, seconds]

	if Input.is_action_just_pressed("pause"):
		pause()

func _physics_process(_delta) -> void:
	var tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
	tween.set_parallel(true)
	tween.tween_property(abiltiy_bar, "size", Vector2(remap(player.ability_cooldown, 0, player.weapon.ability_cooldown_duration, 144, 0), 19), 0.25)

# Ah yes, optimzation. It does exist i swear...
var inv_sprites = []
var pending_deletion = []

func update_inventory() -> void:
	if player.inventory.is_empty():
		for n in inv_sprites:
			backpack_slots.remove_child(n)
			pending_deletion.push_back(n)

		inv_sprites.clear()

		for n in pending_deletion:
			n.queue_free()

		pending_deletion.clear()
	else:
		for n in inv_sprites:
			backpack_slots.remove_child(n)
			pending_deletion.push_back(n)
	
		inv_sprites.clear()
	
		for i in range(0, player.inventory.size()):
			var item_placement = backpack_slots.pivot_offset + Vector2(64, (i * 128) + 64)
			# inv_sprites.clear()
	
			var new_item_sprite = Sprite2D.new()
			backpack_slots.add_child(new_item_sprite)
			new_item_sprite.texture = player.inventory[i].item_icon
			new_item_sprite.position = item_placement
			new_item_sprite.scale = Vector2(0.8, 0.8)
			inv_sprites.push_back(new_item_sprite)
			# inv_sprites.push_back(inv_sprites)
			
		for n in pending_deletion:
			n.queue_free()
	
		pending_deletion.clear()


func update_health(h, mhp) -> void:
	if player != null:
		var tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
		tween.tween_property(health_bar, "size", Vector2(remap(h, 0, mhp, 0, 309), 49), 0.1)

func update_invslots(inv) -> void:
	if player != null:
		var tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(backpack_slots, "size", Vector2(128, 128 * inv), 1.0)

# Pause menu related stuff
func pause() -> void:
	if !main_game.can_pause:
		return

	if get_tree().paused:
		get_tree().paused = false
		pause_menu.visible = false
		$PauseBG.visible = false
		pause_menu.set_process(true)
	else:
		get_tree().paused = true
		pause_menu.visible = true
		$PauseBG.visible = true
		pause_menu.set_process(false)


func game_over() -> void:
	main_game.can_pause = false
	$Pause_Menu/resume.disabled = true
	pause_menu.visible = true
	pause_menu.set_process(true)
	$PauseBG.visible = true
	$Pause_Menu/title.text = "Game Over!"


