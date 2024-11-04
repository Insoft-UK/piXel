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
NSMutableData *closestLUT;

// MARK: - Init

- (id)init {
    if ((self = [super init])) {
        self.mutableData = [NSMutableData dataWithCapacity:1024];
        [self.mutableData setLength:1024];
        colorLUT = (UInt32 *)self.mutableData.mutableBytes;
        
        closestLUT = [NSMutableData dataWithLength:(1 << 24) * sizeof(UInt16)];
        
        
        [self loadAdobeColorTable:[NSBundle.mainBundle pathForResource:@"Default" ofType:@"act"]];
    }
    
    return self;
}

// MARK: - Public Instance Methods

- (void)loadAdobeColorTable:(NSString * _Nonnull)file {
    NSData *data = [NSData dataWithContentsOfFile:file];
    
    if (data.length == 768 || data.length == 772) {
        memset(closestLUT.mutableBytes, 0xFF, closestLUT.length);
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
        for (int n = 0; n < self.defined; n++) {
            color = (UInt32)adobeColorTable->colors[n].r << 24 | (UInt32)adobeColorTable->colors[n].g << 16 | (UInt32)adobeColorTable->colors[n].b << 8 | 255;
            colorLUT[n] = CFSwapInt32BigToHost(color);
        }
        
        if (self.transparency == -1) {
            _transparencyColor = [NSColor clearColor];
            return;
        } else {
            _transparencyColor = [Colors colorFromRgba:colorLUT[self.transparency]];
        }
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
    
    for (int n = 0; n < self.defined; n++) {
        UInt32 color = CFSwapInt32HostToBig(colorLUT[n]);
        adobeColorTable->colors[n].r = color >> 24;
        adobeColorTable->colors[n].g = color >> 16;
        adobeColorTable->colors[n].b = color >> 8;
    }
    
    [fileHandler writeData:data];
    
    [fileHandler closeFile];
}

- (void)mapColorsToColorTable:(const void *)pixelData lengthInBytes:(size_t)length {
    UInt8 r, g, b;
    UInt32 *pixels = (UInt32 *)pixelData;
    SInt16 *closestTable = (SInt16 *)closestLUT.mutableBytes;
    
    while (length--) {
        UInt32 pixel = pixels[length];
        
#ifdef __LITTLE_ENDIAN__
        UInt32 key = pixel & 0xFFFFFF;
#else
        UInt32 key = pixel >> 8;
#endif
        
        if (closestTable[key] >= 0) {
            pixels[length] = colorLUT[closestTable[key]];
            continue;
        }
        
#ifdef __LITTLE_ENDIAN__
        r = pixel;
        g = pixel >> 8;
        b = pixel >> 16;
#else
        r = pixel >> 24;
        g = pixel >> 16;
        b = pixel >> 8;
#endif
        UInt8 closestIndex = 0;
        int closestDistance = INT_MAX;
        
        for (int index = 0; index < self.defined; index++) {
            UInt32 lutColor = colorLUT[index];
#ifdef __LITTLE_ENDIAN__
            UInt8 lutR = lutColor;
            UInt8 lutG = lutColor >> 8;
            UInt8 lutB = lutColor >> 16;
#else
            UInt8 lutR = lutColor >> 24;
            UInt8 lutG = lutColor >> 16;
            UInt8 lutB = lutColor >> 8;
#endif
            int distance = (r - lutR) * (r - lutR) +
                           (g - lutG) * (g - lutG) +
                           (b - lutB) * (b - lutB);
            if (distance < closestDistance) {
                closestDistance = distance;
                closestIndex = (UInt8)index;
            }
        }
        
        closestTable[key] = closestIndex;
        
        pixels[length] = colorLUT[closestIndex];
    }
}

// MARK: - Public Getter & Setters

- (void)setDefinedColors:(NSUInteger)value {
    _defined = value < 1 ? 256 : value;
}

- (void)setTransparencyColor:(NSColor *)color {
    if (self.transparency == -1) return;
    
    UInt32 RGBA = (UInt32)(color.redComponent * 255) << 24 |
                  (UInt32)(color.greenComponent * 255) << 16 |
                  (UInt32)(color.blueComponent * 255) << 8 |
                  (UInt32)(color.alphaComponent * 255);
    
    colorLUT[self.transparency] = CFSwapInt32BigToHost(RGBA);
    _transparencyColor = color;
    
    memset(closestLUT.mutableBytes, 0xFF, closestLUT.length);
}

- (UInt32 *)colors {
    return colorLUT;
}

@end
