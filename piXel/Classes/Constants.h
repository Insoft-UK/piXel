/*
Copyright © 2021 Insoft. All rights reserved.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

#ifndef Constants_h
#define Constants_h

#import <SpriteKit/SpriteKit.h>

#define UInt8(n) ((UInt8)n)

// MARK: - Debug
static const BOOL kDebug = NO;

// MARK: - Screen Bounds
static __inline CGRect ScreenFrame() {
    return [NSScreen mainScreen].frame;
}

// MARK: - Screen Size and Positon
static __inline CGSize ScreenSize() {
    return [NSScreen mainScreen].frame.size;
}

// MARK: - Math Functions
static __inline__ int RandomIntegerBetween(int min, int max) {
    return min + arc4random_uniform(max - min + 1);
}

static __inline__ CGFloat RandomFloatRange(CGFloat min, CGFloat max) {
    return ((CGFloat)arc4random() / 0xFFFFFFFFu) * (max - min) + min;
}

static __inline int MaxInteger(int a, int b) {
    return (a > b) ? a : b;
}

static __inline CGFloat MaxFloat(CGFloat a, CGFloat b) {
    return (a > b) ? a : b;
}

static __inline int MinInteger(int a, int b) {
    return (a < b) ? a : b;
}

static __inline CGFloat MinFloat(CGFloat a, CGFloat b) {
    return (a < b) ? a : b;
}

static __inline int MapInteger(int x, int inMin, int inMax, int outMin, int outMax) {
    return (x - inMin) * (outMax - outMin) / (inMax - inMin) + outMin;
}

static __inline CGFloat MapFloat(CGFloat x, CGFloat inMin, CGFloat inMax, CGFloat outMin, CGFloat outMax) {
    return (x - inMin) * (outMax - outMin) / (inMax - inMin) + outMin;
}



#endif /* Constants_h */

