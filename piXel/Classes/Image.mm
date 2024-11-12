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
#import "Image.hh"
#import "piXel-Swift.h"

#import "Adjustments.hpp"
#import "Filter.hpp"

@implementation Image {
    SKMutableTexture *mutableTexture;
    ViewController* viewController;
    
    
    NSData *sourceImageData;
    SKSpriteNode *overlayGuideImage;
    SKSpriteNode *alteredImage;
    
    
    /// The image pixel data of the image thats been re-pixilated.
    NSMutableData *workBuffer;
}



// MARK: - Init

- (id)initWithSize:(CGSize)size {
    if ((self = [super init])) {
        viewController = (ViewController *)NSApplication.sharedApplication.windows.firstObject.contentViewController;
        
        
        mutableTexture = [[SKMutableTexture alloc] initWithSize:size];
        
        
        if (mutableTexture) {
            alteredImage = [SKSpriteNode spriteNodeWithTexture:(SKTexture*)mutableTexture size:size];
            alteredImage.yScale = -1;
            alteredImage.texture.filteringMode = SKTextureFilteringNearest;
            alteredImage.lightingBitMask = 0;
            alteredImage.shadowedBitMask = 0;
            alteredImage.shadowCastBitMask = 0;
            [self addChild:alteredImage];
        }
        
        
        [self loadImageWithContentsOfURL:[NSURL URLWithString:[[NSBundle mainBundle] pathForResource:@"piXel" ofType:@"png"]]];
        
        _clut = [[CLUT alloc] init];
        
        
        
        
        
        [self defaultSettings];
    }
    
    return self;
}

// MARK: - Private Helper Instance Methods for Init

- (void)defaultSettings {
    overlayGuideImage.alpha = 1.0;
    self.posterizeLevels = 2;
    self.threshold = 0;
    _blockSize = 4;
    _leftCropMargin = 76;
    _rightCropMargin = 72;
    _topCropMargin = 64;
    _bottomCropMargin = 58;
    
    _isAutoZoomEnabled = YES;
    self.autoBlockSizeAdjustEnabled = YES;
}

// MARK: - Public Instance Methods

- (void)loadImageWithContentsOfURL:(NSURL *)url {
    CGImageRef cgImage = nil;
    
    CGDataProviderRef dataProvider = CGDataProviderCreateWithFilename([url.path UTF8String]);
    
    if (dataProvider) {
        NSString *extension = url.pathExtension.lowercaseString;
        
        if ([extension isEqualToString:@"png"])
            cgImage = CGImageCreateWithPNGDataProvider(dataProvider, NULL, true, kCGRenderingIntentDefault);
        if ([extension isEqualToString:@"jpg"] || [extension isEqualToString:@"jpeg"])
            cgImage = CGImageCreateWithJPEGDataProvider(dataProvider, NULL, true, kCGRenderingIntentDefault);
        CGDataProviderRelease(dataProvider);
        
        [self copyDataBytesOfCGImage:cgImage];
        
        
        if ([self childNodeWithName:@"OriginalImage"] != nil) {
            [[self childNodeWithName:@"OriginalImage"] removeFromParent];
        }
        
        _originalSize = [self getCGImageSize:cgImage];
        
        // Make sure we allow for a surounding margin of 1px
        int width = self.originalSize.width + 2;
        int height = self.originalSize.height + 2;
        size_t lengthInBytes = width * height * sizeof(UInt32);
        
        [self reallocateWorkBuffer:lengthInBytes];
        
        
        if (cgImage) CGImageRelease(cgImage);
    }
    
    self.blockSize = 1.0;
    
    if (self.isAutoZoomEnabled) {
        [self automaticallyAdjustZoom];
    }
    
    
    _hasChanged = YES;
}

- (void)saveImageAtURL:(NSURL *)url {
    CGImageRef imageRef = [Extenions createCGImageFromPixelData:(UInt8 *)workBuffer.bytes ofSize:self.size];
    [Extenions writeCGImage:imageRef to:url];
}

- (void)update {
    [self removeOverlayGuideImage];
    [self reconstructPixelArt];
    [self renderTexture];
    
    if (self.isAutoZoomEnabled) {
        [self automaticallyAdjustZoom];
    }
    
    _hasChanged = NO;
}

