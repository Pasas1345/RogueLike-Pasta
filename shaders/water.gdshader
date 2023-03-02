shader_type canvas_item;

uniform vec4 target_color : source_color;
uniform vec4 water_color : source_color;
uniform sampler2D noise;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform vec2 scale;
uniform vec2 distortion_scale;
uniform float y_zoom;
uniform float intensity;
uniform float speed;

void fragment() {
	vec4 texture_color = texture(TEXTURE, UV);
	float noise_texture = texture(noise, (UV * scale * distortion_scale) + TIME*speed).x;
	noise_texture -= 0.5;
	
	float uv_height = SCREEN_PIXEL_SIZE.y / TEXTURE_PIXEL_SIZE.y;
	vec2 reflected_screenuv = vec2(SCREEN_UV.x - noise_texture * intensity, SCREEN_UV.y + uv_height * UV.y * scale.y * y_zoom * 2.0);
	
	if (texture_color.r <= target_color.r) {
		if (texture_color.g <= target_color.g) {
			if (texture_color.b <= target_color.b) {
				vec4 reflection = texture(SCREEN_TEXTURE, reflected_screenuv);
				
				COLOR.rgb = mix(reflection.rgb, water_color.rgb, water_color.a);
				// COLOR.rgb = reflection.rgb;
			}
		}
	}
	else {
		COLOR = texture(TEXTURE, UV);
	}
}
