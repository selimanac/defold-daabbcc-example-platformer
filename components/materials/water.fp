#version 140

in highp vec4   var_position;
in mediump vec3 var_normal;
in mediump vec2 var_texcoord0;

out vec4        out_fragColor;

uniform fs_uniforms
{
    mediump vec4 uTime;
    mediump vec4 uResolution;
};

// Pre-calculated constants
const float PI = 3.14159265359;
const vec4  BACK_TEX = vec4(0.0);
const vec4  WATER_COLOR = vec4(0.0, 0.5, 0.9, 1.0);
const vec4  FOAM_COLOR = vec4(0.8, 1.0, 1.0, 1.0);
const vec4  TOP_LINE_COLOR = vec4(1.0);

const float TRANSPARENCY = 0.4;
const float WAVE_FREQUENCY = 1.0;
const float WAVE_SPEED = 6.0;
const float WAVE_STRENGTH = 0.008; // Pre-multiplied with 0.001
const float FOAM_DEPTH = 0.2;
const float TOP_LINE_THICKNESS = 0.03;
const float WATER_LEVEL = 0.98;

// Pre-calculated wave multipliers
const float WAVE_FREQ_HALF = WAVE_FREQUENCY * 0.5;
const float WAVE_FREQ_NEG = WAVE_FREQUENCY * 1.3;
const float WAVE_SPEED_FAST = WAVE_SPEED * 1.2;
const float WAVE_SPEED_SLOW = WAVE_SPEED * 0.7;
const float TILER_MULT = PI * 10.0;

void        main()
{
    // Calculate UV with aspect ratio correction
    vec2  uv = var_texcoord0;
    float aspectRatio = uResolution.x / uResolution.y;
    uv.x *= aspectRatio;

    float tiler = TILER_MULT / aspectRatio;
    float time = uTime.x;

    //  wave calculations
    float xTiler = uv.x * tiler;
    float baseWave = xTiler * WAVE_FREQUENCY + time * WAVE_SPEED;

    //  water height
    float waterHeight = sin(baseWave);
    waterHeight += sin(xTiler * WAVE_FREQ_HALF + time * WAVE_SPEED_FAST);
    waterHeight += sin(-xTiler * WAVE_FREQ_NEG + time * WAVE_SPEED_SLOW);

    //  wave modifications
    waterHeight = waterHeight * WAVE_STRENGTH + WATER_LEVEL;

    //  water and line boundaries
    float isWater = step(waterHeight, uv.y);
    float distanceToWave = abs(waterHeight - uv.y);
    float isTopLine = (1.0 - step(TOP_LINE_THICKNESS, distanceToWave)) * (1.0 - isWater);

    //  base water color with transparency
    vec4 outColour = mix(WATER_COLOR, vec4(0.0, 0.0, 1.0, 0.0), TRANSPARENCY);

    // Apply foam
    float foamFactor = clamp((waterHeight - uv.y) / FOAM_DEPTH, 0.0, 1.0);
    outColour = mix(FOAM_COLOR, outColour, foamFactor);

    // Apply top line and water masking
    outColour = mix(outColour, TOP_LINE_COLOR, isTopLine);
    out_fragColor = mix(outColour, BACK_TEX, isWater);
}