- (void)showGuideImage {
    [self removeOverlayGuideImage];
    [self createOverlayGuideImage];
    [self rescaleOverlayGuideImage];
    [self centerOverlayGuideImage];
    if (overlayGuideImage == nil) {
        return;
    }
    [self addChild:overlayGuideImage];
    alteredImage.hidden = YES;
}

- (void)hideGuideImage {
    alteredImage.hidden = NO;
    [self removeOverlayGuideImage];
    _hasChanged = YES;
}

// MARK: - Private Instance Methods

- (void)removeOverlayGuideImage {
    if (overlayGuideImage != nil) {
        [overlayGuideImage removeFromParent];
        overlayGuideImage = nil;
    }
}

- (void)createOverlayGuideImage {
    SKMutableTexture *mutableTexture = [[SKMutableTexture alloc] initWithSize:self.croppedSize];
    overlayGuideImage = [SKSpriteNode spriteNodeWithTexture:mutableTexture];
    
    int destWidth = mutableTexture.size.width;
    int destHeight = mutableTexture.size.height;
    int width = self.originalSize.width;
    
    [mutableTexture modifyPixelDataWithBlock:^(void *pixelData, size_t lengthInBytes) {
        UInt32 *src = (UInt32 *)self->sourceImageData.bytes;
        UInt32 *dest = (UInt32 *)pixelData;
        size_t size = destWidth * sizeof(UInt32);
        
        src += (int)self.leftCropMargin;
        src += (int)self.topCropMargin * width;
        
        for (int y = destHeight - 1; y >= 0; y--) {
            memcpy(&dest[y * destWidth], src, size);
            src += width;
        }
    }];
}

- (void)rescaleOverlayGuideImage {
    if (overlayGuideImage == nil) {
        return;
    }
    [overlayGuideImage setScale:1 / self.blockSize];
    float xScale = self.width / overlayGuideImage.size.width;
    float yScale = self.height / overlayGuideImage.size.height;
    overlayGuideImage.xScale *= xScale;
    overlayGuideImage.yScale *= yScale;
}

- (void)centerOverlayGuideImage {
    if (overlayGuideImage == nil) {
        return;
    }
    NSInteger width = self.croppedSize.width;
    NSInteger height = self.croppedSize.height;
    overlayGuideImage.position = CGPointMake(width & 1 ? 0.5 : 0.0, height & 1 ? -0.5 : 0.0);
}

- (void)reallocateWorkBuffer:(size_t)lengthInBytes {
    workBuffer = nil;
    
    workBuffer = [[NSMutableData alloc] initWithCapacity:lengthInBytes];
    
    if (workBuffer != nil) {
        [workBuffer setLength:lengthInBytes];
        [workBuffer resetBytesInRange:NSMakeRange(0, workBuffer.length)];
    }
}

- (void)copyDataBytesOfCGImage:(CGImageRef)cgImage {
    if (!cgImage) return;
    
    CFDataRef rawData = CGDataProviderCopyData(CGImageGetDataProvider(cgImage));
    if (!rawData) return;
    
    NSUInteger lengthInBytes = CGImageGetWidth(cgImage) * CGImageGetHeight(cgImage) * sizeof(UInt32);
    sourceImageData = nil;
    sourceImageData = [NSData dataWithBytes:CFDataGetBytePtr(rawData) length:lengthInBytes];
    CFRelease(rawData);
}

- (CGSize)getCGImageSize:(CGImageRef)cgImage {
    if (cgImage) {
        return (CGSize){.width = static_cast<CGFloat>(CGImageGetWidth(cgImage)), .height = static_cast<CGFloat>(CGImageGetHeight(cgImage))};
    }
    
    return (CGSize){0};
}

- (void)automaticallyAdjustZoom {
    float scaleX, scaleY;
    scaleX = 640 / self.width;
    scaleY = 640 / self.height;
    if (scaleX > scaleY) {
        [self setScale:scaleY];
    }
    else {
        [self setScale:scaleX];
    }
}



- (void)renderTexture {
    [mutableTexture modifyPixelDataWithBlock:^(void *pixelData, size_t lengthInBytes) {
        memset(pixelData, 0, lengthInBytes);
        
        int width = self->mutableTexture.size.width;
        int height = self->mutableTexture.size.height;
        
        UInt32* src = (UInt32 *)self->workBuffer.bytes;
        UInt32* dest = (UInt32 *)pixelData;
        
        int w = self.size.width;
        int h = self.size.height;
        
        int x;
        int y;
        
        dest += (height - h) / 2 * width + (width - w) / 2;
        UInt32 color;
        for (y = 0; y < h; ++y) {
            for (x = 0; x < w; ++x) {
                color = src[x + y * w];
                dest[x + width * y] = color;
            }
        }
    }];
}

