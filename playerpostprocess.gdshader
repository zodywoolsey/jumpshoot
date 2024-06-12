shader_type spatial;
render_mode unshaded;

uniform sampler2D depth_tex : hint_depth_texture;
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
	ALBEDO = vec3(0.0);
	float depth = texture(depth_tex, SCREEN_UV).x;
	vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, depth);
	vec4 view = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	view.xyz /= view.w;
	float linear_depth = -view.z;
	float remapped_value_linear_depth = remap_out_low + (( linear_depth ) - remap_in_low) * (remap_out_high - remap_out_low) / (remap_in_high - remap_in_low);
	//float remapped_value_linear_depth = remap_out_low + (remap_out_high - remap_out_low) * ((linear_depth - remap_in_low) / (remap_in_high - remap_in_low));
	ALBEDO = textureLod(scren_tex, SCREEN_UV,clamp(remapped_value_linear_depth,0.0,4.0)).rgb;
	//if(blend_with_depth_texture){
		//ALBEDO.r = (mix(texture(scren_tex, SCREEN_UV).r,textureLod(scren_tex, SCREEN_UV,4.0).r, clamp(remapped_value_linear_depth,0.0,1.0)));
		//ALBEDO.g = (mix(texture(scren_tex, SCREEN_UV).g,textureLod(scren_tex, SCREEN_UV,4.0).g, clamp(remapped_value_linear_depth,0.0,1.0)));
		//ALBEDO.b = (mix(texture(scren_tex, SCREEN_UV).b,textureLod(scren_tex, SCREEN_UV,4.0).b, clamp(remapped_value_linear_depth,0.0,1.0)));
	//}
}
