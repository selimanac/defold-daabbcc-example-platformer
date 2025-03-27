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

// colors
const vec4 COLORS[4] = vec4[4](
vec4(0.7843, 0.9607, 1.0000, 1.0),
vec4(0.5098, 0.7058, 0.9607, 1.0),
vec4(0.3137, 0.5098, 0.9019, 1.0),
vec4(0.7843, 0.9607, 1.0000, 1.0));

// wave related constants
const vec4 WAVE_PARAMS = vec4(
0.02, // EDGE_WIDTH
5.0,  // WAVE_FREQUENCY
0.02, // WAVE_AMPLITUDE
15.0  // WAVE_SPEED
);

const vec2 NOISE_PARAMS = vec2(10.0, 0.2);      // For noise calculation
const vec2 EDGE_STEPS = vec2(0.9, 1.0);         // For edge smoothstep
const vec3 ALPHA_PARAMS = vec3(0.3, 0.2, 0.45); // Alpha adjustments
const vec2 UV_FACTORS = vec2(0.5, 0.05);        // UV scaling factors

void       main()
{
    vec2  uv = var_texcoord0.xy;
    float time = uTime.x * 0.4;

    vec2  resolution = uResolution.xy * UV_FACTORS.x;
    vec2  uv_pixel = floor(uv * resolution) / resolution;

    //  displacement
    vec2 timeUV = vec2(uv_pixel.x, (uv_pixel.y + time) * UV_FACTORS.y);
    vec3 displace = texture(tex0, timeUV).xyz;
    displace = (displace * UV_FACTORS.x) - vec3(1.0, 1.0, UV_FACTORS.x);

    // Edge effect
    float edgeEffect = abs(uv_pixel.x - UV_FACTORS.x) * 2.0;
    float edgeEffect2 = edgeEffect * edgeEffect;

    // displacement
    float sineTime = (time * 2.0 + uv_pixel.y * 20.0);
    displace.x += sin(sineTime) * 0.02 * edgeEffect2;

    // Texture and color
    vec2 uv_tmp = vec2(uv_pixel.x, uv_pixel.y * UV_FACTORS.x + time);
    vec4 color = texture(tex0, uv_tmp + displace.xy);

    //  noise
    vec4 noise = floor(color * NOISE_PARAMS.x) * NOISE_PARAMS.y;

    // color interpolation
    vec4 dark = mix(COLORS[0], COLORS[1], uv.y);
    vec4 bright = mix(COLORS[2], COLORS[3], uv.y);
    color = mix(dark, bright, noise);

    // power calculations
    float uv_y_pow8 = uv_pixel.y * uv_pixel.y;
    uv_y_pow8 = uv_y_pow8 * uv_y_pow8;
    uv_y_pow8 = uv_y_pow8 * uv_y_pow8;

    float inv_uv = 1.0 - uv_pixel.y;
    float inv_uv_pow12 = inv_uv * inv_uv * inv_uv;
    inv_uv_pow12 = inv_uv_pow12 * inv_uv_pow12;

    // color modifications
    color.xyz -= ALPHA_PARAMS.z * vec3(uv_y_pow8);
    color.a -= ALPHA_PARAMS.y * uv_y_pow8;
    color += inv_uv_pow12;

    color.a = max(0.0, color.a - ALPHA_PARAMS.x);

    // edge highlight
    color.rgb += vec3(smoothstep(EDGE_STEPS.x, EDGE_STEPS.y, edgeEffect) * 0.15);

    // Waves
    float timeWave = time * WAVE_PARAMS.w;
    float waveBase = WAVE_PARAMS.y * uv.y + timeWave;
    float leftEdge = WAVE_PARAMS.x + WAVE_PARAMS.z * sin(waveBase);
    float rightEdge = 1.0 - WAVE_PARAMS.x - WAVE_PARAMS.z * sin(waveBase + 3.14);

    //  edge masking
    float edgeMask = smoothstep(leftEdge - 0.05, leftEdge, uv.x) *
    smoothstep(rightEdge + 0.05, rightEdge, uv.x);

    out_fragColor = color * vec4(1.0, 1.0, 1.0, edgeMask);
}