- (UInt32)getPixelAt:(NSUInteger)x ofY:(NSUInteger)y {
    UInt32* pixels = (UInt32*)sourceImageData.bytes;
    NSUInteger w = (NSUInteger)self.originalSize.width;
    NSUInteger h = (NSUInteger)self.originalSize.height;
    
    if (x >= w || y >= h) return 0;
    return pixels[x + y * w];
}

- (void)setPixelAt:(NSUInteger)x ofY:(NSUInteger)y withRgbaColor:(UInt32)color {
    UInt32* pixels = (UInt32*)workBuffer.bytes;
    NSUInteger w = (NSUInteger)self.size.width;
    NSUInteger h = (NSUInteger)self.size.height;
    
    if (x >= w || y >= h) return;
    pixels[x + y * w] = color;
}

- (UInt32)averageColorForSampleSize:(NSUInteger)size atPoint:(CGPoint)point {
    struct {
        union {
            uint32_t ARGB;
            struct {
                uint32_t R:8;
                uint32_t G:8;
                uint32_t B:8;
                uint32_t A:8;
            } channel;
        };
    } color;
    
    if (size < 1) size = 1;
    NSUInteger r,g,b,a;
    
    r = g = b = a = 0;
    
    point.x -= size / 2;
    point.y -= size / 2;
    
    for (int i = 0; i < size; ++i) {
        for (int j = 0; j < size; ++j) {
            color.ARGB = [self getPixelAt:point.x + j ofY:point.y + i];
            r += color.channel.R;
            g += color.channel.G;
            b += color.channel.B;
            a += color.channel.A;
        }
    }
    
    NSUInteger avarage = size * size;
    color.channel.R = (UInt32)(r /= avarage);
    color.channel.G = (UInt32)(g /= avarage);
    color.channel.B = (UInt32)(b /= avarage);
    color.channel.A = (UInt32)(a /= avarage);
    
    
    return color.ARGB;
}

- (void)reconstructPixelArt {
    UInt32 color;
    float x, y;
    int destX, destY;
    
    for (destY = 0, y = self.topCropMargin; y < self.originalSize.height - self.bottomCropMargin; y += self.blockSize, destY++) {
        for (destX = 0, x = self.leftCropMargin; x < self.originalSize.width - self.rightCropMargin; x += self.blockSize, destX++) {
            color = [self averageColorForSampleSize:self.sampleSize atPoint:CGPointMake(x + self.blockSize / 2, y + self.blockSize / 2)];
            [self setPixelAt:destX ofY:destY withRgbaColor:color | 0xFF000000];
        }
    }
    
    if (self.isPaletteEnabled) {
        [self.clut mapColorsToColorTable:workBuffer.bytes lengthInBytes:(int)self.size.width * (int)self.size.height];
        if (self.isTransparencyEnabled) {
            UInt32 transparencyColor = [Colors RgbaFromColor:self.clut.transparencyColor];
            UInt32 *pixels = (UInt32 *)workBuffer.bytes;
            for (int i = 0; i < (int)self.size.width * (int)self.size.height; ++i) {
                if (pixels[i] != transparencyColor) continue;
                pixels[i] = 0;
            }
        }
    } else {
        if (self.isNormalizeEnabled) {
            Adjustments::normalizeColors(workBuffer.bytes, self.size.width * self.size.height, (unsigned int)self.threshold);
        } else {
            Adjustments::postorize(workBuffer.bytes, self.size.width * self.size.height, (unsigned int)self.posterizeLevels);
        }
    }
    
    if (self.isOutlineEnabled) {
        Filter::outline(workBuffer.bytes, (int)self.size.width, (int)self.size.height);
    }
    
    [self centerAlteredImage];
    
}

- (void)centerAlteredImage {
    NSInteger width = self.width;
    NSInteger height = self.height;
    alteredImage.position = CGPointMake(width & 1 ? 0.5 : 0.0, height & 1 ? -0.5 : 0.0);
}

- (void)refreshOverlayGuideImage {
    [self removeOverlayGuideImage];
    [self createOverlayGuideImage];
    [self rescaleOverlayGuideImage];
    [self centerOverlayGuideImage];
    if (overlayGuideImage == nil) {
        return;
    }
    [self addChild:overlayGuideImage];
}

