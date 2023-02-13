extends Control

var player

onready var health: = $health_label_bg/health_label
onready var health_bar := $health_bar/health_bar_bg
onready var backpack_slots = $backpack_slots
onready var fps = $fps_counter
onready var pause_menu = $Pause_Menu
onready var stage_label := $loop_stage_container/stage_label
onready var loop_label := $loop_stage_container/loop_label
onready var time_label := $time_label

func _init():
	add_to_group("ui")

func _ready():
	Engine.set_target_fps(int(OS.get_screen_refresh_rate() * 3.0))
	player = get_tree().get_nodes_in_group("player")[0]
	update_inventory()

	$loading_screen.visible = true
	var tween = create_tween().set_trans(Tween.TRANS_LINEAR)
	tween.tween_property($loading_screen, "modulate", Color(0, 0, 0, 0), 0.4)
	yield(tween, "finished")
	$loading_screen.visible = false
	
	
func _process(_delta):
	health.text = "{0}/{1}".format([clamp(player.hp, 0, player.max_hp), player.max_hp])

	var healthbar_tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
	healthbar_tween.tween_property(health_bar, "rect_size", Vector2(range_lerp(player.hp, 0, player.max_hp, 0, 309), 49), 0.1)

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
	

	backpack_slots.set_size(Vector2(128, 128 * player.inv_slots))

	if Input.is_action_just_pressed("pause"):
		pause()
			

# Ah yes, optimzation. It does exist i swear...
var inv_sprites = []
var pending_deletion = []

func update_inventory():
	if player.inventory.empty():
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
			var item_placement = backpack_slots.rect_pivot_offset + Vector2(64, (i * 128) + 64)
			# inv_sprites.clear()
	
			var new_item_sprite = Sprite.new()
			backpack_slots.add_child(new_item_sprite)
			new_item_sprite.texture = player.inventory[i].item_icon
			new_item_sprite.position = item_placement
			new_item_sprite.scale = Vector2(0.8, 0.8)
			inv_sprites.push_back(new_item_sprite)
			# inv_sprites.push_back(inv_sprites)
			
		for n in pending_deletion:
			n.queue_free()
	
		pending_deletion.clear()

		

# Pause menu related stuff
func pause():
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


# Pause Menu Buttons.
func _on_resume_pressed():
	pause()

func _on_main_menu_pressed():
	get_tree().paused = false
	get_tree().change_scene("res://levels/main_menu.tscn")
	main_game.reset()

func _on_quit_pressed():
	get_tree().quit()
