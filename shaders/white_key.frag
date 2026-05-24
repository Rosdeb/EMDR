#version 460 core

#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform sampler2D uTexture;

out vec4 fragColor;

void main() {
  vec2 uv = FlutterFragCoord().xy / uSize;
  vec4 color = texture(uTexture, uv);

  float r = color.r;
  float g = color.g;
  float b = color.b;
  float brightness = (r + g + b) / 3.0;
  float maxC = max(r, max(g, b));
  float minC = min(r, min(g, b));
  float saturation = maxC - minC;

  // Remove solid/near-white backgrounds while keeping colorful object pixels.
  if (brightness > 0.965 && saturation < 0.10) {
    color.a = 0.0;
  } else if (brightness > 0.90 && saturation < 0.16) {
    float t = clamp((brightness - 0.90) / 0.065, 0.0, 1.0);
    color.a *= 1.0 - t;
  } else if (brightness > 0.84 && saturation < 0.08) {
    float t = clamp((brightness - 0.84) / 0.10, 0.0, 1.0);
    color.a *= 1.0 - t;
  }

  fragColor = color;
}
