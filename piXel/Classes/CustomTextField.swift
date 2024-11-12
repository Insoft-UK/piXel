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
open class CustomTextField: NSTextField {
//    @IBInspectable public var padding: NSEdgeInsets = NSEdgeInsets(top: 0, left: 5, bottom: 0, right: 5) {
//        didSet { needsDisplay = true }
//    }
    @IBInspectable public var fillColor: NSColor = .black {
        didSet { needsDisplay = true }
    }
    @IBInspectable public var cornerRadius: CGFloat = 8.0 {
        didSet { needsDisplay = true }
    }
    @IBInspectable public var borderColor: NSColor = .black {
        didSet { needsDisplay = true }
    }
    @IBInspectable public var borderWidth: CGFloat = 2.0 {
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
        // Set up the custom padded cell
//        if let cell = self.cell as? NSTextFieldCell {
//            let paddedCell = PaddedTextFieldCell(textCell: self.stringValue)
//            paddedCell.textPadding = NSEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
//            self.cell = paddedCell
//        }
        
        wantsLayer = true
        layer?.masksToBounds = false
        layer?.cornerRadius = cornerRadius
        layer?.borderWidth = borderWidth
        layer?.borderColor = .init(gray: 0.25, alpha: 1.0)
        layer?.backgroundColor = .init(gray: 0, alpha: 0)
        needsDisplay = true
    }
    

    
    override open func draw(_ dirtyRect: CGRect) {
        super.draw(dirtyRect)
        
        
//        let paddedRect = dirtyRect.insetBy(dx: padding.left + padding.right,dy: padding.top + padding.bottom)
//        super.draw(paddedRect)
        
        let path = NSBezierPath(roundedRect: bounds, xRadius: cornerRadius, yRadius: cornerRadius)
        
        
        if (borderWidth > 0) {
            borderColor.setStroke()
            path.lineWidth = borderWidth
            path.stroke()
        }
        
        
    }
    override open func drawFocusRingMask() {
    }
    
}

extension CustomTextField: NSViewLayerContentScaleDelegate {
    public func layer(_ layer: CALayer, shouldInheritContentsScale newScale: CGFloat, from window: NSWindow) -> Bool { true }
}

