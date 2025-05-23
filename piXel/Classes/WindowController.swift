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


import Cocoa

class WindowController: NSWindowController {
    
    
    
    @IBAction private func zoomIn(_ sender: NSToolbarItem) {
        guard let image = Singleton.sharedInstance()?.mainScene.image else {
            return
        }
        if image.yScale < 50.0 {
            image.setScale(image.yScale + 1.0)
        }
    }
    
    @IBAction private func zoomOut(_ sender: NSToolbarItem) {
        guard let image = Singleton.sharedInstance()?.mainScene.image else {
            return
        }
        if image.yScale > 1.0 {
            image.setScale(image.yScale - 1.0)
        }
    }
    
    @IBAction private func coarse(_ sender: NSToolbarItem) {
        guard let image = Singleton.sharedInstance()?.mainScene.image else {
            return
        }
        if sender.tag < 0 {
            image.blockSize -= 1.0
        }
        else {
            image.blockSize += 1.0
        }
    }
    
    @IBAction private func fine(_ sender: NSToolbarItem) {
        guard let image = Singleton.sharedInstance()?.mainScene.image else {
            return
        }
        if sender.tag < 0 {
            image.blockSize -= 0.01
        }
        else {
            image.blockSize += 0.01
        }
    }
    
    
}
