#version 140

in highp vec4             var_position;
in mediump vec3           var_normal;
in mediump vec2           var_texcoord0;

out vec4                  out_fragColor;

uniform mediump sampler2D tex0;

uniform fs_uniforms
{
    mediump vec4 u_repeat;
    mediump vec4 u_offset;
};

void main()
{
    // Scale UVs to tile the texture and add the scrolling offset
    vec2 uv = var_texcoord0.xy * u_repeat.xy + u_offset.xy;
    // Wrap the UVs so they repeat
    uv = fract(uv);
    out_fragColor = texture(tex0, uv);
    wefwef;
}
