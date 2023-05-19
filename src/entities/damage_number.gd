extends Node2D

@export var damage: float

@onready var _anim: AnimationPlayer = $Animation
@onready var _label: Label = $Label

func _ready():
	_label.text = "{0}".format([damage])
	_anim.play("damage")