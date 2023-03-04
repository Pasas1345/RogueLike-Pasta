shader_type canvas_item;

uniform sampler2D noise : repeat_enable;
uniform vec4 field_color : source_color;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float distortion_scale;
uniform float speed;

uniform float light_start : hint_range(0.0, 1.0) = 0.4;
uniform float light_end : hint_range(0.0, 1.0) = 0.237;
uniform vec4 light_color : source_color;

void fragment() {
	float depth = texture(noise, UV + speed * TIME).r * texture(noise, UV + -speed * TIME).r;
	
	vec4 screen_texture = texture(SCREEN_TEXTURE, SCREEN_UV + distortion_scale * vec2(depth));
	
	vec4 field_light = smoothstep(light_start, light_end, depth) * light_color;
	
	COLOR = screen_texture * field_color + field_light;
	COLOR.a = 1.0;
}
