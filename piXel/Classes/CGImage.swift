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

import CoreGraphics

#if canImport(UniformTypeIdentifiers)
import UniformTypeIdentifiers
#endif

#if canImport(MobileCoreServices)
import MobileCoreServices
#endif

extension CGImage {
    static func create(fromPixelData pixelData:UnsafePointer<UInt8>, ofSize size:CGSize) -> CGImage? {
        if size.width < 1 || size.height < 1 {
            return nil
        }
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let provider = CGDataProvider(data: CFDataCreate(nil, pixelData, Int(size.width) * Int(size.height) * 4))
        CGImageSourceCreateWithDataProvider(provider!, nil)
        
        let cgimg = CGImage(
            width: Int(size.width),
            height: Int(size.height),
            bitsPerComponent: Int(8),
            bitsPerPixel: Int(32),
            bytesPerRow: Int(size.width) * Int(4),
            space: colorSpace,
            bitmapInfo: bitmapInfo,
            provider: provider!,
            decode: nil,
            shouldInterpolate: true,
            intent: CGColorRenderingIntent.defaultIntent
        )
        
        return cgimg
    }
    
    @discardableResult func write(to destinationURL: URL) -> Bool {
        if #available(iOS 14.0, *) {
            guard let destination = CGImageDestinationCreateWithURL(destinationURL as CFURL, UTType.png.identifier as CFString, 1, nil) else { return false }
            CGImageDestinationAddImage(destination, self, nil)
            return CGImageDestinationFinalize(destination)
        } else {
            // Fallback on earlier versions
            guard let destination = CGImageDestinationCreateWithURL(destinationURL as CFURL, kUTTypePNG, 1, nil) else { return false }
            CGImageDestinationAddImage(destination, self, nil)
            return CGImageDestinationFinalize(destination)
        }
    }
    
    func resize(_ size: CGSize) -> CGImage? {
        let width: Int = Int(size.width)
        let height: Int = Int(size.height)
        
        let bytesPerPixel = self.bitsPerPixel / self.bitsPerComponent
        let destBytesPerRow = width * bytesPerPixel
        
        
        guard let colorSpace = self.colorSpace else { return nil }
        guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: self.bitsPerComponent, bytesPerRow: destBytesPerRow, space: colorSpace, bitmapInfo: self.alphaInfo.rawValue) else { return nil }
        
        context.interpolationQuality = .none
        context.draw(self, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        return context.makeImage()
    }
}

// MARK: - Objective-C

@objc class _CGImage: NSObject {
    @objc static func create(fromPixelData pixelData:UnsafePointer<UInt8>, ofSize size:CGSize) -> CGImage? {
        return CGImage.create(fromPixelData: pixelData, ofSize: size)
    }
    
    @objc func write(cgimage: CGImage, to destinationURL: URL) -> Bool {
        return cgimage.write(to: destinationURL)
    }
}
