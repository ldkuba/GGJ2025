shader_type spatial;
render_mode unshaded;
uniform sampler2D albedo_texture : source_color;
uniform sampler2D closed_texture : source_color;
uniform vec4 border_color: source_color;
uniform float border_size: hint_range(0.0, 1.0);
uniform int portal_active; // 0 - active

// 0 - border, 1 - inside, 2 - outside
vec2 ellipse(vec2 uv) {
    uv *= 2.6;
    uv -= 1.3;
    float e = (uv.x * uv.x) / 1.0 + (uv.y * uv.y) / 1.0;

    if (e > 1.0 - border_size && e < 1.0 + border_size) {
        return vec2(0.0, e);
    } else if (e <= 1.0 - border_size) {
        return vec2(1.0, e);
    } else {
        return vec2(2.0, e);
    }
}

float random(vec2 uv) {
    return fract(sin(dot(uv.xy,
        vec2(12.9898,78.233))) * 43758.5453123);
}


void fragment() {

    if (portal_active == 0) {
        vec4 albedo_tex = texture(albedo_texture, SCREEN_UV);
        vec2 mode = ellipse(UV);

        if (mode.x == 0.0) {
            // BORDER
            float e = mode.y;
            // border is from e - border_size to e + border_size
            ALPHA = 1.0 - smoothstep(1.0 - border_size, 1.0 + border_size, e);

            ALBEDO = border_color.rgb;
        } else if(mode.x == 1.0) {
            // INSIDE
            float strength = 1.0;
            float time_scale = 2.0;
            float resolution_scale = 20.0;
            
            float red_base = 0.03;
            float red_dynamic = sin(UV.x * resolution_scale + 3.0 + red_base) + cos(UV.y * resolution_scale + red_base) + sin(TIME * time_scale + red_base + SCREEN_UV.x * resolution_scale);
            float red_offset = red_base + red_dynamic * 0.01;

            float green_base = 0.02;
            float green_dynamic = cos(UV.x * resolution_scale + green_base) + sin(UV.y * resolution_scale + 4.0 + green_base) + sin(TIME * time_scale + green_base + SCREEN_UV.y * resolution_scale);
            float green_offset = green_base + red_dynamic * 0.01;

            float blue_base = 0.04;
            float blue_dynamic = sin(UV.x * resolution_scale - 0.6 + blue_base) + cos(UV.y * resolution_scale + blue_base) + sin(TIME * time_scale + blue_base + SCREEN_UV.x * resolution_scale);
            float blue_offset = blue_base + red_dynamic * 0.01;
 
            vec3 chromatic_aberration = vec3(red_offset, green_offset, blue_offset) * strength;

            float e = mode.y;
            float mix_val = smoothstep(1.0 - border_size - 0.1, 1.0 - border_size, e);
            ALBEDO = mix(albedo_tex.rgb + chromatic_aberration, border_color.rgb, mix_val);
        } else {
            // OUTSIDE
            ALPHA = 0.0;
        }
    } else {
        vec4 closed_tex = texture(closed_texture, UV);
        ALBEDO = closed_tex.rgb;
        ALPHA = closed_tex.a;
    }

}