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



typedef struct QuadColor {
    UInt8 red, green, blue, alpha;
} QuadColor;

typedef QuadColor* QuadColorRef;

@interface Image()


// MARK: - Private Properties

@property SKMutableTexture *mutableTexture;

/// The image pixel data of the image thats being re-pixilated.
@property NSMutableData *originalImageData;


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
        self.autoFineBlockSizeAdjustment = YES;
        
        SKSpriteNode *node;
        SKMutableTexture *texture = [[SKMutableTexture alloc] initWithSize:size];
        if (texture != nil) {
            [texture modifyPixelDataWithBlock:^(void *pixelData, size_t lengthInBytes) {
                UInt32 *pixel = pixelData;
                
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
    }
    
    return self;
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
        if (cgImage) CGImageRelease(cgImage);
    }
    
    self.blockSize = 2.0;
   
    float width = floor(self.originalSize.width / self.blockSize);
    [self setScale:floor(640 / width)];
    self.changes = YES;
}

-(CGSize)getCGImageSize:(CGImageRef)cgImage {
    if (cgImage) {
        return (CGSize){.width = CGImageGetWidth(cgImage), .height = CGImageGetHeight(cgImage)};
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
    CGFloat width = floor(self.originalSize.width / self.blockSize);
    CGFloat height = floor(self.originalSize.height / self.blockSize);
    CGImageRef imageRef = [Extenions createCGImageFromPixelData:self.scratchData.bytes ofSize:CGSizeMake(width, height)];
    [Extenions writeCGImage:imageRef to:url];
}

-(BOOL)updateWithDelta:(NSTimeInterval)delta {
    if (self.changes) {
        [self restorePixelatedImage];
        [self renderTexture];
        self.changes = NO;
        return YES;
    }
    return NO;
}

- (void)renderTexture {
    [self.mutableTexture modifyPixelDataWithBlock:^(void *pixelData, size_t lengthInBytes) {
        memset(pixelData, 0, lengthInBytes);
        
        int width = self.mutableTexture.size.width;
        int height = self.mutableTexture.size.height;
        
        UInt32* src = (UInt32 *)self.scratchData.bytes;
        UInt32* dest = (UInt32 *)pixelData;
        
        int w = self.originalSize.width / self.blockSize;
        int h = self.originalSize.height / self.blockSize;
        
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

- (UInt32)getPixelAt:(NSUInteger)x ofY:(NSUInteger)y {
    UInt32* pixels = (UInt32*)self.originalImageData.bytes;
    NSUInteger w = (NSUInteger)self.originalSize.width;
    NSUInteger h = (NSUInteger)self.originalSize.height;
    
    if (x >= w || y >= h) return 0;
    return pixels[x + y * w];
}

- (void)setPixelAt:(NSUInteger)x ofY:(NSUInteger)y withColor:(UInt32)color {
    UInt32* pixels = (UInt32*)self.scratchData.bytes;
    NSUInteger w = (NSUInteger)(self.originalSize.width / self.blockSize);
    NSUInteger h = (NSUInteger)(self.originalSize.height / self.blockSize);
    
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
    float x;
    float y;
    
    for (y = 0; y < self.originalSize.height; y += self.blockSize) {
        for (x = 0; x < self.originalSize.width; x += self.blockSize) {
            color = [self averageColorForSampleSize:self.sampleSize atPoint:CGPointMake(x + self.blockSize / 2, y + self.blockSize / 2)];
            [self setPixelAt:floor(x / self.blockSize) ofY:floor(y / self.blockSize) withColor:color];
        }
    }
}


- (void)setBlockSize:(float)size {
    if (size < 2.0) return;
    if (self.autoFineBlockSizeAdjustment) {
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
    
    [self setScale:floor(640 / floor(self.originalSize.width / self.blockSize))];
    
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

- (void)setAutoFineBlockSizeAdjustment:(BOOL)state {
    _autoFineBlockSizeAdjustment = state;
}

@end


