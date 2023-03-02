# tool
extends TileMap

func _process(_delta):
	tile_set.tile_get_material(24).set_shader_parameter("y_zoom", get_viewport_transform().y)
	# pass
	# print(tile_set.tile_get_material(24))

func _on_water_item_rect_changed():
	# tile_set.tile_get_material(24).set_shader_parameter("scale", scale)
	pass
