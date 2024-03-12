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

import Foundation
#if os(macOS)
import Cocoa
#endif

extension CGFloat {
#if !os(macOS)
    static let scale = UIScreen.main.scale
    static let scaleFactor = UIDevice.current.userInterfaceIdiom == .pad ? 1.5 * UIScreen.main.scale : UIScreen.main.scale
    static let nativeScale = UIScreen.main.nativeScale
    
    static var width: CGFloat {
        return UIScreen.main.bounds.size.width
    }
    static var nativeWidth: CGFloat {
        return UIScreen.main.nativeBounds.size.width
    }
    static var height: CGFloat {
        return UIScreen.main.bounds.size.height
    }
    static var nativeHight: CGFloat {
        return UIScreen.main.nativeBounds.size.height
    }
#else
    static let scale = NSScreen.main?.backingScaleFactor
    static let scaleFactor = 1.5 * (NSScreen.main?.backingScaleFactor ?? 1.0)
#endif
    
    static let margin: CGFloat = 18.0
    
    static func degrees(_ angle: CGFloat) -> CGFloat {
        return angle * .pi/180
    }
    
    static let earthGravity: CGFloat = 9.8;
}

