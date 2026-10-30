shader_type canvas_item;
render_mode unshaded;

uniform float amount = 1.0;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
void fragment() {
	vec3 c = texture(screen_texture, SCREEN_UV).rgb;
	vec3 o = c;
	float v = (c.r + c.b + c.g) / 3.0;
	COLOR.rgb = vec3(v * 0.75, v * 0.875, v);
	COLOR.rgb = pow(COLOR.rgb, vec3(1.5));
	COLOR.rgb *= 2.0;
	COLOR.rgb = mix(o, COLOR.rgb, amount);
}
