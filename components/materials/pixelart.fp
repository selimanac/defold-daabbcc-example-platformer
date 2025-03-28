#version 140

in highp vec4             var_position;
in mediump vec3           var_normal;
in mediump vec2           var_texcoord0;
in mediump vec4           var_light;

out vec4                  out_fragColor;

uniform mediump sampler2D tex0;

uniform fs_uniforms
{
    mediump vec4 tint;
};

void main()
{
    vec4 color = texture(tex0, var_texcoord0.xy);
    out_fragColor = vec4(color.rgb, 1.0);
}
