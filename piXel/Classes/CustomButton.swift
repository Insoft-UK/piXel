import Cocoa

@IBDesignable
open class CustomButton: NSButton {
	public required init?(coder: NSCoder) {
		super.init(coder: coder)
		setup()
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		setup()
	}

	private func setup() {
//		let isOn = state == .on

		wantsLayer = true
		layer?.masksToBounds = false
		layer?.cornerRadius = 15
		layer?.borderWidth = 2
        layer?.borderColor = .init(gray: 0.25, alpha: 1.0)
        layer?.backgroundColor = .init(gray: 0, alpha: 0)
		needsDisplay = true
	}



	override open func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
	}

	override open func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
	}

	override open func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
	}

	override open func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)
	}
}

extension CustomButton: NSViewLayerContentScaleDelegate {
	public func layer(_ layer: CALayer, shouldInheritContentsScale newScale: CGFloat, from window: NSWindow) -> Bool { true }
}
