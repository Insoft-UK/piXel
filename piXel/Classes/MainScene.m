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

#import "MainScene.h"

#import "piXel-Swift.h"
#import "Image.hh"
#import <Cocoa/Cocoa.h>

@interface MainScene()

@end

@implementation MainScene

NSTimeInterval lastUpdateTime;
const ViewController* viewController;
const AppDelegate* appDelegate;

UInt32 gridLightColor;
UInt32 gridDarkColor;

// MARK: - View

- (void)didMoveToView:(SKView *)view {
    
    
    viewController = (ViewController *)NSApplication.sharedApplication.windows.firstObject.contentViewController;
    appDelegate = (AppDelegate *)NSApplication.sharedApplication.delegate;
    
    Singleton.sharedInstance.mainScene = self;
    [self setup];
}



- (void)willMoveFromView:(SKView *)view {
    
}



// MARK: - Setup

- (void)setup {
    CGSize size = NSApp.windows.firstObject.frame.size;
    self.size = CGSizeMake(size.width, size.height - 28);

    [self setGridColor: GridColorBlue];
    [self setGridSize: 8];
    
    Singleton.sharedInstance.image.position = CGPointMake(self.size.width / 2, self.size.height / 2);
    [Singleton.sharedInstance.image setZPosition:1.0];
    [self addChild:Singleton.sharedInstance.image];
}

- (void)initGrid {
    SKSpriteNode *node;
    
    if ([self childNodeWithName:@"Grid"]) {
        [[self childNodeWithName:@"Grid"] removeFromParent];
    }
    
    if (self.gridSize == 0) return;
    
    CGSize size = CGSizeMake(floor(self.size.width / (CGFloat)self.gridSize), floor(self.size.height / (CGFloat)self.gridSize));
    SKMutableTexture *texture = [[SKMutableTexture alloc] initWithSize:size];
    
    if (texture != nil) {
        [texture modifyPixelDataWithBlock:^(void *pixelData, size_t lengthInBytes) {
            UInt32 *pixel = (UInt32 *)pixelData;
            
            for (NSUInteger y = 0; y < (NSUInteger)size.height; y++) {
                for (NSUInteger x = 0; x < (NSUInteger)size.width; x++) {
                    if (y & 1) {
                        *pixel++ = x & 1 ? gridDarkColor : gridLightColor;
                    } else {
                        *pixel++ = x & 1 ? gridLightColor : gridDarkColor;
                    }
                }
            }
        }];
    
        if ((node = [SKSpriteNode spriteNodeWithTexture:(SKTexture*)texture size:texture.size]) != nil) {
            [node.texture setFilteringMode:SKTextureFilteringNearest];
            [node setPosition:CGPointMake(self.size.width / 2, self.size.height / 2)];
            [node setZPosition:-1];
            [node setScale:(CGFloat)self.gridSize];
            [node setName:@"Grid"];
            [self addChild:node];
        }
    }
}


// MARK: - Keyboard Events

- (void)keyDown:(NSEvent *)event {
    Image* image = Singleton.sharedInstance.image;
    
    enum {
        Space = 0x31,
        UpArrow = 126,
        DownArrow = 125,
        LeftArrow = 123,
        RightArrow = 124
    };
    
    NSUInteger flags = [event modifierFlags] & NSEventModifierFlagDeviceIndependentFlagsMask;
    
    switch (event.keyCode) {
        case Space:
            [image showOriginal];
            break;
            
        case LeftArrow:
            if (flags & NSEventModifierFlagOption) {
                [image setWidth: image.width - 1];
            } else {
                if (image.isAutoBlockSizeAdjustEnabled) break;
                [image setBlockSize: image.blockSize -= 0.01];
            }
            break;
            
        case RightArrow:
            if (flags & NSEventModifierFlagOption) {
                [image setWidth: image.width + 1];
            } else {
                if (image.isAutoBlockSizeAdjustEnabled) break;
                [image setBlockSize: image.blockSize += 0.01];
            }
            break;
            
        case DownArrow:
            if (flags & NSEventModifierFlagOption) {
                [image setHeight: image.height - 1];
            } else {
                [image setBlockSize: image.blockSize -= 1];
            }
            break;
            
        case UpArrow:
            if (flags & NSEventModifierFlagOption) {
                [image setHeight: image.height + 1];
            } else {
                [image setBlockSize: image.blockSize += 1];
            }
            break;
            
            
        default:
#ifdef DEBUG
            NSLog(@"keyDown:'%@' keyCode: 0x%02X", event.characters, event.keyCode);
#endif
            break;
    }
}

