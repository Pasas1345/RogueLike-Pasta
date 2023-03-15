extends Node2D

@export var next_stage: int
@export var stage_path: String

@onready var animation: = $AnimationPlayer

var selected: bool = false : set = set_selected

var active : set = set_active

func set_active(act):
	active = act
	if act:
		visible = true
		$Sprite2D.scale = Vector2(0, 0)
		var tween = create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
		tween.tween_property($Sprite2D, "scale", Vector2(2.32, 2.32), 0.5)
	else:
		visible = false
		var tween = create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
		tween.tween_property($Sprite2D, "scale", Vector2(0, 0), 0.5)

func set_selected(select):
	selected = select

	if selected:
		var tween = create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
		tween.tween_property($Label, "scale", Vector2(1, 1), 0.5)
	else:
		var tween = create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
		tween.tween_property($Label, "scale", Vector2(0, 0), 0.5)

func _init():
	add_to_group("portal")

func _process(_delta):
	if selected && Input.is_action_just_pressed("interact") && active:
		teleport()

func _on_Area2D_body_entered(body: Node):
	if body == get_tree().get_nodes_in_group("player")[0] && active:
		set_selected(true)


func _on_Area2D_body_exited(body:Node):
	if body == get_tree().get_nodes_in_group("player")[0] && active:
		set_selected(false)
		

func teleport():
	main_game.stage_counter = next_stage
	$audio.play()
	# print("portal entered")
	player_stats.sync_player_to_global()
	animation.play("to_next_stage")
	main_game.can_pause = false
	if main_game.loop <= 0:
		$CanvasLayer/next_stage.text = "Stage {0}".format([main_game.stage_counter])
	else:
		$CanvasLayer/next_stage.text = "Loop {0}\nStage {1}".format([main_game.loop, main_game.stage_counter])
	await animation.animation_finished
	main_game.can_pause = true
	get_tree().change_scene_to_file("res://levels/{0}_{1}.tscn".format([stage_path, next_stage]))

