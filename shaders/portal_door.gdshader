shader_type spatial;
render_mode unshaded;
uniform sampler2D albedo_texture : source_color;
uniform sampler2D closed_texture : source_color;
instance uniform vec4 border_color: source_color;
instance uniform float border_size: hint_range(0.0, 1.0);
instance uniform int portal_active; // 0 - active

void fragment() {

    if (portal_active == 0) {
        vec4 albedo_tex = texture(albedo_texture, SCREEN_UV);
        if (UV.x < border_size || UV.x > 1.0 - border_size || UV.y < border_size || UV.y > 1.0 - border_size) {
            ALBEDO = border_color.rgb;
        } else {
            ALBEDO = albedo_tex.rgb;
        }
    } else {
        vec4 closed_tex = texture(closed_texture, UV);
        ALBEDO = closed_tex.rgb;
        ALPHA = closed_tex.a;
    }

}