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
#import "Image.h"
#import "piXel-Swift.h"

#import "ImageAdjustments.hpp"
#import <array>

typedef UInt32 Color;

typedef struct {
    float r;
    float g;
    float b;
} ColorRGB;

@interface Image()


// MARK: - Private Properties

@property SKMutableTexture *mutableTexture;

/// The image pixel data of the image thats being re-pixilated.
@property NSMutableData *originalImageData;
@property SKSpriteNode *originalImage;

/// The image pixel data of the image thats been re-pixilated.
@property NSMutableData *scratchData;

@property BOOL changes;

@end

@implementation Image


// MARK: - Init

- (id)initWithSize:(CGSize)size {
    if ((self = [super init])) {
        NSUInteger lengthInBytes = (NSUInteger)size.width * (NSUInteger)size.height * sizeof(UInt32);
        
        self.mutableTexture = [[SKMutableTexture alloc] initWithSize:size];
        self.originalImageData = [[NSMutableData alloc] initWithCapacity:lengthInBytes];
        self.originalImageData.length = lengthInBytes;
        self.scratchData = [[NSMutableData alloc] initWithCapacity:lengthInBytes];
        self.scratchData.length = lengthInBytes;
        
        
        
        SKSpriteNode *node;
        SKMutableTexture *texture = [[SKMutableTexture alloc] initWithSize:size];
        if (texture != nil) {
            [texture modifyPixelDataWithBlock:^(void *pixelData, size_t lengthInBytes) {
                Color *pixel = (Color *)pixelData;
                
                NSUInteger s = size.width;
                NSUInteger l = size.height;
                
                for (NSUInteger r = 0; r < l; ++r) {
                    for (NSUInteger c = 0; c < s; ++c) {
                        pixel[r * s + c] = (r & 0b1000 ? c+8 : c) & 0b1000 ? 0xFFFF0000 : 0xFFAA0000;
                    }
                }
            }];
            
            
            node = [SKSpriteNode spriteNodeWithTexture:(SKTexture*)texture size:size];
            node.texture.filteringMode = SKTextureFilteringNearest;
            [self addChild:node];
            
        }
        
        if (self.mutableTexture) {
            node = [SKSpriteNode spriteNodeWithTexture:(SKTexture*)self.mutableTexture size:size];
            node.yScale = -1;
            node.texture.filteringMode = SKTextureFilteringNearest;
            node.name = @"Image";
            [self addChild:node];
        }
        
        
        [self loadImageWithContentsOfURL:[NSURL URLWithString:[[NSBundle mainBundle] pathForResource:@"piXel" ofType:@"png"]]];
     
        _palette = [[Palette alloc] init];
        
        
        
        
        [self updateOverlayOfOriginalImageScale];
        
        [self defaultSettings];
        }
        
    return self;
}

-(void)defaultSettings {
    self.originalImage.alpha = 1.0;
    self.posterizeLevels = 256;
    self.threshold = 0;
    
    self.autoZoomEnabled = YES;
    self.autoBlockSizeAdjustEnabled = NO;
}

// MARK: - Public Instance Methods

-(void)loadImageWithContentsOfURL:(NSURL *)url {
    CGImageRef cgImage = nil;
    
    CGDataProviderRef dataProvider = CGDataProviderCreateWithFilename([url.path UTF8String]);
    
    if (dataProvider) {
        NSString *extension = url.pathExtension.lowercaseString;
        
        if ([extension isEqualToString:@"png"])
            cgImage = CGImageCreateWithPNGDataProvider(dataProvider, NULL, true, kCGRenderingIntentDefault);
        if ([extension isEqualToString:@"jpg"] || [extension isEqualToString:@"jpeg"])
            cgImage = CGImageCreateWithJPEGDataProvider(dataProvider, NULL, true, kCGRenderingIntentDefault);
        CGDataProviderRelease(dataProvider);
        
        [self copyDataBytesOfCGImage:cgImage to:self.originalImageData];
        _originalSize = [self getCGImageSize:cgImage];
        
        if ([self childNodeWithName:@"OriginalImage"] != nil) {
            [[self childNodeWithName:@"OriginalImage"] removeFromParent];
        }
        
        self.originalImage = [SKSpriteNode spriteNodeWithColor:NSColor.clearColor size:[self getCGImageSize:cgImage]];
        self.originalImage.texture = [SKTexture textureWithCGImage:cgImage];
        self.originalImage.name = @"OriginalImage";
        self.originalImage.hidden = YES;
        
        [self addChild:self.originalImage];
        
        if (cgImage) CGImageRelease(cgImage);
        
        
        
    }
    
    self.blockSize = 1.0;
    
    if (self.isAutoZoomEnabled) {
        [self automaticallyAdjustZoom];
    }
    
    
    self.changes = YES;
}

