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

#ifndef Palette_h
#define Palette_h

@interface Palette: NSObject

// MARK: - Class Properties

@property (readonly) NSInteger colorCount;
@property (readonly) NSUInteger transparentIndex;
@property (readonly) UInt8  * _Nonnull  bytes;

// MARK: - Class Instance Methods

-(void)loadPhotoshopActFile:( NSString* _Nonnull )file;
-(void)saveAsPhotoshopActAtPath:( NSString* _Nonnull )path;
-(UInt32)packedRGBColorAtIndex:(NSUInteger)index;

// MARK: - Class Setters

-(void)setPaletteColorWithPackedRGB:( UInt32 )rgb atIndex:(NSUInteger)index;
-(void)setPaletteColorWithRed:(UInt8)r green:(UInt8)g blue:(UInt8)b atIndex:(NSUInteger)index;
-(void)setTransparentIndex:(NSUInteger)index;

@end


#endif /* Palette_h */
