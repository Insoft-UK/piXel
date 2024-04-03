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
#import "sXale-Swift.h"


@interface Image()


// MARK: - Private Properties

@property SKMutableTexture *mutableTexture;

// The source image pixel data of the image thats going to be scaled.
@property NSMutableData *inputImageData;
@property NSMutableData *outputImageData;

@property (readonly) CGSize inputImageSize;
@property (readonly) CGSize outputImageSize;


@property BOOL changes;


@end

@implementation Image


// MARK: - Init

- (id)initWithSize:(CGSize)size {
    if ((self = [super init])) {
        [self setupWithSize: size];
        self.changes = YES;
    }
    
    return self;
}

- (void)setupWithSize:(CGSize)size {
    NSUInteger lengthInBytes = (NSUInteger)size.width * (NSUInteger)size.height * sizeof(UInt32);
    
    self.mutableTexture = [[SKMutableTexture alloc] initWithSize:size];
    self.inputImageData = [[NSMutableData alloc] initWithCapacity:lengthInBytes];
    self.inputImageData.length = lengthInBytes;
    
    self.outputImageData = [[NSMutableData alloc] initWithCapacity:lengthInBytes];
    self.outputImageData.length = lengthInBytes;
    
    NSString *file = [[NSBundle mainBundle] pathForResource:@"piXel" ofType:@"raw"];
    NSData *data;
    if ((data = [NSData dataWithContentsOfFile:file]) != nil) {
        memcpy((void *)_inputImageData.bytes, data.bytes, 256 * 256 * 4);
        data = nil;
    }
    
    
    
    [self setScale:1];
    
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
        
        [self copyDataBytesOfCGImage:cgImage to:self.inputImageData];
        [self copyDataBytesOfCGImage:cgImage to:self.outputImageData];
        _inputImageSize = [self getCGImageSize:cgImage];
        _outputImageSize = _inputImageSize;
        
        if (cgImage) CGImageRelease(cgImage);
    }
    
    
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
    CGImageRef imageRef = [Extenions createCGImageFromPixelData:self.outputImageData.bytes ofSize:CGSizeMake(self.outputImageSize.width, self.outputImageSize.height)];
    [Extenions writeCGImage:imageRef to:url];
}

-(void)updateWithDelta:(NSTimeInterval)delta {
    
    ViewController *viewController = (ViewController *)NSApplication.sharedApplication.windows.firstObject.contentViewController;
    
    viewController.widthText.stringValue = [NSString stringWithFormat:@"%d", (int)self.inputImageSize.width];
    viewController.heightText.stringValue = [NSString stringWithFormat:@"%d", (int)self.inputImageSize.height];
    viewController.zoomText.stringValue = [NSString stringWithFormat:@"%ldx", self.zoom];
    
    [self renderTexture];
    
    viewController.infoText.stringValue = [NSString stringWithFormat:@"Resolution: %dx%d", (int)self.outputImageSize.width, (int)self.outputImageSize.height];
    
    
    self.changes = NO;
}

- (void)renderTexture {
    [self.mutableTexture modifyPixelDataWithBlock:^(void *pixelData, size_t lengthInBytes) {
        memset(pixelData, 0x0, lengthInBytes);
        [self renderImageDataToPixelData:(void *)pixelData ofSize:self.mutableTexture.size];
    }];
}

- (void)renderImageDataToPixelData:(void *)pixelData ofSize:(CGSize)size {
    if (!self.outputImageData || !pixelData) return;

    int ww = (int)self.outputImageSize.width;
    int hh = (int)self.outputImageSize.height;
    
    UInt32 *source = (UInt32 *)self.outputImageData.bytes;
    UInt32 *dest = (UInt32 *)pixelData;
    
    int w = (int)size.width;
    int h = (int)size.height;
    
    dest += (w - ww) / 2;
    dest += (h - hh) / 2 * w;
    
    for(int y = 0; y < hh; y+=1) {
        for (int x = 0; x < ww; x+=1) {
            dest[x + y * w] = source[x + y * ww];
        }
    }
}


- (void)EPX {
    
}



// MARK: - Public Setters

- (void)setScale:(CGFloat)scale {
    self.xScale = scale;
    self.yScale = scale;
    _zoom = (NSUInteger)self.xScale;
}



// MARK: - Private Class Methods





@end


