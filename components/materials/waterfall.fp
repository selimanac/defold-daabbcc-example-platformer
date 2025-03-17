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

// Wave function
float edgeWave(float x, float time, float frequency, float amplitude)
{
    float distFromCenter = abs(x - 0.5) * 2.0;
    float edgeFactor = smoothstep(0.0, 1.0, pow(distFromCenter, 1.5));
    float wave = sin(time * frequency + x * 10.0) * amplitude;
    return wave * edgeFactor;
}

// FROM: https://shadered.org/view?s=6Gny24_ojD
void main()
{
    vec2  uv = var_texcoord0.xy;
    float time = uTime.x * 0.4;

    // Apply horizontal wave displacement based on position
    float xDisplacement = edgeWave(uv.x, time, 2.0, 0.01);

    // Apply the displacement to the UV coordinates
    vec2 wavyUV = uv;
    wavyUV.x += xDisplacement;

    // Ensure UV stays within bounds (optional, creates a "cropped" effect)
    wavyUV.x = clamp(wavyUV.x, 0.0, 1.0);

    vec2 uv_pixel = floor(wavyUV * (uResolution.xy / 2)) / (uResolution.xy / 2);

    vec4 col1 = vec4(0.7843, 0.9607, 1, 1.0);
    vec4 col2 = vec4(0.5098, 0.7058, 0.9607, 1.0);
    vec4 col3 = vec4(0.3137, 0.5098, 0.9019, 1.0);
    vec4 col4 = vec4(0.7843, 0.9607, 1, 1.0);

    // Add vertical displacement that varies based on horizontal position
    vec3 displace = texture(tex0, vec2(uv_pixel.x, (uv_pixel.y + time) * 0.05)).xyz;
    displace *= 0.5;
    displace.x -= 1.0;
    displace.y -= 1.0;
    displace.y *= 0.5;

    // Add extra horizontal displacement at edges
    float edgeEffect = abs(uv_pixel.x - 0.5) * 2.0; // 0 at center, 1 at edges
    float horizontalWave = sin(time * 2.0 + uv_pixel.y * 20.0) * 0.02 * pow(edgeEffect, 2.0);
    displace.x += horizontalWave;

    // color
    vec2 uv_tmp = uv_pixel;
    uv_tmp.y *= 0.5;
    uv_tmp.y += time;
    vec4 color = texture(tex0, uv_tmp + displace.xy);

    // match to colors
    vec4 noise = floor(color * 10.0) / 5.0;
    vec4 dark = mix(col1, col2, wavyUV.y);
    vec4 bright = mix(col3, col4, wavyUV.y);
    color = mix(dark, bright, noise);

    // add gradients (top dark and transparent, bottom bright)
    float inv_uv = 1.0 - uv_pixel.y;
    color.xyz -= 0.45 * pow(uv_pixel.y, 32.0);
    color.a -= 0.2 * pow(uv_pixel.y, 8.0);
    color += pow(inv_uv, 12.0);

    // make waterfall transparent
    color.a -= 0.3;

    // Add a slight edge highlight to emphasize the wavy sides
    float edgeHighlight = smoothstep(0.9, 1.0, edgeEffect) * 0.15;
    color.rgb += vec3(edgeHighlight);

    // edge mask
    float edgeWidth = 0.02;     // Controls how wide the wavy edge is
    float waveFrequency = 5.0;  // Controls how many waves appear
    float waveAmplitude = 0.02; // Controls how pronounced the waves are
    float waveSpeed = 15.0;     // Controls how fast the waves move

    // sine wave offset for left and right edges
    float leftEdge = edgeWidth + waveAmplitude * sin(waveFrequency * uv.y + time * waveSpeed);
    float rightEdge = 1.0 - edgeWidth - waveAmplitude * sin(waveFrequency * uv.y + time * waveSpeed + 3.14);

    float edgeMask = 1.0;

    if (uv.x < leftEdge)
    {
        edgeMask *= smoothstep(leftEdge - 0.05, leftEdge, uv.x);
    }

    if (uv.x > rightEdge)
    {
        edgeMask *= smoothstep(rightEdge + 0.05, rightEdge, uv.x);
    }

    color.a *= edgeMask;

    out_fragColor = vec4(color);
}