shader_type spatial;
render_mode unshaded;
uniform sampler2D albedo_texture : source_color;

void fragment() {
    vec2 base_uv = SCREEN_UV;
    vec4 albedo_tex = texture(albedo_texture, base_uv);
    ALBEDO = albedo_tex.rgb;
}