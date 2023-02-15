extends Node2D

export var next_stage: int
export var stage_path: String

onready var animation: = $AnimationPlayer

var selected: bool = false setget set_selected

var active setget set_active

func set_active(act):
	active = act
	if act:
		visible = true
		$Sprite.scale = Vector2(0, 0)
		var tween = create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
		tween.tween_property($Sprite, "scale", Vector2(2.32, 2.32), 0.5)
	else:
		visible = false
		var tween = create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
		tween.tween_property($Sprite, "scale", Vector2(0, 0), 0.5)

func set_selected(select):
	selected = select

	if selected:
		var tween = create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
		tween.tween_property($Label, "rect_scale", Vector2(1, 1), 0.5)
	else:
		var tween = create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
		tween.tween_property($Label, "rect_scale", Vector2(0, 0), 0.5)

func _init():
	add_to_group("portal")

func _process(_delta):
	if Input.is_action_just_pressed("interact") && active && selected:
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
	yield(animation, "animation_finished")
	main_game.can_pause = true
	get_tree().change_scene("res://levels/{0}_{1}.tscn".format([stage_path, next_stage]))

