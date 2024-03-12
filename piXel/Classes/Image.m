/*
Copyright © 2023 Insoft. All rights reserved.

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
@property NSMutableData *imageData;


/// The image pixel data of the image thats been re-pixilated.
@property NSMutableData *scratchData;

@property BOOL changes;


@end

@implementation Image


// MARK: - Init

- (id)initWithSize:(CGSize)size {
    if ((self = [super init])) {
        
        
//
//        NSString *file = [[NSBundle mainBundle] pathForResource:@"piXel" ofType:@"raw"];
//        NSData *data;
//        if ((data = [NSData dataWithContentsOfFile:file]) != nil) {
//            self.cgImage = [_CGImage createFromPixelData:data.bytes ofSize:CGSizeMake(256, 256)];
//        }
        
        
//        CGDataProviderRef dataProvider = CGDataProviderCreateWithFilename([path UTF8String]);
//
//        if (dataProvider) {
//            self.cgImage = CGImageCreateWithPNGDataProvider(dataProvider, NULL, true, kCGRenderingIntentDefault);
//            CGDataProviderRelease(dataProvider);
            
            //            if (self.cgImage) {
            //                CFDataRef rawData = CGDataProviderCopyData(CGImageGetDataProvider(self.cgImage));
            //                if (rawData) {
            //                    self.imageData = [NSMutableData dataWithBytes:CFDataGetBytePtr(rawData) length:CFDataGetLength(rawData)];
            //                    self.imageSize = CGSizeMake((CGFloat)CGImageGetWidth(self.cgImage), (CGFloat)CGImageGetHeight(self.cgImage));
            //                    CFRelease(rawData);
            //                }
            //                CGImageRelease(self.cgImage);
            //            }
            
        //}
        
        
        
        
        
        
        //CGDataProviderRef imgDataProvider = CGDataProviderCreateWithCFData((CFDataRef)[NSData dataWithContentsOfFile:@"pixel-art"]);
        //CGImageRef image = CGImageCreateWithJPEGDataProvider(imgDataProvider, NULL, true, kCGRenderingIntentDefault);
        
        
        
        
        
        [self setupWithSize: size];
        self.changes = YES;
        
    }
    
    return self;
}

- (void)setupWithSize:(CGSize)size {
    NSUInteger lengthInBytes = (NSUInteger)size.width * (NSUInteger)size.height * sizeof(UInt32);
    
    self.mutableTexture = [[SKMutableTexture alloc] initWithSize:size];
    self.imageData = [[NSMutableData alloc] initWithCapacity:lengthInBytes];
    self.imageData.length = lengthInBytes;
    self.scratchData = [[NSMutableData alloc] initWithCapacity:lengthInBytes];
    self.scratchData.length = lengthInBytes;
    
    NSString *file = [[NSBundle mainBundle] pathForResource:@"piXel" ofType:@"raw"];
    NSData *data;
    if ((data = [NSData dataWithContentsOfFile:file]) != nil) {
        memcpy((void *)_imageData.bytes, data.bytes, 256 * 256 * 4);
        data = nil;
    }
    
    self.aspectRatio = 1.0;
    _pixelSize = CGSizeMake(4.0, 4.0);
    _offset = (TPoint){3, 3};
    _bitsPerChannel = 2;
    _size = (TSize){27,33};
    [self setScale:5];
    _imageSize = (TSize){256, 256};
    
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
        
        [self copyDataBytesOfCGImage:cgImage to:self.imageData];
        _imageSize = [self getCGImageSize:cgImage];
        
        if (cgImage) CGImageRelease(cgImage);
    }
    
    ViewController *viewController = (ViewController *)NSApplication.sharedApplication.windows.firstObject.contentViewController;
    viewController.infoText.stringValue = [NSString stringWithFormat:@"Resolution: %zux%zu", self.imageSize.width, self.imageSize.height];
    
}

-(TSize)getCGImageSize:(CGImageRef)cgImage {
    if (cgImage) {
        return (TSize){.width = CGImageGetWidth(cgImage), .height = CGImageGetHeight(cgImage)};
    }
    
    return (TSize){0};
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
    CGImageRef imageRef = [Extenions createCGImageFromPixelData:self.scratchData.bytes ofSize:CGSizeMake(self.size.width, self.size.height)];
    [Extenions writeCGImage:imageRef to:url];
}

-(void)updateWithDelta:(NSTimeInterval)delta {
    
    ViewController *viewController = (ViewController *)NSApplication.sharedApplication.windows.firstObject.contentViewController;
    
    viewController.widthText.stringValue = [NSString stringWithFormat:@"%d", (int)self.size.width];
    viewController.heightText.stringValue = [NSString stringWithFormat:@"%d", (int)self.size.height];
    viewController.zoomText.stringValue = [NSString stringWithFormat:@"%ldx", self.zoom];
    
    if (self.aspectRatio > 1.1) {
        viewController.ratioText.stringValue = @"2:1";
    } else if (self.aspectRatio < 1.0) {
        viewController.ratioText.stringValue = @"1:2";
    } else {
        viewController.ratioText.stringValue = @"1:1";
    }
    
    
    
    [self renderTexture];
    
    self.changes = NO;
}

- (void)renderTexture {
    [self.mutableTexture modifyPixelDataWithBlock:^(void *pixelData, size_t lengthInBytes) {
        memset(pixelData, 0, lengthInBytes);
        
        [self renderImageDataToPixelData:(void *)pixelData ofSize:self.mutableTexture.size];
        [self samplePixelData:pixelData ofSize:self.mutableTexture.size];
        [Colors redrawPreview:self.scratchData.bytes];
    }];
}

- (void)renderImageDataToPixelData:(void *)pixelData ofSize:(CGSize)size {
    if (!self.imageData || !pixelData) return;
    
    
    
    UInt32 *source = (UInt32 *)self.imageData.bytes;
    
    CGSize border = {
        .width = (size.width - self.imageSize.width) / 2,
        .height = (size.height - self.imageSize.height) / 2
    };
    
    for(int y = border.height; y < size.height - border.height; y++) {
        for (int x = border.width; x < size.width - border.width; x++) {
            ((UInt32 *)pixelData)[y * (int)size.width + x] = *source++;
        }
    }
    
    ViewController *viewController = (ViewController *)NSApplication.sharedApplication.windows.firstObject.contentViewController;
    viewController.infoText.stringValue = [NSString stringWithFormat:@"Resolution: %zux%zu", self.imageSize.width, self.imageSize.height];
    
    
}

- (void)samplePixelData:(void *)pixelData ofSize:(CGSize)size {
    if (!pixelData) return;
    
    
    CGSize border = {
        .width = (size.width - self.size.width * floor(self.pixelSize.width)) / 2,
        .height = (size.height - self.size.height * floor(self.pixelSize.height)) / 2
    };
    
    UInt32 * output = (UInt32 *)self.scratchData.bytes;
    
    
    for(CGFloat y = border.height; y < size.height - border.height; y += self.pixelSize.height) {
        for (CGFloat x = border.width; x < size.width - border.width; x += self.pixelSize.width) {
            UInt32 *pixel = &((UInt32 *)pixelData)[((int)y + (int)self.offset.y) * (int)size.width + ((int)x + (int)self.offset.x)];
            [self reduceChannels:(QuadColor *)pixel];
            
            *output++ = *pixel;
            
            //*output++ = *pixel;
            
            pixel[-(int)size.width] = 255 << 24;
            pixel[+(int)size.width] = 255 << 24;
            pixel[-1] = 255 << 24;
            pixel[+1] = 255 << 24;
            pixel[0] = ~0;
        }
    }
}

- (UInt8)reduceChannel:(UInt8)value {
    
    if (self.bitsPerChannel == 1) {
        value &= 0b10000000;
        if (value & 0b10000000) value |= 0b01111111;
    }
    
    if (self.bitsPerChannel == 2) {
        value &= 0b11000000;
        value |= value >> 2;
        value |= value >> 2;
        value |= value >> 2;
    }
    
    if (self.bitsPerChannel == 3) {
        value &= 0b11100000;
        value |= value >> 3;
        value |= value >> 3;
    }
    
    if (self.bitsPerChannel == 4) {
        value &= 0b11110000;
        value |= value >> 4;
    }
    
    if (self.bitsPerChannel == 5) {
        value &= 0b11111000;
        value |= value >> 5;
    }
    
    if (self.bitsPerChannel == 6) {
        value &= 0b11111100;
        value |= value >> 6;
    }
    
    return value;
    
}

- (void)reduceChannels:(QuadColorRef) quadColor {
    quadColor->red = [self reduceChannel:quadColor->red];
    quadColor->green = [self reduceChannel:quadColor->green];
    quadColor->blue = [self reduceChannel:quadColor->blue];
    quadColor->alpha = 255;
}

- (void)renderOutputData:(NSData *)output toPixelData:(void *)pixelData ofSize:(CGSize)size {
    UInt32 *src = (UInt32 *)output.bytes;
    UInt32 *dst = (UInt32 *)pixelData;
    
    int x_ofs = ((int)size.width - (int)self.size.width) / 2;
    int y_ofs = ((int)size.height - (int)self.size.height) / 2;
    
    for(int y = 0; y < (int)self.size.height; y++) {
        for (int x = 0; x < (int)self.size.width; x++) {
            dst[x_ofs + x + (y + y_ofs) * (int)size.width] = src[x + y * (int)self.size.width];
        }
    }
}


// MARK: - Public Setters

- (void)setScale:(CGFloat)scale {
    self.xScale = scale;
    self.yScale = scale;
    _zoom = (NSUInteger)self.xScale;
}


- (void)setSize:(TSize)size {
    if (size.width < 0 || size.height < 0) return;
    if (size.width > 255 || size.height > 255) return;
    _size = size;
}


- (void)setAspectRatio:(CGFloat)aspectRatio {
    _aspectRatio = aspectRatio;
    self.xScale = self.yScale * self.aspectRatio;
}


- (void)setPixelSize:(CGSize)pixelSize {
    if (pixelSize.width < 1.0 || pixelSize.height < 1.0) return;
    if (pixelSize.width > 64.0 || pixelSize.height > 64.0) return;
    _pixelSize = pixelSize;
    
    if (self.offset.x > (NSUInteger)self.pixelSize.width - 1) _offset.x = (NSUInteger)self.pixelSize.width - 1;
    if (self.offset.y > (NSUInteger)self.pixelSize.height - 1) _offset.y = (NSUInteger)self.pixelSize.height - 1;
}

- (void)setOffset:(TPoint)offset {
    if (!(offset.x < 0 || offset.x > (NSUInteger)self.pixelSize.width)) {
        _offset.x = offset.x;
    }
    if (!(offset.y < 0 || offset.y > (NSUInteger)self.pixelSize.height)) {
        _offset.y = offset.y;
    }
}

- (void)setBitsPerChannel:(NSUInteger)bitsPerChannel {
    _bitsPerChannel = bitsPerChannel % 8;
    if (_bitsPerChannel == 0) _bitsPerChannel++;
}



// MARK: - Private Class Methods





@end


