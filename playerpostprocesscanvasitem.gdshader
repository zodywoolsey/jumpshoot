shader_type canvas_item;
render_mode unshaded;

uniform sampler2D scren_tex : hint_screen_texture;

uniform bool blend_with_depth_texture = false;
uniform float remap_in_low = 0.0;
uniform float remap_in_high = 1.0;
uniform float remap_out_low = 0.0;
uniform float remap_out_high = 1.0;

//void vertex() {
	//POSITION = vec4(VERTEX, 1.0);
//}

void fragment() {
	COLOR = texture(scren_tex, SCREEN_UV);
	
	//ALPHA = clamp(linear_depth/20.0,0.0,1.0);
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
