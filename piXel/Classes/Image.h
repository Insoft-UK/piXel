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

#import <CoreGraphics/CoreGraphics.h>
#import "Palette.h"

#ifndef Image_h
#define Image_h

typedef struct {
    CGFloat top, left, bottom, right;
} TMargin;

@interface Image: SKNode

@property (nonatomic, readonly) CGSize originalSize;
@property (nonatomic, readonly) CGSize repixelatedSize;
@property (nonatomic, readonly) float blockSize;
@property (nonatomic, readonly) NSInteger sampleSize;
@property (nonatomic, readonly) NSUInteger posterizeLevels;

@property (nonatomic, readonly) Palette* palette;

@property (nonatomic, readonly) TMargin margin;

@property (nonatomic, readonly) NSUInteger threshold;

@property (nonatomic, readonly) BOOL isPaletteEnabled;
@property (nonatomic, readonly) BOOL isPosterizeEnabled;
@property (nonatomic, readonly) BOOL isColorNormalizationEnabled;
@property (nonatomic, readonly) BOOL isAutoBlockSizeAdjustEnabled;

- (id)initWithSize:(CGSize)size;

- (BOOL)updateWithDelta:(NSTimeInterval)delta;
- (void)saveImageAtURL:(NSURL *)url;
- (void)loadImageWithContentsOfURL:(NSURL *)url;

- (void)setBlockSize:(float)size;
- (void)setSampleSize:(NSInteger)size;
- (void)setPosterizeLevels:(NSUInteger)levels;
- (void)setThreshold:(NSUInteger)value;
- (void)setAutoBlockSizeAdjustEnabled:(BOOL)state;
- (void)setIsPaletteEnabled:(BOOL)state;
- (void)setMargin:(CGFloat)top left:(CGFloat)left bottom:(CGFloat)bottom right:(CGFloat)right;
@end

#endif /* Image_h */
