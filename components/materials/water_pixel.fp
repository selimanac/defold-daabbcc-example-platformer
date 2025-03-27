#version 140

in highp vec4   var_position;
in mediump vec2 var_texcoord0;
out vec4        out_fragColor;

uniform fs_uniforms
{
    mediump vec4 uTime;
    mediump vec4 uResolution;
};

const vec4 COLORS[4] = vec4[4](
vec4(0.0, 0.0, 0.0, 0.0), // backTex
vec4(0.0, 0.5, 0.9, 1.0), // waterColour
vec4(0.8, 1.0, 1.0, 1.0), // foamColour
vec4(1.0, 1.0, 1.0, 1.0)  // topLineColor
);

// constants
const float WAVE_PARAMS[3] = float[3](
128.0, // pixelScale
1.0,   // waveFrequency
6.0    // waveSpeed
);

const float VISUAL_PARAMS[4] = float[4](
0.4, // transparency
8.0, // waveStrength
0.2, // foamDepth
0.03 // topLineThickness
);

void main()
{
    // Precalculate common values
    vec2  uv = var_texcoord0.xy;
    float aspectRatio = uResolution.x / uResolution.y;
    uv.x *= aspectRatio;

    // grid calculation
    vec2 grid = floor(uv * WAVE_PARAMS[0]) / WAVE_PARAMS[0];

    //  tiling
    float tiler = 31.4159 / aspectRatio; //  PI * 10.0
    float quantizedTime = floor(uTime.x * 8.0) / 8.0;

    // wave calculations
    float x = grid.x * tiler;
    float t = quantizedTime * WAVE_PARAMS[2];
    float waterHeight = sin(x * WAVE_PARAMS[1] + t);
    waterHeight += sin(x * WAVE_PARAMS[1] * 0.5 + t * 1.2);
    waterHeight += sin(-x * WAVE_PARAMS[1] * 1.3 + t * 0.7);

    // wave height calculations
    waterHeight = floor((waterHeight * VISUAL_PARAMS[1] * 0.001 + 0.98) * WAVE_PARAMS[0]) / WAVE_PARAMS[0];

    float isWater = step(waterHeight, uv.y);

    // line calculation
    float pixelLineThickness = max(1.0, floor(VISUAL_PARAMS[3] * WAVE_PARAMS[0]));
    float lineThickness = pixelLineThickness / WAVE_PARAMS[0];
    float isTopLine = float(uv.y >= waterHeight - lineThickness &&
                            uv.y < waterHeight) *
    (1.0 - isWater);

    // color mix
    vec4  outColour = mix(COLORS[1], vec4(0.0, 0.0, 1.0, 0.0), VISUAL_PARAMS[0]);

    float foamFactor = clamp((waterHeight - uv.y) / VISUAL_PARAMS[2], 0.0, 1.0);
    foamFactor = floor(foamFactor * 5.0) / 5.0;

    outColour = mix(COLORS[2], outColour, foamFactor);
    outColour = mix(outColour, COLORS[3], isTopLine);
    out_fragColor = mix(outColour, COLORS[0], isWater);
}