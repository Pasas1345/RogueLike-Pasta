tool
extends TileMap

func _process(_delta):
	material.set_shader_param("y_zoom", get_viewport_transform().y)

func _on_water_item_rect_changed():
	material.set_shader_param("scale", scale)
