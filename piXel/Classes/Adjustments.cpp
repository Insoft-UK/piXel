/*
 The MIT License (MIT)
 
 Copyright (c) 2023 Insoft. All rights reserved.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

#include "Adjustments.hpp"
#include <string>

template <typename T> static T swap_endian(T u) {
    static_assert (CHAR_BIT == 8, "CHAR_BIT != 8");
    
    union {
        T u;
        unsigned char u8[sizeof(T)];
    } source, dest;
    
    source.u = u;
    
    for (size_t k = 0; k < sizeof(T); k++)
        dest.u8[k] = source.u8[sizeof(T) - k - 1];
    
    return dest.u;
}

// Function to extract color components from RGBA value
static void getColorComponents(uint32_t color, int* r, int* g, int* b) {
#ifdef __LITTLE_ENDIAN__
    color = swap_endian(color);
#endif
    *r = (color >> 24) & 255;
    *g = (color >> 16) & 255;
    *b = (color >> 8) & 255;
}

// Function to calculate Euclidean distance between two ARGB colors
static unsigned colorDistance(uint32_t color1, uint32_t color2) {
    int r1, g1, b1;
    int r2, g2, b2;
    
    getColorComponents(color1, &r1, &g1, &b1);
    getColorComponents(color2, &r2, &g2, &b2);
    
    // Euclidean distance ignoring the alpha channel
    return sqrt((r1 - r2) * (r1 - r2) +
                (g1 - g2) * (g1 - g2) +
                (b1 - b2) * (b1 - b2));
}

void Adjustments::postorize(const void* pixels, long length, unsigned levels) {
    uint32_t* colors = (uint32_t*)pixels;
    uint32_t* colorLUT = (uint32_t *)calloc(1 << 24, sizeof(uint32_t));
    float step = 1.0f / (float)(levels - 1);
    
    for (long i = 0; i < length; i++) {
        uint32_t baseColor = colors[i];
        
#ifdef __LITTLE_ENDIAN__
        uint32_t key = baseColor & 0xFFFFFF;
#else
        uint32_t key = baseColor >> 8;
#endif
        if (colorLUT[key] != 0) {
            colors[i] = colorLUT[key];
            continue;
        }
        
#ifdef __LITTLE_ENDIAN__
        uint8_t R = baseColor;
        uint8_t G = baseColor >> 8;
        uint8_t B = baseColor >> 16;
        uint8_t A = baseColor >> 24;
#else
        uint8_t R = baseColor >> 24;
        uint8_t G = baseColor >> 16;
        uint8_t B = baseColor >> 8;
        uint8_t A = baseColor;
#endif

        // Normalize the values to the range 0-1
        float r = (float)R / 255.0f;
        float g = (float)G / 255.0f;
        float b = (float)B / 255.0f;
        float a = (float)A / 255.0;
        
        r = round(r / step) * step;
        g = round(g / step) * step;
        b = round(b / step) * step;
        
#ifdef __LITTLE_ENDIAN__
        colorLUT[key] = (uint32_t)(r * 255.0) | (uint32_t)(g * 255.0) << 8 | (uint32_t)(b * 255.0) << 16 | (uint32_t)(a * 255.0) << 24;
#else
        colorLUT[key] = (uint32_t)(r * 255.0) << 24 | (uint32_t)(g * 255.0) << 16 | (uint32_t)(b * 255.0) << 8 | (uint32_t)(a * 255.0);
#endif
        
        colors[i] = colorLUT[key];
    }
    
    free(colorLUT);
}

void Adjustments::normalizeColors(const void* pixels, long length, unsigned threshold) {
    uint32_t* colorLUT = (uint32_t *)calloc(1 << 24, sizeof(uint32_t));
    uint32_t* colors = (uint32_t *)pixels;
    
    for (int i = 0; i < length; i++) {
        uint32_t baseColor = colors[i];
        
#ifdef __LITTLE_ENDIAN__
        uint32_t key = baseColor & 0xFFFFFF;
#else
        uint32_t key = baseColor >> 8;
#endif
        
        if (colorLUT[key] != 0) {
            colors[i] = colorLUT[key];
            continue;
        }
        
        for (int j = i; j < length; j++) {
            if (colorDistance(baseColor, colors[j]) < threshold && j != i) {
                colors[j] = baseColor;
#ifdef __LITTLE_ENDIAN__
                colorLUT[colors[j] & 0xFFFFFF] = baseColor;
#else
                colorLUT[colors[j] >> 8] = baseColor;
#endif
            }
        }
    }
    
    free(colorLUT);
}


