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

const float PI = 3.14159265359;

// From https://www.shadertoy.com/view/MltyRs
void main()
{
    vec2  uv = var_texcoord0.xy;
    float aspectRatio = uResolution.x / uResolution.y;
    uv.x *= aspectRatio;

    // Makes sure the wave will tile
    float tiler = PI * 10.0 / aspectRatio;

    vec4  backTex = vec4(0.0, 0.0, 0.0, 0.0);

    vec4  waterColour = vec4(0.0, 0.5, 0.9, 1.0);
    vec4  foamColour = vec4(0.8, 1.0, 1.0, 1.0);

    float transparency = 0.4;
    float waveFrequency = 1.0; // Only whole numbers will tile
    float waveSpeed = 6.0;
    float waveStrength = 8.0;
    float foamDepth = 0.2;

    float distortion = 0.1;

    // Generates the wave and its movement
    float waterHeight = sin((uv.x * tiler) * waveFrequency + uTime.x * waveSpeed);
    waterHeight += sin((uv.x * tiler) * waveFrequency * 0.5 + uTime.x * waveSpeed * 1.2);
    waterHeight += sin((-uv.x * tiler) * waveFrequency * 1.3 + uTime.x * waveSpeed * 0.7);

    waterHeight *= waveStrength * 0.001; // Reduces the wave strength
    waterHeight += 1.0;                  // Raises the water level from the bottom

    // Calculates if the pixel is part of the water
    float isWater = step(waterHeight, uv.y);

    // vec2(uv.x + (waterHeight - 0.25) * distortion, uv.y)
    vec4 outColour = vec4(0.0, 0, 1.0, 0.0);
    // Adds transparency to the water colour
    outColour = mix(waterColour, outColour, transparency);

    // Creates the foam
    outColour = mix(foamColour, outColour, clamp((waterHeight - uv.y) / foamDepth, 0.0, 1.0));

    // Outputs a colour depending on if it's water or not (isWater)
    // out_fragColor = backTex * isWater + outColour * (1.0 - isWater);
    out_fragColor = mix(outColour, backTex, isWater);
}
