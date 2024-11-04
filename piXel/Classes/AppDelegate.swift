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

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var mainMenu: NSMenu!
    @IBOutlet weak var posterize: NSMenuItem!
    @IBOutlet weak var normalize: NSMenuItem!
    
    let image = Singleton.sharedInstance()!.image!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        updateAllMenus()
        
        // Observe the color change notification
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(colorDidChange(_:)),
            name: NSColorPanel.colorDidChangeNotification,
            object: NSColorPanel.shared
        )
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
    }
    
    func application(sender: NSApplication, openFile theDroppedFilePath: String) -> Bool {
        if let url = URL(string: theDroppedFilePath) {
            Singleton.sharedInstance()?.image.load(withContentsOf: url)
            NSApp.windows.first?.title = url.lastPathComponent
        }
        return true
    }
    
    // MARK: - Observer/s
    
    @objc func colorDidChange(_ notification: Notification) {
        let pickedColor = NSColorPanel.shared.color
        image.clut.setTransparencyColor(pickedColor)
        image.redraw()
        
#if DEBUG
        let red = pickedColor.redComponent
        let green = pickedColor.greenComponent
        let blue = pickedColor.blueComponent
        let alpha = pickedColor.alphaComponent
        print("sRGB Color Values - Red: \(red), Green: \(green), Blue: \(blue), Alpha: \(alpha)")
#endif
    }
    
    
    // MARK: - Action Methods
    
    @IBAction private func openDocument(_ sender: NSMenuItem) {
        let openPanel = NSOpenPanel()
        
        openPanel.title = "piXel"
        openPanel.canChooseFiles = true
        openPanel.canChooseDirectories = true
        openPanel.canCreateDirectories = false
        
        let modalresponse = openPanel.runModal()
        if modalresponse == .OK {
            if let url = openPanel.url {
                Singleton.sharedInstance()?.image.load(withContentsOf: url)
                NSApp.windows.first?.title = url.lastPathComponent
            }
        }
    }
    
    
    @IBAction private func saveAs(_ sender: NSMenuItem) {
        let savePanel = NSSavePanel()
        
        savePanel.title = "piXel"
        savePanel.canCreateDirectories = true
        savePanel.nameFieldStringValue = "\(NSApp.windows.first?.title ?? "name").png"
        
        let modalresponse = savePanel.runModal()
        if modalresponse == .OK {
            if let url = savePanel.url {
                Singleton.sharedInstance()?.image.save(at: url)
            }
        }
    }
    
    @IBAction private func importAct(_ sender: NSMenuItem) {
        let openPanel = NSOpenPanel()
        
        openPanel.title = "piXel"
        openPanel.canChooseFiles = true
        openPanel.canChooseDirectories = true
        openPanel.canCreateDirectories = false
        
        let modalresponse = openPanel.runModal()
        if modalresponse == .OK {
            if let url = openPanel.url {
                Singleton.sharedInstance()?.image.clut.loadAdobeColorTable(url.path)
                if let image = Singleton.sharedInstance()?.image {
                    NSColorPanel.shared.color = image.clut.transparencyColor
                }
            }
        }
    }
    
    @IBAction private func exportAs(_ sender: NSMenuItem) {
        let savePanel = NSSavePanel()
        
        savePanel.title = "piXel"
        savePanel.canCreateDirectories = true
        savePanel.nameFieldStringValue = "\(NSApp.windows.first?.title ?? "name").act"
        
        let modalresponse = savePanel.runModal()
        if modalresponse == .OK {
            if let url = savePanel.url {
                Singleton.sharedInstance()?.image.clut.saveAsAdobeColorTable(atPath: url.path)
            }
        }
    }
    
    
    @IBAction private func sampleSize(_ sender: NSMenuItem) {
        image.sampleSize = UInt(sender.tag);
        updateAllMenus()
    }
    
    @IBAction private func blockSize(_ sender: NSMenuItem) {
        image.blockSize = CGFloat(sender.tag);
        updateAllMenus()
    }
    
    @IBAction private func autoAdjustBlockSize(_ sender: NSMenuItem) {
        image.isAutoBlockSizeAdjustEnabled = !image.isAutoBlockSizeAdjustEnabled
        updateAllMenus()
    }
    
    @IBAction private func postorize(_ sender: NSMenuItem) {
        image.posterizeLevels = UInt(sender.tag)
        if image.posterizeLevels != 256 {
            image.isPaletteEnabled = false
            image.threshold = 0
        }
        updateAllMenus()
    }
    
    
    @IBAction private func normalize(_ sender: NSMenuItem) {
        if let image = Singleton.sharedInstance()?.image {
            image.threshold = image.isNormalizeEnabled ? 0 : 10
            if image.isNormalizeEnabled {
                image.isPaletteEnabled = false
            }
        }
        updateAllMenus()
    }
    
    @IBAction private func increaseThreshold(_ sender: NSMenuItem) {
        image.threshold += 1;
        if image.isNormalizeEnabled {
            image.isPaletteEnabled = false
        }
        updateAllMenus()
    }
    
    @IBAction private func decreaseThreshold(_ sender: NSMenuItem) {
        if image.threshold != 0 {
            image.threshold -= 1;
        }
        if image.isNormalizeEnabled {
            image.isPaletteEnabled = false
        }
        updateAllMenus()
    }
    
    @IBAction private func enablePalette(_ sender: NSMenuItem) {
        image.isPaletteEnabled = !image.isPaletteEnabled
        posterize.isEnabled = false
        normalize.isEnabled = false
        updateAllMenus()
    }
    @IBAction private func transparency(_ sender: NSMenuItem) {
        image.isTransparencyEnabled = !image.isTransparencyEnabled
        if image.isTransparencyEnabled {
            image.isPaletteEnabled = true
            posterize.isEnabled = false
            normalize.isEnabled = false
        }
        updateAllMenus()
    }
    
    @IBAction private func outline(_ sender: NSMenuItem) {
        image.isOutlineEnabled = !image.isOutlineEnabled
        if image.isOutlineEnabled {
            image.isPaletteEnabled = true
            posterize.isEnabled = false
            normalize.isEnabled = false
        }
        updateAllMenus()
    }
    
    @IBAction private func autoZoom(_ sender: NSMenuItem) {
        image.isAutoZoomEnabled = !image.isAutoZoomEnabled
        updateAllMenus()
    }
    
    @IBAction private func zoomIn(_ sender: NSMenuItem) {
        if image.yScale < 50.0 {
            image.setScale(image.yScale + 1.0)
        }
    }
    
    @IBAction private func zoomOut(_ sender: NSMenuItem) {
        if image.yScale > 1.0 {
            image.setScale(image.yScale - 1.0)
        }
    }
    
    
    //    override func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
    //        if menuItem.action == #selector(postorize) {
    //            return isFeatureEnabled
    //        }
    //        return true // Enable other menu items by default
    //    }
    
    func updateAllMenus() {
        if let submenu = mainMenu.item(withTitle: "Image")?.submenu?.item(withTitle: "Sample Size")?.submenu {
            for item in submenu.items {
                item.isEnabled = (item.tag > Int(image.blockSize)) ? true : false;
                
                if (item.tag == image.sampleSize) {
                    item.state = .on
                }
                else {
                    item.state = .off
                }
            }
        }
        
        if let submenu = mainMenu.item(withTitle: "Image")?.submenu?.item(withTitle: "Block Size")?.submenu {
            for item in submenu.items {
                if (item.tag == Int(image.blockSize)) {
                    item.state = .on
                }
                else {
                    item.state = .off
                }
            }
        }
        
        if let item = mainMenu.item(withTitle: "Image")?.submenu?.item(withTitle: "Auto Adjust Block Size") {
            item.state = image.isAutoBlockSizeAdjustEnabled ? .on : .off
        }
        
        if let submenu = mainMenu.item(withTitle: "Image")?.submenu?.item(withTitle: "Postorize")?.submenu {
            for item in submenu.items {
                if (item.tag == Int(image.posterizeLevels)) {
                    item.state = .on
                }
                else {
                    item.state = .off
                }
            }
        }
        
        if let item = mainMenu.item(withTitle: "Image")?.submenu?.item(withTitle: "Postorize") {
            item.state = image.isPosterizeEnabled ? .on : .off
        }
        
        if let item = mainMenu.item(withTitle: "Image")?.submenu?.item(withTitle: "Normalize") {
            item.state = image.isNormalizeEnabled ? .on : .off
        }
        
        if let item = mainMenu.item(withTitle: "Image")?.submenu?.item(withTitle: "Enable Palette") {
            item.state = image.isPaletteEnabled ? .on : .off
        }
        
        if let item = mainMenu.item(withTitle: "Image")?.submenu?.item(withTitle: "Transparency") {
            item.state = image.isTransparencyEnabled && image.isPaletteEnabled ? .on : .off
            item.isEnabled = image.isPaletteEnabled
        }
        
        if let item = mainMenu.item(withTitle: "Image")?.submenu?.item(withTitle: "Outline") {
            item.state = image.isOutlineEnabled && image.isPaletteEnabled ? .on : .off
        }
        
        if let item = mainMenu.item(withTitle: "View")?.submenu?.item(withTitle: "Auto Zoom") {
            item.state = image.isAutoZoomEnabled ? .on : .off
        }
    }
}