- (void)keyUp:(NSEvent *)event {
    Image* image = Singleton.sharedInstance.image;
    
    enum {
        Space = 0x31
    };
    
    switch (event.keyCode) {
        case Space:
            [image hideOriginal];
            break;
        default:
#ifdef DEBUG
            NSLog(@"keyUp:'%@' keyCode: 0x%02X", event.characters, event.keyCode);
#endif
            break;
    }
}


- (void)mouseDown:(NSEvent *)event {
    
    NSPoint location = event.locationInWindow;
#ifdef DEBUG
    NSLog(@"locationInWindow.x: 0x%02f locationInWindow.y: 0x%02f", location.x, location.y);
#endif
}

// MARK: - Update

-(void)update:(CFTimeInterval)currentTime {
    NSTimeInterval delta = currentTime - lastUpdateTime;
    lastUpdateTime = currentTime;
    
    Image* image = Singleton.sharedInstance.image;
    
    if ([image updateWithDelta:delta]) {
        CGFloat w = image.originalSize.width / image.blockSize;
        CGFloat h = image.originalSize.height / image.blockSize;
        
        viewController.widthText.stringValue = [NSString stringWithFormat:@"%d", (int)image.originalSize.width];
        viewController.heightText.stringValue = [NSString stringWithFormat:@"%d", (int)image.originalSize.height];
        if (image.isNormalizeEnabled) {
            viewController.infoText.stringValue = [NSString stringWithFormat:@"Repixelated Image Resolution: %dx%d - Block Size: %.2f, Threshold %ld",
                                                        (int)w,
                                                        (int)h,
                                                        image.blockSize,
                                                        image.threshold
            ];
        }
        else {
            viewController.infoText.stringValue = [NSString stringWithFormat:@"Repixelated Image Resolution: %dx%d - Block Size: %.2f",
                                                        (int)w,
                                                        (int)h,
                                                        image.blockSize
            ];
        }
    }
    
    viewController.zoomText.stringValue = [NSString stringWithFormat:@"%d%%", (int)image.xScale * 100];
    [viewController redrawPalette:(const UInt8 *)image.clut.colors colorCount:image.clut.defined];
}

// MARK: - Getter & Setters

- (void)setGridSize:(NSUInteger)newValue {
    _gridSize = newValue;
    [self initGrid];
}

- (void)setGridColor:(GridColor)newValue {
    _gridColor = newValue;
    
    UInt32 light, dark;
    
    switch (self.gridColor) {
        case GridColorLight:
            light = 0xEEEEEEFF;
            dark = 0xDDDDDDFF;
            break;
            
        case GridColorMedium:
            light = 0x888888FF;
            dark = 0x666666FF;
            break;
            
        case GridColorDark:
            light = 0x333333FF;
            dark = 0x222222FF;
            break;
        
        case GridColorRed:
            light = 0xCC0000FF;
            dark = 0x880000FF;
            break;
        
        case GridColorOrange:
            light = 0xFF8800FF;
            dark = 0xCC4400FF;
            break;
        
        case GridColorGreen:
            light = 0x00CC00FF;
            dark = 0x008800FF;
            break;
        
        case GridColorBlue:
            light = 0x0000FFFF;
            dark = 0x0000AAFF;
            break;
        
        case GridColorPurple:
            light = 0xDD00DDFF;
            dark = 0x880088FF;
            break;
        
        case GridColorNone:
        default:
            light = dark = 0;
            break;
    }
    
    gridLightColor = CFSwapInt32BigToHost(light);
    gridDarkColor = CFSwapInt32BigToHost(dark);
    
    [self initGrid];
}


@end
