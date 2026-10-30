shader_type canvas_item;
render_mode unshaded;

void fragment() {
	if (COLOR.a != 0.0) {
		float a = COLOR.r + TIME;
		float b = 0.5;
		if (modf(a, b) > 0.65) {
			COLOR.rgba = vec4(1.0, 1.0, 1.0, COLOR.a);
		}
		else {
			COLOR.rgba = vec4(0.0, 0.0, 0.0, 0.0);
		}
	}
}