// MARK: - Getter & Setters

- (CGSize)croppedSize {
    return CGSizeMake(self.originalSize.width - self.leftCropMargin - self.rightCropMargin, self.originalSize.height - self.topCropMargin - self.bottomCropMargin);
}

- (void)setLeftCropMargin:(NSInteger)newValue {
    if (newValue < 0) return;
    if (newValue + self.rightCropMargin > self.originalSize.width) return;
    _leftCropMargin = newValue;
    [self refreshOverlayGuideImage];
}

- (void)setRightCropMargin:(NSInteger)newValue {
    if (newValue < 0) return;
    if (newValue + self.leftCropMargin > self.originalSize.width) return;
    _rightCropMargin = newValue;
    [self refreshOverlayGuideImage];
}

- (void)setTopCropMargin:(NSInteger)newValue {
    if (newValue < 0) return;
    if (newValue + self.bottomCropMargin > self.originalSize.height) return;
    _topCropMargin = newValue;
    [self refreshOverlayGuideImage];
}

- (void)setBottomCropMargin:(NSInteger)newValue {
    if (newValue < 0) return;
    if (newValue + self.topCropMargin > self.originalSize.height) return;
    _bottomCropMargin = newValue;
    [self refreshOverlayGuideImage];
}

- (CGSize)size {
    CGSize size;
    
    size = self.originalSize;
    size.width = size.width - self.leftCropMargin - self.rightCropMargin;
    size.height = size.height - self.topCropMargin - self.bottomCropMargin;
    size.width = floor(size.width / self.blockSize);
    size.height = floor(size.height / self.blockSize);
    
    if (self.isOutlineEnabled) {
        size.width += 2;
        size.height += 2;
    }
    return size;
}

- (CGFloat)width {
    return self.size.width;
}

- (void)setWidth:(CGFloat)newValue {
    self.blockSize = self.originalSize.width / newValue;
}

- (CGFloat)height {
    return self.size.height;
}

- (void)setHeight:(CGFloat)newValue {
    self.blockSize = self.originalSize.height / newValue;
}

- (void)setBlockSize:(CGFloat)size {
    if (size < 1.0) return;
    
    if (self.isAutoBlockSizeAdjustEnabled) {
        size = self.originalSize.width / floor(self.originalSize.width / floor(size));
        
        float integerPart;
        float fractionalPart;
        
        fractionalPart = modff(size, &integerPart);
        
        if (fractionalPart > 0.01) {
            size -= 0.01;
        }
        _blockSize = size;
        
    }
    else {
        _blockSize = size;
    }
    self.sampleSize = self.sampleSize;
    
    int length = self.size.width * self.size.height * sizeof(UInt32);
    [workBuffer setLength:length];
    
    _hasChanged = YES;
}

- (void)setSampleSize:(NSUInteger)newValue {
    _sampleSize = newValue;
    
    if (newValue > self.blockSize || newValue < 1) {
        _sampleSize = 1;
    }
    
    _hasChanged = YES;
}

- (void)setPosterizeLevels:(NSUInteger)newValue {
    _posterizeLevels = newValue >= 2 && newValue < 256 ? newValue : 256;
    _hasChanged = YES;
}

- (void)setIsTransparencyEnabled:(BOOL)newValue {
    _isTransparencyEnabled = newValue;
    _hasChanged = YES;
}

- (void)setOutlineEnabled:(BOOL)state {
    _isOutlineEnabled = state;
    _hasChanged = YES;
}


- (BOOL)isPosterizeEnabled {
    return self.posterizeLevels < 256 && !self.isNormalizeEnabled && !self.isPaletteEnabled;
}

- (BOOL)isNormalizeEnabled {
    return self.threshold > 0 && !self.isPaletteEnabled;
}

- (void)setThreshold:(NSUInteger)newValue {
    if (newValue > 256) return;
    _threshold = newValue;
    _hasChanged = YES;
}

- (void)setAutoBlockSizeAdjustEnabled:(BOOL)newValue {
    _isAutoBlockSizeAdjustEnabled = newValue;
}

- (void)setIsPaletteEnabled:(BOOL)newValue {
    _isPaletteEnabled = newValue;
    _hasChanged = YES;
}

- (void)setIsAutoZoomEnabled:(BOOL)state {
    _isAutoZoomEnabled = state;
}



@end