-(CGSize)getCGImageSize:(CGImageRef)cgImage {
    if (cgImage) {
        return (CGSize){.width = static_cast<CGFloat>(CGImageGetWidth(cgImage)), .height = static_cast<CGFloat>(CGImageGetHeight(cgImage))};
    }
    
    return (CGSize){0};
}

-(void)copyDataBytesOfCGImage:(CGImageRef)cgImage to:(NSMutableData *)data {
    if (!cgImage || !data) return;
    
    CFDataRef rawData = CGDataProviderCopyData(CGImageGetDataProvider(cgImage));
    if (!rawData) return;
    
    NSUInteger lengthInBytes = CGImageGetWidth(cgImage) * CGImageGetHeight(cgImage) * sizeof(UInt32);
    memcpy((void *)data.bytes, CFDataGetBytePtr(rawData), lengthInBytes);
    CFRelease(rawData);
}

-(void)saveImageAtURL:(NSURL *)url {
    CGImageRef imageRef = [Extenions createCGImageFromPixelData:(UInt8 *)self.scratchData.bytes ofSize:self.newImageSize];
    [Extenions writeCGImage:imageRef to:url];
}

-(BOOL)updateWithDelta:(NSTimeInterval)delta {
    if (self.changes) {
        [self restorePixelatedImage];
        [self renderTexture];
        
        if (self.isAutoZoomEnabled) {
            [self automaticallyAdjustZoom];
        }
        
        [self updateOverlayOfOriginalImageScale];
        
        self.changes = NO;
        return YES;
    }
    return NO;
}

- (void)automaticallyAdjustZoom {
    float scaleX, scaleY;
    scaleX = floor(640 / floor(self.originalSize.width / self.blockSize));
    scaleY = floor(640 / floor(self.originalSize.height / self.blockSize));
    if (scaleX > scaleY) {
        [self setScale:scaleY];
    }
    else {
        [self setScale:scaleX];
    }
}

- (void)updateOverlayOfOriginalImageScale {
    [self.originalImage setScale:1 / self.blockSize];
}

- (void)renderTexture {
    [self.mutableTexture modifyPixelDataWithBlock:^(void *pixelData, size_t lengthInBytes) {
        memset(pixelData, 0, lengthInBytes);
        
        int width = self.mutableTexture.size.width;
        int height = self.mutableTexture.size.height;
        
        UInt32* src = (UInt32 *)self.scratchData.bytes;
        UInt32* dest = (UInt32 *)pixelData;
        
        int w = self.newImageSize.width;
        int h = self.newImageSize.height;
        
        int x;
        int y;
        
        dest += (height - h) / 2 * width + (width - w) / 2;
        
        for (y = 0; y < h; ++y) {
            for (x = 0; x < w; ++x) {
                dest[x + width * y] = src[x + y * w];
            }
        }
    }];
}




- (ColorRGB)convertFromPackedRGB:(Color)color {
    ColorRGB rgb;
    
    // Extract the RGB components from the ARGB value
    unsigned char r = (color >> 16) & 0xFF; // Red (bits 16-23)
    unsigned char g = (color >> 8) & 0xFF;  // Green (bits 8-15)
    unsigned char b = color & 0xFF;         // Blue (bits 0-7)
    
    // Normalize the values to the range 0-1
    rgb.r = r / 255.0f;
    rgb.g = g / 255.0f;
    rgb.b = b / 255.0f;
    
    return rgb;
}

