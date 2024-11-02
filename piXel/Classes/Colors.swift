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


@objc class Colors : NSObject {
    @objc class func colorFrom(rgba: UInt32) -> NSColor {
        let r = (rgba.bigEndian >> 24) & 255
        let g = (rgba.bigEndian >> 16) & 255
        let b = (rgba.bigEndian >> 8) & 255
        let a = rgba.bigEndian & 255
        
        return NSColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(a) / 255.0)
    }
    
    @objc class func RgbaFrom(color: NSColor) -> UInt32 {
        var result: UInt32
        result = UInt32(color.redComponent * 255) << 24 | UInt32(color.greenComponent * 255) << 16 | UInt32(color.blueComponent * 255) << 8 | UInt32(color.alphaComponent * 255)
        return result.bigEndian
    }
}
