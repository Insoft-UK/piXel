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

@IBDesignable
open class CustomColorWell: NSColorWell {
    @IBInspectable public var fillColor: NSColor = .systemBlue {
        didSet { needsDisplay = true }
    }
    @IBInspectable public var cornerRadius: CGFloat = 0.0 {
        didSet { needsDisplay = true }
    }
    @IBInspectable public var borderColor: NSColor = .clear {
        didSet { needsDisplay = true }
    }
    @IBInspectable public var borderWidth: CGFloat = 3.0 {
        didSet { needsDisplay = true }
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    private func setup() {
        wantsLayer = true
        layer?.masksToBounds = false
        layer?.cornerRadius = cornerRadius
        layer?.borderWidth = borderWidth
        layer?.borderColor = .init(gray: 0.0, alpha: 0.0)
        layer?.backgroundColor = .init(gray: 0, alpha: 0)
        needsDisplay = true
    }
    
        override open func draw(_ dirtyRect: CGRect) {
            NSColor.clear.setFill()
            dirtyRect.fill()
            let path = NSBezierPath(roundedRect: bounds, xRadius: cornerRadius, yRadius: cornerRadius)
            fillColor = self.color
            fillColor.setFill()
            path.fill()
            if (borderWidth > 0) {
                borderColor.setStroke()
                path.lineWidth = borderWidth
                path.stroke()
            }
        }
        override open func drawFocusRingMask() {}
}

extension CustomColorWell: NSViewLayerContentScaleDelegate {
    public func layer(_ layer: CALayer, shouldInheritContentsScale newScale: CGFloat, from window: NSWindow) -> Bool { true }
}
