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

#import <CoreGraphics/CoreGraphics.h>

#ifndef Image_h
#define Image_h


@interface Image: SKNode

// MARK: - Class Properties

@property (readonly) NSUInteger zoom;


// MARK: - Class Init

-(id)initWithSize:(CGSize)size;

// MARK: - Class Instance Methods



-(void)updateWithDelta:(NSTimeInterval)delta;
-(void)saveImageAtURL:(NSURL *)url;
-(void)loadImageWithContentsOfURL:(NSURL *)url;

- (void)EPX;

// MARK: - Class Methods


// MARK: - Class Setters
- (void)setScale:(CGFloat)scale;
@end


#endif /* Image_h */
