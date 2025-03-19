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
// + claude 3.7
void main()
{
    vec2  uv = var_texcoord0.xy;
    float aspectRatio = uResolution.x / uResolution.y;
    uv.x *= aspectRatio;

    // PIXEL ART PARAMETERS - ADJUST THESE
    float pixelScale = 128.0; // Higher number = more pixels (smaller pixels)
                              // Try values between 8.0 (very chunky) and 64.0 (fine)

    // Create a pixelated grid effect by quantizing coordinates
    float gridX = floor(uv.x * pixelScale) / pixelScale;
    float gridY = floor(uv.y * pixelScale) / pixelScale;

    // Calculate a pixel-perfect water height for each pixel column
    // Makes sure the wave will tile
    float tiler = PI * 10.0 / aspectRatio;

    vec4  backTex = vec4(0.0, 0.0, 0.0, 0.0);

    vec4  waterColour = vec4(0.0, 0.5, 0.9, 1.0);
    vec4  foamColour = vec4(0.8, 1.0, 1.0, 1.0);
    vec4  topLineColor = vec4(1.0, 1.0, 1.0, 1.0); // Pure white for the top line

    float transparency = 0.4;
    float waveFrequency = 1.0; // Only whole numbers will tile
    float waveSpeed = 6.0;
    float waveStrength = 8.0;
    float foamDepth = 0.2;
    float topLineThickness = 0.03; // Controls the thickness of the top white line

    // Quantize time for stepped animation
    float quantizedTime = floor(uTime.x * 8.0) / 8.0;

    // Generate pixelated water height based on the quantized grid
    float waterHeight = sin((gridX * tiler) * waveFrequency + quantizedTime * waveSpeed);
    waterHeight += sin((gridX * tiler) * waveFrequency * 0.5 + quantizedTime * waveSpeed * 1.2);
    waterHeight += sin((-gridX * tiler) * waveFrequency * 1.3 + quantizedTime * waveSpeed * 0.7);

    waterHeight *= waveStrength * 0.001; // Reduces the wave strength

    // Quantize water height to match the pixel grid
    waterHeight = floor(waterHeight * pixelScale) / pixelScale;

    waterHeight += 0.98; // Raises the water level from the bottom

    // Calculates if the pixel is part of the water
    // Use original uv.y for smooth filling but gridX for pixelated wave top
    float isWater = step(waterHeight, uv.y);

    // For the white line, we want it to follow the pixelated top
    // This creates a line that follows the water top with controllable thickness
    float isTopLine = 0.0;

    // Calculate pixel-perfect top line thickness
    // Convert topLineThickness to an integer number of pixels
    float pixelLineThickness = max(1.0, floor(topLineThickness * pixelScale));
    float lineThickness = pixelLineThickness / pixelScale;

    // The line is exactly pixelLineThickness pixels high at the top of each water column
    if (uv.y >= waterHeight - lineThickness && uv.y < waterHeight)
    {
        isTopLine = 1.0;
    }

    // Only show the line where there's water
    isTopLine *= (1.0 - isWater);

    vec4 outColour = vec4(0.0, 0, 1.0, 0.0);
    // Adds transparency to the water colour
    outColour = mix(waterColour, outColour, transparency);

    // Creates the foam with pixel art style
    float foamFactor = clamp((waterHeight - uv.y) / foamDepth, 0.0, 1.0);
    // Quantize foam factor for a stepped appearance
    foamFactor = floor(foamFactor * 5.0) / 5.0;
    outColour = mix(foamColour, outColour, foamFactor);

    // Add the bold white top line
    outColour = mix(outColour, topLineColor, isTopLine);

    // Outputs a colour depending on if it's water or not (isWater)
    out_fragColor = mix(outColour, backTex, isWater);
}