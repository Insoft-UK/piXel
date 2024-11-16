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

class ColorTableViewController: NSViewController {
    @IBOutlet weak var colorLUTPopUpButton: NSPopUpButton!
    
    @IBOutlet weak var CLUTImageView: NSImageView!
    @IBOutlet weak var transparency: NSImageView!
    
    @IBOutlet weak var newColor: NSColorWell!
    @IBOutlet weak var currentColor: NSColorWell!
    
    @IBOutlet weak var index: NSTextField!
    @IBOutlet weak var defined: NSTextField!
    
    @IBOutlet weak var R: NSTextField!
    @IBOutlet weak var G: NSTextField!
    @IBOutlet weak var B: NSTextField!
    
    @IBOutlet weak var hex: NSTextField!
    
    @IBOutlet weak var indexStepper: NSStepper!
    @IBOutlet weak var definedStepper: NSStepper!
    
    @IBOutlet weak var rStepper: NSStepper!
    @IBOutlet weak var gStepper: NSStepper!
    @IBOutlet weak var bStepper: NSStepper!
    
    @IBOutlet weak var transparent: NSButton!
    
    let image = Singleton.sharedInstance()!.mainScene.image!
    var clut: CLUT?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let image = Singleton.sharedInstance()?.mainScene.image {
            clut = image.clut
        }
        
