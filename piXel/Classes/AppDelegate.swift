/*
Copyright © 2021 Insoft. All rights reserved.

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


import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    //private var image: Image?
    
    @IBOutlet weak var mainMenu: NSMenu!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        //image = Singleton.sharedInstance()?.image
        updateAllMenus()
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func application(sender: NSApplication, openFile theDroppedFilePath: String) {
        // PROCESS YOUR FILES HERE
        
        if let url = URL(string: theDroppedFilePath) {
            //Singleton.sharedInstance()?.image.modify(withContentsOf: url)
            NSApp.windows.first?.title = url.lastPathComponent
        }
        updateAllMenus()
    }
    
    
    
    // MARK: - Private Action Methods
    
    @IBAction private func zoomIn(_ sender: NSMenuItem) {
        if let image = Singleton.sharedInstance()?.image {
            if image.yScale < 8.0 {
                image.setScale(image.yScale + 1.0)
                image.xScale = image.yScale * image.aspectRatio
            }
        }
    }
    
    @IBAction private func zoomOut(_ sender: NSMenuItem) {
        if let image = Singleton.sharedInstance()?.image {
            if image.yScale > 1.0 {
                image.setScale(image.yScale - 1.0)
                image.xScale = image.yScale * image.aspectRatio
            }
        }
    }
    
    @IBAction private func aspectRatio(_ sender: NSMenuItem) {
        if let image = Singleton.sharedInstance()?.image {
            if sender.title == "1:1" {
                image.setAspectRatio(1.0)
            }
            if sender.title == "2:1" {
                image.setAspectRatio(2.0)
            }
            if sender.title == "1:2" {
                image.setAspectRatio(0.5)
            }
        }
        updateAllMenus();
    }
    
    @IBAction private func increaseWidth(_ sender: NSMenuItem) {
        if let image = Singleton.sharedInstance()?.image {
            image.setSize(TSize(width: image.size.width + 1, height: image.size.height))
            updateAllMenus()
        }
    }
    
    @IBAction private func decreaseWidth(_ sender: NSMenuItem) {
        if let image = Singleton.sharedInstance()?.image {
            image.setSize(TSize(width: image.size.width - 1, height: image.size.height))
            updateAllMenus()
        }
    }
    
    
    @IBAction private func increaseHeight(_ sender: NSMenuItem) {
        if let image = Singleton.sharedInstance()?.image {
            image.setSize(TSize(width: image.size.width, height: image.size.height + 1))
            updateAllMenus()
        }
    }
    
    
    @IBAction private func decreaseHeight(_ sender: NSMenuItem) {
        if let image = Singleton.sharedInstance()?.image {
            image.setSize(TSize(width: image.size.width, height: image.size.height - 1))
            updateAllMenus()
        }
    }
    
    
    @IBAction private func imageWidth(_ sender: NSMenuItem) {
        if let image = Singleton.sharedInstance()?.image {
            image.setSize(TSize(width: UInt(sender.tag), height: image.size.height))
            updateAllMenus()
        }
    }
    
    @IBAction private func imageHeight(_ sender: NSMenuItem) {
        if let image = Singleton.sharedInstance()?.image {
            image.setSize(TSize(width: image.size.width, height: UInt(sender.tag)))
            updateAllMenus()
        }
    }
    
    @IBAction private func pixelSize(_ sender: NSMenuItem) {
        Singleton.sharedInstance()?.image.setPixelSize(.init(width: CGFloat(sender.tag), height: CGFloat(sender.tag)))
        updateAllMenus()
    }
    
    @IBAction private func increasePixelSizeWidth(_ sender: NSMenuItem) {
        if let image = Singleton.sharedInstance()?.image {
            image.setPixelSize(.init(width: image.pixelSize.width + 0.125, height: image.pixelSize.height))
        }
        updateAllMenus()
    }
    
    
    @IBAction private func decreasePixelSizeWidth(_ sender: NSMenuItem) {
        if let image = Singleton.sharedInstance()?.image {
            image.setPixelSize(.init(width: image.pixelSize.width - 0.125, height: image.pixelSize.height))
        }
        updateAllMenus()
    }
    
    @IBAction private func increasePixelSizeHeight(_ sender: NSMenuItem) {
        if let image = Singleton.sharedInstance()?.image {
            image.setPixelSize(.init(width: image.pixelSize.width, height: image.pixelSize.height + 0.125))
        }
        updateAllMenus()
    }
    
    
    @IBAction private func decreasePixelSizeHeight(_ sender: NSMenuItem) {
        if let image = Singleton.sharedInstance()?.image {
            image.setPixelSize(.init(width: image.pixelSize.width, height: image.pixelSize.height - 0.125))
        }
        updateAllMenus()
    }
    
    @IBAction private func colorSpace(_ sender: NSMenuItem) {
        Singleton.sharedInstance()?.image.setBitsPerChannel(UInt(sender.tag))
        updateAllMenus()
    }
    
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
        
        updateAllMenus()
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
    
    // MARK: - Private Methods
    
    private func updateAllMenus() {
        if let image = Singleton.sharedInstance()?.image {
            // Size
            if let menu = mainMenu.item(at: 2)?.submenu?.item(withTitle: "Size")?.submenu {
                if let width = menu.item(withTitle: "Width")?.submenu {
                    for item in width.items {
                        item.state = item.tag == Int(image.size.width) ? .on : .off
                    }
                }
                
                if let height = menu.item(withTitle: "Height")?.submenu {
                    for item in height.items {
                        item.state = item.tag == Int(image.size.height) ? .on : .off
                    }
                }
            }
            
            if let menu = mainMenu.item(at: 2)?.submenu?.item(withTitle: "Pixel Size")?.submenu {
                for item in menu.items {
                    item.state = item.tag == Int(image.pixelSize.width) ? .on : .off
                }
            }
            
            // Pixel Aspect Ratio
            if let menu = mainMenu.item(at: 4)?.submenu?.item(withTitle: "Pixel Aspect Ratio")?.submenu {
                if let item = menu.item(withTitle: "1:1") {
                    item.state = image.aspectRatio == 1.0 ? .on : .off
                }
                if let item = menu.item(withTitle: "2:1") {
                    item.state = image.aspectRatio == 2.0 ? .on : .off
                }
                if let item = menu.item(withTitle: "1:2") {
                    item.state = image.aspectRatio == 0.5 ? .on : .off
                }
            }
            
        }
    }
    
    
    
}
