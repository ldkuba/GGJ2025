shader_type spatial;
render_mode unshaded;
uniform sampler2D albedo_texture : source_color;
instance uniform vec4 border_color: source_color;
instance uniform float border_size: hint_range(0.0, 1.0);

void fragment() {
    vec2 base_uv = SCREEN_UV;
    vec4 albedo_tex = texture(albedo_texture, base_uv);
    if (UV.x < border_size || UV.x > 1.0 - border_size || UV.y < border_size || UV.y > 1.0 - border_size) {
        ALBEDO = border_color.rgb;
    } else {
        ALBEDO = albedo_tex.rgb;
    }
}