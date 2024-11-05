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

#import <SpriteKit/SpriteKit.h>

typedef enum GridColor : NSUInteger {
    GridColorNone   = 0,
    GridColorLight  = 1,
    GridColorMedium = 2,
    GridColorDark   = 3,
    GridColorRed    = 4,
    GridColorOrange = 5,
    GridColorGreen  = 6,
    GridColorBlue   = 7,
    GridColorPurple = 8
} GridColor;

@interface MainScene : SKScene

// MARK: - Class Properties

@property (nonatomic) NSUInteger gridSize;
@property (nonatomic) GridColor gridColor;

// MARK: - Class Instance Methods



@end
