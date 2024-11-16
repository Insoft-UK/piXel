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

#import "CLUT.h"
#import "piXel-Swift.h"

typedef struct __attribute__((__packed__)) {
    struct {
        UInt8 r, g, b;
    } colors[256];
    
    UInt16 defined;
    UInt16 transparency;
} AdobeColorTable;

@interface CLUT()

// MARK: - Private Properties
@property NSMutableData *mutableData;

@end

@implementation CLUT

UInt32 * _Nonnull colorLUT;

// MARK: - Init

- (id)init {
    if ((self = [super init])) {
        self.mutableData = [NSMutableData dataWithCapacity:1024];
        [self.mutableData setLength:1024];
        colorLUT = (UInt32 *)self.mutableData.mutableBytes;
        
        [self loadAdobeColorTable:[NSBundle.mainBundle pathForResource:@"Default" ofType:@"act"]];
    }
    
    return self;
}

// MARK: - Public Instance Methods

- (void)loadAdobeColorTable:(NSString * _Nonnull)file {
    NSData *data = [NSData dataWithContentsOfFile:file];
    
    if (!(data.length == 768 || data.length == 772)) {
        data = nil;
        return;
    }
    
    
    AdobeColorTable *adobeColorTable = (AdobeColorTable *)data.bytes;
    
    if (data.length == 772) {
        _defined = CFSwapInt16BigToHost(adobeColorTable->defined);
        [self.mutableData setLength:self.defined * sizeof(UInt32)];
        _transparency = CFSwapInt16BigToHost(adobeColorTable->transparency);
    } else {
        _defined = 256;
        _transparency = -1;
    }
    
    UInt32 color;
    for (int n = 0; n < 256; n++) {
        if (n >= self.defined) {
            colorLUT[n] = 0;
            continue;
        }
        color = (UInt32)adobeColorTable->colors[n].r << 24 | (UInt32)adobeColorTable->colors[n].g << 16 | (UInt32)adobeColorTable->colors[n].b << 8;
        if (self.transparency != n) color |= 255;
        colorLUT[n] = CFSwapInt32BigToHost(color);
    }
}

-(void)saveAsAdobeColorTableAtPath:(NSString * _Nonnull )path {
    // Ensure the file exists before trying to open it
    NSFileManager *fileManager = [NSFileManager defaultManager];

    // Create the file if it doesn't exist
    if (![fileManager fileExistsAtPath:path]) {
        [fileManager createFileAtPath:path contents:nil attributes:nil];
    }

    // Now try to open the file for writing
    NSFileHandle *fileHandler = [NSFileHandle fileHandleForWritingAtPath:path];
    
    if (fileHandler == nil) return;
    
    NSMutableData* data = [NSMutableData dataWithCapacity:772];
    if (data == nil) {
        [fileHandler closeFile];
        return;
    }
    
    [data setLength:772];
    AdobeColorTable *adobeColorTable = (AdobeColorTable *)data.bytes;
    
    adobeColorTable->defined = CFSwapInt16HostToBig(self.defined);
    adobeColorTable->transparency = CFSwapInt16HostToBig(self.transparency);
    
    for (int n = 0; n <= self.defined; n++) {
        UInt32 color = CFSwapInt32HostToBig(colorLUT[n]);
        adobeColorTable->colors[n].r = color >> 24;
        adobeColorTable->colors[n].g = color >> 16;
        adobeColorTable->colors[n].b = color >> 8;
    }
    
    [fileHandler writeData:data];
    
    [fileHandler closeFile];
}

- (void)mapColorsToColorTable:(const void *)pixelData lengthInBytes:(size_t)length ignoreTransparency:(BOOL)ignore {
    UInt8 r, g, b;
    UInt32 *pixels = (UInt32 *)pixelData;
    
    while (length--) {
        UInt32 pixel = CFSwapInt32HostToBig(pixels[length]);
        
        r = pixel >> 24;
        g = pixel >> 16;
        b = pixel >> 8;

        
        UInt8 closestIndex = 0;
        int closestDistance = INT_MAX;
        
        for (int index = 0; index <= self.defined; index++) {
            UInt32 lutColor = CFSwapInt32HostToBig(colorLUT[index]);

            UInt8 lutR = lutColor >> 24;
            UInt8 lutG = lutColor >> 16;
            UInt8 lutB = lutColor >> 8;

            int distance = (r - lutR) * (r - lutR) +
                           (g - lutG) * (g - lutG) +
                           (b - lutB) * (b - lutB);
            if (distance < closestDistance) {
                closestDistance = distance;
                closestIndex = (UInt8)index;
            }
        }
        
        pixels[length] = colorLUT[closestIndex];
        if (ignore) {
            if (closestIndex == self.transparency) pixels[length] = 0;
        }
    }
}

- (NSColor *)colorAtIndex:(NSInteger)index {
    NSColor *nsColor;
    UInt32 lutColor = CFSwapInt32HostToBig(colorLUT[index]);
    
    UInt8 lutR = lutColor >> 24;
    UInt8 lutG = lutColor >> 16;
    UInt8 lutB = lutColor >> 8;
    
    CGFloat r = (CGFloat)lutR / 255.0;
    CGFloat g = (CGFloat)lutG / 255.0;
    CGFloat b = (CGFloat)lutB / 255.0;
    
    nsColor = [NSColor colorWithRed:r green:g blue:b alpha:1.0];
    
    return nsColor;
}

// MARK: - Public Getter & Setters

- (void)setDefined:(UInt16)defined {
    _defined = MIN(MAX(defined, 2), 256);
    if (self.transparency > self.defined - 1) {
        self.transparency = -1;
    }
    for (int i = 0; i < self.defined; i++) {
        colorLUT[i] |= CFSwapInt32BigToHost(255);
    }
    for (int i = self.defined; i < 256; i++) {
        colorLUT[i] = 0;
    }
}

- (UInt32 *)colors {
    return colorLUT;
}

- (void)setTransparency:(SInt16)transparency {
    if (self.transparency != -1) {
        colorLUT[self.transparency] |= CFSwapInt32BigToHost(255);
    }
    _transparency = MIN(MAX(transparency, -1), 255);
    if (self.transparency != -1) {
        colorLUT[self.transparency] &= CFSwapInt32BigToHost(0xFFFFFF);
    }
}

@end
