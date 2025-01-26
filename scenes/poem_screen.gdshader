shader_type canvas_item;
uniform vec3 color : source_color;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	float a = 1.0-cos(UV.y * PI * 2.0);
	a = sqrt(a);
	COLOR = vec4(color, a);
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
