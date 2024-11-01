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
#import "Image.h"
#import <Cocoa/Cocoa.h>

@interface MainScene()

//@property SKLabelNode *info;
@property NSTimeInterval lastUpdateTime;
@property ViewController* viewController;
@property AppDelegate* appDelegate;

@end

@implementation MainScene

// MARK: - View

- (void)didMoveToView:(SKView *)view {
    [self setup];
    
    self.viewController = (ViewController *)NSApplication.sharedApplication.windows.firstObject.contentViewController;
    self.appDelegate = (AppDelegate *)NSApplication.sharedApplication.delegate;
    
    Singleton.sharedInstance.mainScene = self;
}

- (void)willMoveFromView:(SKView *)view {
    
}

// MARK: - Setup

- (void)setup {
    CGSize size = NSApp.windows.firstObject.frame.size;
    self.size = CGSizeMake(size.width, size.height - 28);
    
    
    
    Singleton.sharedInstance.image.position = CGPointMake(1024 / 2, 768 / 2);
    [self addChild:Singleton.sharedInstance.image];
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
    
    switch (event.keyCode) {
        case Space:
            [image showOriginal];
            break;
            
        case LeftArrow:
            if (image.isAutoBlockSizeAdjustEnabled) break;
            [image setBlockSize: image.blockSize -= 0.01];
            break;
            
        case RightArrow:
            if (image.isAutoBlockSizeAdjustEnabled) break;
            [image setBlockSize: image.blockSize += 0.01];
            break;
            
        case DownArrow:
            [image setBlockSize: image.blockSize -= 1];
            break;
            
        case UpArrow:
            [image setBlockSize: image.blockSize += 1];
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
    NSTimeInterval delta = currentTime - self.lastUpdateTime;
    self.lastUpdateTime = currentTime;
    
    Image* image = Singleton.sharedInstance.image;
    
    if ([image updateWithDelta:delta]) {
        CGFloat w = image.originalSize.width / image.blockSize;
        CGFloat h = image.originalSize.height / image.blockSize;
        
        self.viewController.widthText.stringValue = [NSString stringWithFormat:@"%d", (int)image.originalSize.width];
        self.viewController.heightText.stringValue = [NSString stringWithFormat:@"%d", (int)image.originalSize.height];
        if (image.isColorNormalizationEnabled) {
            self.viewController.infoText.stringValue = [NSString stringWithFormat:@"Repixelated Image Resolution: %dx%d - Block Size: %.2f, Threshold %ld",
                                                        (int)w,
                                                        (int)h,
                                                        image.blockSize,
                                                        image.threshold
            ];
        }
        else {
            self.viewController.infoText.stringValue = [NSString stringWithFormat:@"Repixelated Image Resolution: %dx%d - Block Size: %.2f",
                                                        (int)w,
                                                        (int)h,
                                                        image.blockSize
            ];
        }
        
       
        
        [self.appDelegate updateAllMenus];
    }
    
    self.viewController.zoomText.stringValue = [NSString stringWithFormat:@"%d%%", (int)image.xScale * 100];
    [self.viewController redrawPalette:image.palette.bytes colorCount:image.palette.colorCount];
}








@end