        selectCLUT(atIndex: 0)
        refreshWindow()
    }
    
    
    
    
    
    @IBAction func closeWindow(_ sender: NSButton) {
        self.view.window?.close()
    }
    
    @IBAction func applyColor(_ sender: NSButton) {
        guard let clut = self.clut else {
            return
        }
        clut.colors[index.integerValue] = Colors.RgbaFrom(color: newColor.color)
        
       
        for item in colorLUTPopUpButton.itemArray {
            if (item.title == "Custom") {
                item.state = .on
            }
            else {
                item.state = .off
            }
        }
        colorLUTPopUpButton.title = "Custom"

        selectCLUT(atIndex: index.integerValue)
    }
    
    @IBAction func revertColor(_ sender: NSButton) {
        selectCLUT(atIndex: index.integerValue)
    }
    
    @IBAction func field(_ sender: NSTextField) {
        guard let clut = self.clut else {
            return
        }
        
        switch sender.tag {
        case 1:
            rStepper.integerValue = sender.integerValue
        case 2:
            gStepper.integerValue = sender.integerValue
        case 3:
            bStepper.integerValue = sender.integerValue
        case 4:
            let hex = sender.integerValue
            R.integerValue = (hex >> 16) & 255
            G.integerValue = (hex >> 8) & 255
            B.integerValue = hex & 255
            rStepper.integerValue = R.integerValue
            gStepper.integerValue = G.integerValue
            bStepper.integerValue = B.integerValue
        case 5:
            selectCLUT(atIndex: sender.integerValue)
        case 6:
            clut.setDefined(UInt16(sender.integerValue))
            selectCLUT(atIndex: index.integerValue)
        default:
            break
        }
        hex.integerValue = R.integerValue << 16 | G.integerValue << 8 | B.integerValue
        newColor.color = .init(red: CGFloat(R.floatValue / 255.0), green: CGFloat(G.floatValue / 255.0), blue: CGFloat(B.floatValue / 255.0), alpha: 1.0)
    }
    
    @IBAction func stepper(_ sender: NSStepper) {
        guard let clut = self.clut else {
            return
        }
        
        switch sender.tag {
        case 1:
            R.integerValue = sender.integerValue
        case 2:
            G.integerValue = sender.integerValue
        case 3:
            B.integerValue = sender.integerValue
        case 5:
            selectCLUT(atIndex: sender.integerValue)
        case 6:
            clut.setDefined(UInt16(sender.integerValue))
            selectCLUT(atIndex: index.integerValue)
        default:
            break
        }
        
        hex.integerValue = R.integerValue << 16 | G.integerValue << 8 | B.integerValue
        newColor.color = .init(red: CGFloat(R.floatValue / 255.0), green: CGFloat(G.floatValue / 255.0), blue: CGFloat(B.floatValue / 255.0), alpha: 1.0)
    }
    
    
    @IBAction func transparentCheckBox(_ sender: NSButton) {
        guard let clut = self.clut else {
            return
        }
        
        if sender.state == .on {
            clut.setTransparency(Int16(index.integerValue))
        } else {
            clut.setTransparency(-1)
        }
        
        selectCLUT(atIndex: index.integerValue)
    }
    
    @IBAction private func importAct(_ sender: NSButton) {
        guard let clut = self.clut else {
            return
        }
        
        let openPanel = NSOpenPanel()
        
        openPanel.title = "piXel"
        openPanel.canChooseFiles = true
        openPanel.canChooseDirectories = true
        openPanel.canCreateDirectories = false
        
        let modalresponse = openPanel.runModal()
        if modalresponse == .OK {
            if let url = openPanel.url {
                clut.loadAdobeColorTable(url.path)
                selectCLUT(atIndex: 0)
                refreshWindow()
            }
        }
    }
    
    @IBAction private func exportAs(_ sender: NSButton) {
        guard let clut = self.clut else {
            return
        }
        
        let savePanel = NSSavePanel()
        
        savePanel.title = "piXel"
        savePanel.canCreateDirectories = true
        savePanel.nameFieldStringValue = "\(NSApp.windows.first?.title ?? "name").act"
        
        let modalresponse = savePanel.runModal()
        if modalresponse == .OK {
            if let url = savePanel.url {
                clut.saveAsAdobeColorTable(atPath: url.path)
            }
        }
    }
    
    @IBAction private func loadAdobeColorTable(_ sender: NSMenuItem) {
        guard let clut = self.clut else {
            return
        }
        
        if let filePath = Bundle.main.path(forResource: sender.title, ofType: "act") {
            clut.loadAdobeColorTable(filePath)
            selectCLUT(atIndex: 0)
            refreshWindow()
            return
        }
    }
    
    private func selectCLUT(atIndex index: Int) {
        guard let clut = self.clut else {
            return
        }
        
        self.index.integerValue = min(max(index, 0), Int(clut.defined) - 1)
        indexStepper.integerValue = self.index.integerValue
        indexStepper.maxValue = Double(clut.defined) - 1
        
        defined.integerValue = Int(clut.defined)
        definedStepper.integerValue = defined.integerValue
        
        newColor.color = clut.color(at: self.index.integerValue)
        currentColor.color = newColor.color
        
        R.integerValue = Int(currentColor.color.redComponent * 255)
        G.integerValue = Int(currentColor.color.greenComponent * 255)
        B.integerValue = Int(currentColor.color.blueComponent * 255)
        
        rStepper.integerValue = R.integerValue
        gStepper.integerValue = G.integerValue
        bStepper.integerValue = B.integerValue
        
        hex.integerValue = Int(R.integerValue << 16 | G.integerValue << 8 | B.integerValue)
        transparent.state = self.index.integerValue != clut.transparency ? .off : .on
        
        refreshCLUTImageView()
        refreshTransparent()
        
        
    }
    
    private func refreshCLUTImageView() {
        guard let clut = self.clut else {
            return
        }
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let provider = CGDataProvider(data: CFDataCreate(nil, clut.colors, 1024))
        CGImageSourceCreateWithDataProvider(provider!, nil)
        
        if let cgImage = CGImage(
            width: 16,
            height: 16,
            bitsPerComponent: 8,
            bitsPerPixel: 32,
            bytesPerRow: 16 * 4,
            space: colorSpace,
            bitmapInfo: bitmapInfo,
            provider: provider!,
            decode: nil,
            shouldInterpolate: true,
            intent: CGColorRenderingIntent.defaultIntent
        ) {
            
            
            if let resized = cgImage.resize(CGSize(width: 256, height: 256)) {
                if let nsImage: NSImage = .create(fromCGImage: resized) {
                    CLUTImageView.image = nsImage
                }
            }
        }
    }

    
    private func refreshTransparent() {
        guard let clut = self.clut else {
            return
        }
        
        
        if clut.transparency != -1 {
            let x = clut.transparency % 16
            let y = clut.transparency / 16
            let dx = CLUTImageView.frame.size.width / 16
            let dy = CLUTImageView.frame.size.height / 16
            transparency.frame.origin = CLUTImageView.frame.origin
            transparency.frame.origin.x += CGFloat(x) * dx
            transparency.frame.origin.y -= CGFloat(y) * dy
            transparency.frame.origin.y += CLUTImageView.frame.size.height - dy
            transparency.isHidden = false
        } else {
            transparency.isHidden = true
        }
    }
    
    
    private func refreshWindow() {
        guard let clut = self.clut else {
            return
        }
        
        if let window = NSApplication.shared.windows.first {
            if let rootViewController = window.contentViewController as? ViewController {
                let uint32Pointer: UnsafeMutablePointer<UInt32> = clut.colors
                let uint8Pointer = UnsafeRawPointer(uint32Pointer).bindMemory(to: UInt8.self, capacity: 4)
                
                rootViewController.redrawPalette(uint8Pointer, colorCount: Int(clut.defined))
            }
        }
        
        image.blockSize = image.blockSize;
    }
}
