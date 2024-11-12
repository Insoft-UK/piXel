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

import Foundation

@objc class SKGridNode: SKNode {
    var lightColor: SKColor = .clear
    var darkColor: SKColor = .clear
    var size: Int = 2
    var colorIndex = 0
    
    private var mutableTexture: SKMutableTexture!
    
    // MARK: - Init
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @objc init(size: CGSize) {
        super.init()
        self.lightColor = SKColor(named: "Blue")!.usingColorSpace(.deviceRGB)!
        self.darkColor = SKColor(named: "DarkBlue")!.usingColorSpace(.deviceRGB)!
        mutableTexture = SKMutableTexture(size: size)
        let node = SKSpriteNode(texture: mutableTexture, color: .clear, size: size)
        node.setScale(8.0)
        node.texture?.filteringMode = .nearest
        addChild(node)
    }
    
    @objc func update() {
        let width = Int(mutableTexture.size().width)
        let height = Int(mutableTexture.size().height)
        
        let lightColor = Colors.RgbaFrom(color: self.lightColor)
        let darkColor = Colors.RgbaFrom(color: self.darkColor)
        
        mutableTexture.modifyPixelData { pixelData, lengthInBytes in
            // Cast the pixelData to a UInt32 pointer for pixel manipulation
            let dest = pixelData!.assumingMemoryBound(to: UInt32.self)

            // Copy the pixels from the source to the destination
            for y in 0..<height {
                for x in 0..<width {
                    if y / self.size & 1 != 0 {
                        dest[x + y * width] = x / self.size & 1 != 0 ? darkColor : lightColor
                    } else {
                        dest[x + y * width] = x / self.size & 1 != 0 ? lightColor : darkColor
                    }
                }
            }
        }
    }
}
