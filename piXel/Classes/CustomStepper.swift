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

class CustomStepper: NSStepper {
    
    // Define arrow properties
    let arrowLineWidth: CGFloat = 2.0  // Line width for the arrow
    let arrowLength: CGFloat = 3.0    // Length of the arrow
    let arrowWidth: CGFloat = 5.0      // Width of the arrow lines
    let padding: CGFloat = 10.0         // Padding around the arrow
    
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
        layer?.masksToBounds = true
        needsDisplay = true
    }
    
    // Override the draw function to manually draw the arrows
    override func draw(_ dirtyRect: NSRect) {
        // Clear the background (ensure transparency)
        NSColor.clear.setFill()
        dirtyRect.fill()
        
        // Calculate the height for each arrow area (divide into top and bottom)
        let arrowAreaHeight = (dirtyRect.height - (3 * padding)) / 2
        
        // Up arrow positioning (centered horizontally, placed at the top of the stepper)
        let upArrowRect = NSRect(
            x: (dirtyRect.width - arrowWidth) / 2,
            y: dirtyRect.maxY - padding - arrowAreaHeight - arrowLineWidth,
            width: arrowWidth,
            height: arrowLength
        )
        
        // Down arrow positioning (centered horizontally, placed at the bottom of the stepper)
        let downArrowRect = NSRect(
            x: (dirtyRect.width - arrowWidth) / 2,
            y: dirtyRect.minY + padding + arrowAreaHeight - arrowLineWidth,
            width: arrowWidth,
            height: arrowLength
        )
        
        // Draw the arrows
        drawArrow(in: upArrowRect, pointingUp: true)    // Draw the up arrow
        drawArrow(in: downArrowRect, pointingUp: false) // Draw the down arrow
    }
    
    // Helper function to draw a single caret-style arrow (either up or down)
    private func drawArrow(in rect: NSRect, pointingUp: Bool) {
        let path = NSBezierPath()
        
        // Set the line width and line cap style
        path.lineWidth = arrowLineWidth
        path.lineCapStyle = .round
        
        let middleX = rect.midX
        let startY = rect.minY
        let endY = rect.maxY
        
        // For up arrow: draw lines from the bottom left and bottom right, meeting at the top
        if pointingUp {
            path.move(to: NSPoint(x: middleX - arrowWidth / 2, y: startY))
            path.line(to: NSPoint(x: middleX, y: endY)) // top point
            path.move(to: NSPoint(x: middleX + arrowWidth / 2, y: startY))
            path.line(to: NSPoint(x: middleX, y: endY)) // top point
        }
        // For down arrow: reverse the direction
        else {
            path.move(to: NSPoint(x: middleX - arrowWidth / 2, y: endY))
            path.line(to: NSPoint(x: middleX, y: startY)) // bottom point
            path.move(to: NSPoint(x: middleX + arrowWidth / 2, y: endY))
            path.line(to: NSPoint(x: middleX, y: startY)) // bottom point
        }
        
        // Set the arrow color and draw the lines
        NSColor.white.setStroke()  // Change the color as needed
        path.stroke()
    }
}
