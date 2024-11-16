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

class SettingsViewController: NSViewController {
    @IBOutlet weak var slider: NSSlider!
    
    @IBOutlet weak var gridView: NSGridView!
    
    @IBOutlet weak var lightColor: NSColorWell!
    @IBOutlet weak var darkColor: NSColorWell!
    
    @IBOutlet weak var imageView: NSImageView!
    
    
    var gridColorIndex = 1
    
    let image = Singleton.sharedInstance()!.mainScene.image!
    
    var window: NSWindow?
    var scene: MainScene?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.window?.styleMask.remove([.resizable, .miniaturizable, .fullScreen])
        
        if let window = NSApplication.shared.windows.first {
            self.window = window
            
            if let rootViewController = window.contentViewController as? ViewController {
                self.scene = rootViewController.skView.scene as? MainScene
            }
        }
        
        slider.integerValue = scene!.grid.size
        gridColorIndex = scene!.grid.colorIndex
        
        lightColor.color = (scene?.grid.lightColor)!
        darkColor.color = (scene?.grid.darkColor)!
        
        
        updateGridView()
        updateImageView()
    }
    
    @IBAction private func slider(_ sender: NSSlider) {
        updateImageView()
    }
    
    
    @IBAction func closeWindow(_ sender: NSButton) {
        if sender.tag == 1 {
            applySettings()
        }
        self.view.window?.close()
    }
    
    func applySettings() {
        if let scene = scene {
            scene.grid.size = slider.integerValue
            scene.grid.colorIndex = gridColorIndex
            scene.grid.lightColor =  lightColor.color
            scene.grid.darkColor =  darkColor.color
            scene.grid.update()
        }
    }

    
    @IBAction private func colorWell(_ sender: NSColorWell) {
        gridColorIndex = 0
        updateGridView()
        updateImageView()
    }
    
    private func updateImageView() {
        let mutableData = NSMutableData(length: 36864)!
        
        // Access mutableBytes directly, casting to UnsafeMutablePointer<UInt32>
        let uint32Pointer = mutableData.mutableBytes.bindMemory(to: UInt32.self, capacity: mutableData.length / MemoryLayout<UInt32>.size)
        
        let gs = slider.integerValue * 8
        // Update each UInt32 value in the buffer
        
        
        
        
        
        let light = Colors.RgbaFrom(color: self.lightColor.color)
        let dark = Colors.RgbaFrom(color: self.darkColor.color)
        
        
        
        for index in 0..<(mutableData.length / MemoryLayout<UInt32>.size) {
            if (gs != 0) {
                let x = index % 96 / gs
                let y = index / 96 / gs
                
                if y & 1 != 0 {
                    uint32Pointer[index] = x & 1 != 0 ? dark : light
                } else {
                    uint32Pointer[index] = x & 1 != 0 ? light : dark
                }
            } else {
                uint32Pointer[index] = 0
            }
        }
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let provider = CGDataProvider(data: CFDataCreate(nil, mutableData.bytes, 36864))
        CGImageSourceCreateWithDataProvider(provider!, nil)
        
        let cgImage = CGImage(
            width: 96,
            height: 96,
            bitsPerComponent: Int(8),
            bitsPerPixel: Int(32),
            bytesPerRow: 384,
            space: colorSpace,
            bitmapInfo: bitmapInfo,
            provider: provider!,
            decode: nil,
            shouldInterpolate: true,
            intent: CGColorRenderingIntent.defaultIntent
        )
        
        
        if let resized = cgImage?.resize(CGSize(width: 96, height: 96)) {
            if let nsImage: NSImage = .create(fromCGImage: resized) {
                self.imageView.image = nsImage
            }
        }
        
    }
    
    @IBAction private func buttonTapped(_ sender: NSButton) {
        let index = sender.tag
        
        if (gridColorIndex == index) {
            return
        }
        
        let colorNames = ["White", "Silver", "Gray", "Red", "Orange", "Green", "Blue", "Purple"]
        
        if let lightColorValue = NSColor(named: colorNames[index - 1]) {
            lightColor.color = lightColorValue.usingColorSpace(.deviceRGB)!
        }
        if let darkColorValue = NSColor(named: "Dark\(colorNames[index - 1])") {
            darkColor.color = darkColorValue.usingColorSpace(.deviceRGB)!
        }
        gridColorIndex = index
        
        
        updateGridView()
        updateImageView()
    }
    
    private func updateGridView() {
        let selected = NSImage(systemSymbolName: "circle.inset.filled", accessibilityDescription: nil)
        let unselected = NSImage(systemSymbolName: "circle.fill", accessibilityDescription: nil)
        
        let index = gridColorIndex - 1
        
        for columnIndex in 0...7 {
            let cell = gridView.cell(atColumnIndex: columnIndex, rowIndex: 0)
            if let button = cell.contentView as? NSButton {
                button.image = columnIndex == index ? selected : unselected
            }
        }
        
        gridView.frame.origin.y = 143
    }
    
    
}
