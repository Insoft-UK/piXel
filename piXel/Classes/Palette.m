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

#import "Palette.h"
#import "piXel-Swift.h"

typedef struct __attribute__((__packed__)) {
    struct {
        UInt8 r, g, b;
    } colors[256];
    
    UInt16 defined;
    UInt16 transparency;
} AdobeColorTable;

@interface Palette()

// MARK: - Private Properties
@property NSMutableData *mutableData;

@end

@implementation Palette

// MARK: - Init

- (id)init {
    if ((self = [super init])) {
        self.mutableData = [NSMutableData dataWithCapacity:1024];
        [self.mutableData setLength:1024];
        _colors = (UInt32 *)self.mutableData.mutableBytes;
        [self loadPhotoshopActFile:[NSBundle.mainBundle pathForResource:@"Default" ofType:@"act"]];
    }
    
    return self;
}

// MARK: - Public Instance Methods

- (void)loadPhotoshopActFile:(NSString * _Nonnull)file {
    NSData *data = [NSData dataWithContentsOfFile:file];
    
    if (data.length == 768 || data.length == 772) {
        AdobeColorTable *adobeColorTable = (AdobeColorTable *)data.bytes;
        
        if (data.length == 772) {
            _definedColors = CFSwapInt16BigToHost(adobeColorTable->defined);
            [self.mutableData setLength:self.definedColors * sizeof(UInt32)];
            _transparencyIndex = CFSwapInt16BigToHost(adobeColorTable->transparency);
        } else {
            _definedColors = 256;
            _transparencyIndex = -1;
        }
        
        UInt32 color;
        for (int n = 0; n < self.definedColors; n++) {
            color = (UInt32)adobeColorTable->colors[n].r << 24 | (UInt32)adobeColorTable->colors[n].g << 16 | (UInt32)adobeColorTable->colors[n].b << 8 | 255;
            self.colors[n] = CFSwapInt32BigToHost(color);
        }
        
        if (_transparencyIndex == -1) {
            _transparencyColor = [NSColor clearColor];
            return;
        } else {
            _transparencyColor = [Colors colorFromRgba:self.colors[self.transparencyIndex]];
        }
    }
}

-(void)saveAsPhotoshopActAtPath:(NSString * _Nonnull )path {
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
    
    adobeColorTable->defined = CFSwapInt16HostToBig(self.definedColors);
    adobeColorTable->transparency = CFSwapInt16HostToBig(self.transparencyIndex);
    
    for (int n = 0; n < self.definedColors; n++) {
        UInt32 color = CFSwapInt32HostToBig(self.colors[n]);
        adobeColorTable->colors[n].r = color >> 24;
        adobeColorTable->colors[n].g = color >> 16;
        adobeColorTable->colors[n].b = color >> 8;
    }
    
    [fileHandler writeData:data];
    
    [fileHandler closeFile];
}


// MARK: - Public Getter & Setters

- (void)setDefinedColors:(NSUInteger)value {
    _definedColors = value < 1 ? 256 : value;
}

- (void)setTransparencyColor:(NSColor *)color {
    if (self.transparencyIndex == -1) return;
    
    self.colors[self.transparencyIndex] = CFSwapInt32BigToHost((UInt32)(color.redComponent * 255) << 24 | (UInt32)(color.greenComponent * 255) << 16 | (UInt32)(color.blueComponent * 255) << 8 | (UInt32)(color.alphaComponent * 255));
    _transparencyColor = color;
}

@end
