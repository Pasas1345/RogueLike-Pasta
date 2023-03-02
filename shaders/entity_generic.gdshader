shader_type canvas_item;

uniform vec4 solid_color: source_color;
uniform bool flash = false;

void fragment() {
	vec4 texture_color = texture(TEXTURE, UV);
	if (flash) {
		COLOR = vec4(mix(texture_color.rgb, solid_color.rgb, solid_color.a), texture_color.a);
	}
	else {
		COLOR = texture_color;
	}
}