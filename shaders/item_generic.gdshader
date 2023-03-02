shader_type canvas_item;

uniform vec4 color : source_color;
uniform float width = 2.0;

void fragment() {
	// Yes, this is shamelessly stolen from the 2d shaders demo
	vec4 texture_color = texture(TEXTURE, UV);
	vec2 pixel_size = TEXTURE_PIXEL_SIZE;
	
	float a;
	float maxa = texture_color.a;
	float mina = texture_color.a;
	
	a = texture(TEXTURE, UV + vec2(0.0, -width) * pixel_size).a;
	maxa = max(a, maxa);
	mina = min(a, mina);

	a = texture(TEXTURE, UV + vec2(0.0, width) * pixel_size).a;
	maxa = max(a, maxa);
	mina = min(a, mina);

	a = texture(TEXTURE, UV + vec2(-width, 0.0) * pixel_size).a;
	maxa = max(a, maxa);
	mina = min(a, mina);

	a = texture(TEXTURE, UV + vec2(width, 0.0) * pixel_size).a;
	maxa = max(a, maxa);
	mina = min(a, mina);
	
	COLOR = mix(texture_color, color, maxa - mina);
}