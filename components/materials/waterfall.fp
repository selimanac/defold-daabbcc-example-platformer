#version 140

in highp vec4             var_position;
in mediump vec3           var_normal;
in mediump vec2           var_texcoord0;

out vec4                  out_fragColor;

uniform mediump sampler2D tex0;

uniform fs_uniforms
{
    mediump vec4 uTime;
    mediump vec4 uResolution;
};

// From https://shadered.org/view?s=6Gny24_ojD
void main()
{
    vec2  uv = var_texcoord0.xy;
    float time = uTime.x * 0.4;

    vec2  uv_pixel = floor(uv * (uResolution.xy / 2)) / (uResolution.xy / 2);

    vec4  col1 = vec4(0.7843137383461, 0.96078431606293, 1, 1.0);
    vec4  col2 = vec4(0.50980395078659, 0.70588237047195, 0.96078431606293, 1.0);
    vec4  col3 = vec4(0.3137255012989, 0.50980395078659, 0.90196079015732, 1.0);
    vec4  col4 = vec4(0.7843137383461, 0.96078431606293, 1, 1.0);

    // displacement on top of y
    vec3 displace = texture(tex0, vec2(uv_pixel.x, (uv_pixel.y + time) * 0.05)).xyz;
    displace *= 0.5;
    displace.x -= 1.0;
    displace.y -= 1.0;
    displace.y *= 0.5;

    // color
    vec2 uv_tmp = uv_pixel;
    uv_tmp.y *= 0.5;
    uv_tmp.y += time;
    vec4 color = texture(tex0, uv_tmp + displace.xy);

    // match to colors
    vec4 noise = floor(color * 10.0) / 5.0;
    vec4 dark = mix(col1, col2, uv.y);
    vec4 bright = mix(col3, col4, uv.y);
    color = mix(dark, bright, noise);

    // add gradients (top dark and transparent, bottom bright)
    float inv_uv = 1.0 - uv_pixel.y;
    color.xyz -= 0.45 * pow(uv_pixel.y, 32.0);
    color.a -= 0.2 * pow(uv_pixel.y, 8.0);
    color += pow(inv_uv, 12.0);

    // make waterfall transparent
    color.a -= 0.3;

    out_fragColor = vec4(color);
}
