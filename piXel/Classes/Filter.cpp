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

#include "Filter.hpp"


#include <stdint.h>

void Filter::outline(const void* pixels, int w, int h) {
    uint32_t color;
    uint32_t* colors = (uint32_t *)pixels;
    
#ifdef __LITTLE_ENDIAN__
#define BLACK 4278190080
#else
#define BLACK = 255
#endif
#define CLEAR 0
    
    for (int y = 0; y < h; y++) {
        for (int x = 0; x < w; x++) {
            color = colors[x + y * w];
            if (!color) {
                continue;
            }
            
            if (color == BLACK) {
                continue;
            }
            
            if (x > 0) {
                if (colors[x + y * w - 1] == CLEAR) {
                    colors[x + y * w - 1] = BLACK;
                }
            }
            
            if (x < w - 1) {
                if (colors[x + y * w + 1] == CLEAR) {
                    colors[x + y * w + 1] = BLACK;
                }
            }
            
            if (y > 0) {
                if (colors[x + y * w - w] == CLEAR) {
                    colors[x + y * w - w] = BLACK;
                }
            }
            
            if (y < h - 1) {
                if (colors[x + y * w + w] == CLEAR) {
                    colors[x + y * w + w] = BLACK;
                }
            }
        }
    }
}
