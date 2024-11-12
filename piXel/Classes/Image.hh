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
#import "CLUT.h"

#ifndef Image_hh
#define Image_hh

@interface Image: SKNode

// MARK: - Class Properties

@property (nonatomic, readonly) CLUT * _Nonnull clut;
@property (nonatomic, readonly) CGSize originalSize;
@property (nonatomic, readonly) CGSize croppedSize;
@property (nonatomic) NSInteger leftCropMargin;
@property (nonatomic) NSInteger rightCropMargin;
@property (nonatomic) NSInteger topCropMargin;
@property (nonatomic) NSInteger bottomCropMargin;
@property (nonatomic, readonly) CGSize size;
@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat height;
@property (nonatomic) CGFloat blockSize;
@property (nonatomic) NSUInteger sampleSize;
@property (nonatomic) NSUInteger posterizeLevels;
@property (nonatomic) NSUInteger threshold;
@property (nonatomic) BOOL isPaletteEnabled;
@property (nonatomic) BOOL isAutoZoomEnabled;
@property (nonatomic) BOOL isTransparencyEnabled;
@property (nonatomic) BOOL isOutlineEnabled;
@property (nonatomic, readonly) BOOL isPosterizeEnabled;
@property (nonatomic, readonly) BOOL isNormalizeEnabled;
@property (nonatomic) BOOL isAutoBlockSizeAdjustEnabled;
@property (nonatomic, readonly) BOOL hasChanged;
@property (nonatomic) BOOL hasMargin;

// MARK: - Class Instance Methods

- (id _Nonnull)initWithSize:(CGSize)size;
- (void)loadImageWithContentsOfURL:(NSURL * _Nonnull)url;
- (void)saveImageAtURL:(NSURL * _Nonnull)url;
- (void)update;
- (void)showGuideImage;
- (void)hideGuideImage;

@end

#endif /* Image_hh */
