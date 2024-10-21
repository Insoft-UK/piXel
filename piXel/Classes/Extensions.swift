/*
 Copyright © 2022 Insoft. All rights reserved.
 
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

#if os(iOS) || os(tvOS)
import UIKit
import MobileCoreServices // before iOS 14
#else
import Cocoa
#endif
import CoreGraphics
import Foundation
import UniformTypeIdentifiers



@objc class Extenions : NSObject {
    @objc @discardableResult class func writeCGImage(_ image: CGImage, to destinationURL: URL) -> Bool {
        return image.write(to: destinationURL)
    }
    
    @objc class func createCGImage(fromPixelData pixelData:UnsafePointer<UInt8>, ofSize size:CGSize) -> CGImage? {
        return CGImage.create(fromPixelData: pixelData, ofSize: size)
    }
    
    @objc class func resizeCGImage(_ image: CGImage, toSize size: CGSize) -> CGImage? {
        return image.resize(size)
    }
#if !os(macOS)
    @objc class func tiledUIImage(fromImage image : UIImage, ofSize size:CGSize) -> UIImage? {
        return UIImage.tiled(fromImage: image, ofSize: size)
    }
#endif
    
    @objc class func convertCIImageToCGImage(inputImage: CIImage) -> CGImage? {
        let context = CIContext(options: nil)
        if let cgImage = context.createCGImage(inputImage, from: inputImage.extent) {
            return cgImage
        }
        return nil
    }
}
