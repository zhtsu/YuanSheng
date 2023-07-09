shader_type canvas_item;
render_mode unshaded;

uniform float cutoff : hint_range(0.0, 1.0) = 0.04;
uniform float wave_size : hint_range(0.0, 1.0) = 0.04;
uniform float wave_frequency : hint_range(0.0, 1.0) = 0.04;
uniform float wave_speed : hint_range(0.0, 30.0) = 10.0;

void fragment() {
	float value = (1.0 - UV.y) * (1.0 - wave_size);
	float alpha = 1.0;
	vec3 color = COLOR.rgb;
	
	float wave_cutoff_percent = (sin(UV.x / wave_frequency + TIME * wave_speed) + 1.0) / 2.0;
	float wave_cutoff_value = cutoff - wave_cutoff_percent * wave_size;
	
	if (value > wave_cutoff_value) {
		alpha = 0.0;
	}
	
	COLOR = vec4(color, alpha);
}