- (Color)convertToPackedRGB:(ColorRGB)colorRGB withAlphaOf:(float)alpha {
    // Convert the RGB values (0-1 range) back to 0-255 range
    Color r = (Color)(colorRGB.r * 255.0f);
    Color g = (Color)(colorRGB.g * 255.0f);
    Color b = (Color)(colorRGB.b * 255.0f);
    Color a = (Color)(alpha * 255.0f);
    
    // Combine ARGB into a 32-bit integer
    return a << 24 | r << 16 | g << 8 | b;
}



- (UInt32)getPixelAt:(NSUInteger)x ofY:(NSUInteger)y {
    UInt32* pixels = (UInt32*)self.originalImageData.bytes;
    NSUInteger w = (NSUInteger)self.originalSize.width;
    NSUInteger h = (NSUInteger)self.originalSize.height;
    
    if (x >= w || y >= h) return 0;
    return pixels[x + y * w];
}

- (void)setPixelAt:(NSUInteger)x ofY:(NSUInteger)y withColor:(UInt32)color {
    UInt32* pixels = (UInt32*)self.scratchData.bytes;
    NSUInteger w = (NSUInteger)self.newImageSize.width;
    NSUInteger h = (NSUInteger)self.newImageSize.height;
    
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

- (void)restorePixelatedImage {
    UInt32 color;
    float x, y;
    int destX, destY;
    
    for (destY = 0, y = 0; y < self.originalSize.height; y += self.blockSize, destY++) {
        for (destX = 0, x = 0; x < self.originalSize.width; x += self.blockSize, destX++) {
            color = [self averageColorForSampleSize:self.sampleSize atPoint:CGPointMake(x + self.blockSize / 2, y + self.blockSize / 2)];
            [self setPixelAt:destX ofY:destY withColor:color];
        }
    }
    
    
    if (self.isColorNormalizationEnabled) {
        ImageAdjustments::normalizeColors(self.scratchData.bytes, (int)self.newImageSize.width, (int)self.newImageSize.height, (unsigned int)self.threshold);
    }
    
    if (self.isPosterizeEnabled) {
        long length = self.newImageSize.width * self.newImageSize.height;
        ImageAdjustments::postorize(self.scratchData.bytes, length, (unsigned int)self.posterizeLevels);
    }
    
    if (self.isPaletteEnabled) {
        ImageAdjustments::normalizeColorsToPalette(self.scratchData.bytes, (int)self.newImageSize.width, (int)self.newImageSize.height, (UInt32*)self.palette.bytes, (int)self.palette.colorCount);
        return;
    }
    
    SKNode *node = [self childNodeWithName:@"Image"];
    auto size = self.newImageSize;
    node.position = CGPointMake((int)size.width & 1 ? 0.5 : 0.0, (int)size.height & 1 ? -0.5 : 0.0);
}

// MARK: - Getter/s

- (CGSize)newImageSize {
    return CGSizeMake((CGFloat)floor(self.originalSize.width / self.blockSize), (CGFloat)floor(self.originalSize.height / self.blockSize));
}

- (BOOL)isPosterizeEnabled {
    return self.posterizeLevels < 256;
}

- (BOOL)isColorNormalizationEnabled {
    return self.threshold > 0;
}


// MARK: - Setter/s

- (void)setThreshold:(NSUInteger)value {
    if (value > 256) return;
    _threshold = value;
    self.changes = YES;
}

- (void)setAutoBlockSizeAdjustEnabled:(BOOL)state {
    _isAutoBlockSizeAdjustEnabled = state;
}

- (void)setPosterizeLevels:(NSUInteger)levels {
    _posterizeLevels = levels >= 2 && levels < 256 ? levels : 256;
    self.changes = YES;
}

- (void)setSampleSize:(NSInteger)size {
    NSInteger blockSize = self.blockSize;
    
    if (size > blockSize || size < 1) {
        _sampleSize = 1;
        return;
    }
    
    _sampleSize = size;
    self.changes = YES;
}

- (void)setBlockSize:(float)size {
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

    
    self.changes = YES;
}

- (void)setIsPaletteEnabled:(BOOL)state {
    _isPaletteEnabled = state;
    self.changes = YES;
}



- (void)setAutoZoomEnabled:(BOOL)state {
    _isAutoZoomEnabled = state;
}

-(void)showOriginal {
    self.originalImage.hidden = NO;
}
-(void)hideOriginal {
    self.originalImage.hidden = YES;
}
@end


