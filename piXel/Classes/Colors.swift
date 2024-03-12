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


import SpriteKit



@objc class Colors : NSObject {
    
    class var red:Int         { return 0xb42222 }
    
    class func colorFrom(rgb: Int) -> SKColor {
        return SKColor(red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
                       green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
                       blue: CGFloat(rgb & 0x0000FF) / 255.0,
                       alpha: 1.0)
    }
    
    class func rgbFrom(color: SKColor) -> Int {
        return Colors.rgbaFrom(color: color) >> 8
    }
    
    class func rgbaFrom(color: SKColor) -> Int {
        return
            ( Int(color.redComponent * 255.0) << 24 ) |
            ( Int(color.greenComponent * 255.0) << 16 ) |
            ( Int(color.redComponent * 255.0) << 8 ) | 255
    }
    
    class func colorFrom8Bit(rgb: Int8) -> SKColor {
        return SKColor(red: CGFloat(red >> 5) / 7.0 * 255.0, green: CGFloat(rgb & 0b11100) / 28 * 255.0, blue: CGFloat(rgb & 0b11) / 3 * 255.0, alpha: 1.0)
    }
    
    
    @objc class func redrawPreview(_ bytes: UnsafePointer<UInt8>) {
        guard let image = Singleton.sharedInstance().image else {
            return
        }
        
        guard let cgImage: CGImage = .create(fromPixelData: bytes, ofSize: CGSize(width: CGFloat(image.size.width), height: CGFloat(image.size.height))) else {
            return
        }
        
        let scale = CGFloat(floor(128.0 / Float(max(image.size.width, image.size.height))))
        
            
        if let resized = cgImage.resize(CGSize(width: CGFloat(image.size.width) * scale, height: CGFloat(image.size.height) * scale)) {
            if let nsImage: NSImage = .create(fromCGImage: resized) {
                if let viewController = NSApplication.rootViewController as? ViewController {
                    viewController.imageView.image = nsImage
                    viewController.imageView.imageScaling = .scaleProportionallyDown;
                }
            }
        }
    }
    
}
