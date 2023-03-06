extends Area2D
class_name Upgrade

@export var upgrade_id: String
@export var upgrade_icon: Texture2D


func _on_body_entered(body:Node2D):
	if body.name == "Player":
		body.upgrade_player(self)
		queue_free()
