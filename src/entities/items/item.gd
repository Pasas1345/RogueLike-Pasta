extends Area2D
class_name Item

@export var item_id: = "item_kokkoro"
@export var item_icon: Texture2D

@onready var _sprite = $Sprite2D

func _ready():
	if !item_icon:
		item_icon = _sprite.texture

	print("New item spawned! Item ID {0}".format([self.item_id]))


func _on_Item_body_entered(body: Node2D):
	if body.name == "Player":
		if body.add_item(self):
			get_tree().queue_delete(self)
