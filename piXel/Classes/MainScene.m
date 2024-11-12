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

#import "Image.hh"
#import <Cocoa/Cocoa.h>

#import "piXel-Swift.h"

@implementation MainScene

//NSTimeInterval lastUpdateTime;
const ViewController* viewController;
const AppDelegate* appDelegate;

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

    _image = [[Image alloc] initWithSize:CGSizeMake(1024 * 4, 768 * 4)];
    _image.position = CGPointMake(self.size.width / 2, self.size.height / 2);
    [_image setZPosition:1.0];
    [self addChild:_image];
    
    _grid = [[SKGridNode alloc] initWithSize:CGSizeMake(self.size.width / 8, self.size.height / 8)];
    if (_grid != nil) {
        _grid.position = CGPointMake(self.size.width / 2, self.size.height / 2);
        [_grid update];
        [self addChild:_grid];
    }
    
    
}

// MARK: - Keyboard Events

- (void)keyDown:(NSEvent *)event {
    
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
            [self.image showGuideImage];
            break;
            
        case LeftArrow:
            if (flags & NSEventModifierFlagOption) {
                [self.image setWidth: self.image.width - 1];
            } else {
                if (self.image.isAutoBlockSizeAdjustEnabled) break;
                [self.image setBlockSize: self.image.blockSize -= 0.01];
            }
            break;
            
        case RightArrow:
            if (flags & NSEventModifierFlagOption) {
                [self.image setWidth: self.image.width + 1];
            } else {
                if (self.image.isAutoBlockSizeAdjustEnabled) break;
                [self.image setBlockSize: self.image.blockSize += 0.01];
            }
            break;
            
        case DownArrow:
            if (flags & NSEventModifierFlagOption) {
                [self.image setHeight: self.image.height - 1];
            } else {
                [self.image setBlockSize: self.image.blockSize -= 1];
            }
            break;
            
        case UpArrow:
            if (flags & NSEventModifierFlagOption) {
                [self.image setHeight: self.image.height + 1];
            } else {
                [self.image setBlockSize: self.image.blockSize += 1];
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
    enum {
        Space = 0x31
    };
    
    switch (event.keyCode) {
        case Space:
            [self.image hideGuideImage];
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
//    NSTimeInterval delta = currentTime - lastUpdateTime;
//    lastUpdateTime = currentTime;
    
    
    if (self.image.hasChanged) {
        [self.image update];
        
        CGFloat w = self.image.originalSize.width / self.image.blockSize;
        CGFloat h = self.image.originalSize.height / self.image.blockSize;
        
        viewController.widthText.stringValue = [NSString stringWithFormat:@"%d", (int)self.image.originalSize.width];
        viewController.heightText.stringValue = [NSString stringWithFormat:@"%d", (int)self.image.originalSize.height];
        if (self.image.isNormalizeEnabled) {
            viewController.infoText.stringValue = [NSString stringWithFormat:@"Repixelated Image Resolution: %dx%d - Block Size: %.2f, Threshold %ld",
                                                        (int)w,
                                                        (int)h,
                                                   self.image.blockSize,
                                                   self.image.threshold
            ];
        }
        else {
            viewController.infoText.stringValue = [NSString stringWithFormat:@"Repixelated Image Resolution: %dx%d - Block Size: %.2f",
                                                        (int)w,
                                                        (int)h,
                                                   self.image.blockSize
            ];
        }
        [viewController redrawPalette:(const UInt8 *)self.image.clut.colors colorCount:self.image.clut.defined];
        viewController.zoomText.stringValue = [NSString stringWithFormat:@"%d%%", (int)self.image.xScale * 100];
    }
    
    
    
}


@end
