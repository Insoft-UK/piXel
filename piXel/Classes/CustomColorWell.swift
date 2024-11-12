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
            let colorWellBounds = self.bounds
            
            NSColor.clear.setFill()
            dirtyRect.fill()
            let path = NSBezierPath(roundedRect: colorWellBounds, xRadius: cornerRadius, yRadius: cornerRadius)
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
