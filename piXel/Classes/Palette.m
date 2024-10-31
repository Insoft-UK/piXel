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

@interface Palette()

// MARK: - Private Properties
@property NSMutableData *mutableData;


@end


@implementation Palette

// MARK: - Init

-(id)init {
    if ((self = [super init])) {
        [self setup];
    }
    
    return self;
}

-(void)setup {
    self.mutableData = [NSMutableData dataWithCapacity:1024];
    
    [self loadPhotoshopActFile:[NSBundle.mainBundle pathForResource:@"Default" ofType:@"act"]];
    
    _bytes = (UInt8 *)self.mutableData.bytes;
    
}

// MARK: - Public Instance Methods


-(void)loadPhotoshopActFile:(NSString* _Nonnull)file {
    NSData *data = [NSData dataWithContentsOfFile:file];
    
    if ( data.length >= 768 ) {
        UInt8* byte = ( UInt8* )data.bytes;
        UInt16 c = 0;
        
        if ( data.length == 772 ) {
            _colorCount =  CFSwapInt16BigToHost(*(UInt16 *)(data.bytes + 768));
            self.mutableData.length = self.colorCount * sizeof(UInt32);
            _transparentIndex =  CFSwapInt16BigToHost(*(UInt16 *)(data.bytes + 770));
        } else {
            _colorCount = 256;
            _transparentIndex = 0xFFFF;
        }
        
        for (; c < self.colorCount; c++) {
            [self setPaletteColorWithRed:byte[0] green:byte[1] blue:byte[2] atIndex:c];
            byte += 3;
        }
    }
}

-(void)saveAsPhotoshopActAtPath:( NSString* _Nonnull )path {
    
    //NSFileHandle *fileHandler = [NSFileHandle fileHandleForWritingAtPath:path];
    FILE *fp;
    
    fp = fopen([path UTF8String], "wb");
    
    if ( fp != nil ) {
        NSMutableData* act = [NSMutableData dataWithCapacity:772];
        if (act != nil) {
            act.length = 772;
            UInt8* byte = ( UInt8* )act.mutableBytes;
            UInt16 c = 0;
            
            UInt32 *pal = self.mutableData.mutableBytes;
            
            for (; c < self.colorCount; c++) {
                
                UInt32 rgb = pal[c & 255];
#ifdef __LITTLE_ENDIAN__
                rgb = CFSwapInt32HostToBig(rgb); // / ABGR -> RGBA
#endif
                
                // RGBA
                byte[0] = rgb >> 24;
                byte[1] = ( rgb >> 16 ) & 255;
                byte[2] = ( rgb >> 8 ) & 255;
                
#ifdef DEBUG
                NSLog(@"R:0x%02X, G:0x%02X, B:0x%02X", byte[0], byte[1], byte[2]);
#endif
                
                byte += 3;
            }
            
            // Zero... out any unused palette entries.
            for (; c < 256; c++) {
                *byte++ = 0;
                *byte++ = 0;
                *byte++ = 0;
            }
            
            fwrite(act.bytes, sizeof(char), 768, fp);
            
            c = CFSwapInt16HostToBig(self.colorCount);
            fwrite(&c, sizeof(UInt16), 1, fp);
            
            c = CFSwapInt16HostToBig(self.transparentIndex);
            fwrite(&c, sizeof(UInt16), 1, fp);
            
            
            //[fileHandler writeData:actData];
            
        }
        //[fileHandler closeFile];
        fclose(fp);
    }
}



-(UInt32)packedRGBColorAtIndex:(NSUInteger)index {
    UInt32 *pal = self.mutableData.mutableBytes;
    return pal[index & 255];
}


// MARK: - Public Getter & Setters


-(void)setPaletteColorWithPackedRGB:(UInt32)rgb atIndex:(NSUInteger)index {
    *( UInt32* )( self.mutableData.mutableBytes + ( ( index & 255 ) * sizeof(UInt32) ) ) = rgb | 0xFF000000;
}

-(void)setPaletteColorWithRed:(UInt8)r green:(UInt8)g blue:(UInt8)b atIndex:(NSUInteger)index {
    *( UInt32* )( self.mutableData.mutableBytes + ( ( index & 255 ) * sizeof(UInt32) ) ) = (UInt32)r | ((UInt32)g << 8) | ((UInt32)b << 16) | 0xFF000000;
    if (index == _transparentIndex) {
        *( UInt32* )( self.mutableData.mutableBytes + ( ( index & 255 ) * sizeof(UInt32) ) ) &= 0x00FFFFFF;
    }
}

-(void)setColorCount:(NSUInteger)count {
    _colorCount = count < 1 ? 256 : count;
    //    [Colors redrawPalette:self.mutableData.bytes colorCount:self.colorCount];
}

-(void)setTransparentIndex:(NSUInteger)index {
    _transparentIndex = index & 255;
}

// MARK:- Private Class Methods

+(BOOL)isAnyRepeatsInList:( const UInt16* )list withLength:( NSUInteger )length {
    for (NSUInteger i = 0; i < length; i++) {
        for (NSUInteger j = 0; j < length; j++) {
            if (i != j) {
                if (list[i] == list[j]) {
                    return YES;
                }
            }
        }
    }
    return NO;
}

@end
