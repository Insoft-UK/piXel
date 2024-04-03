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
                image.xScale = image.yScale
            }
        }
    }
    
    @IBAction private func zoomOut(_ sender: NSMenuItem) {
        if let image = Singleton.sharedInstance()?.image {
            if image.yScale > 1.0 {
                image.setScale(image.yScale - 1.0)
                image.xScale = image.yScale
            }
        }
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
    }
    

    @IBAction private func saveAs(_ sender: NSMenuItem) {
        let savePanel = NSSavePanel()
        
        savePanel.title = "sXale"
        savePanel.canCreateDirectories = true
        savePanel.nameFieldStringValue = "\(NSApp.windows.first?.title ?? "name").png"
        
        let modalresponse = savePanel.runModal()
        if modalresponse == .OK {
            if let url = savePanel.url {
                Singleton.sharedInstance()?.image.save(at: url)
            }
        }
    }
    
    @IBAction private func EPX(_ sender: NSMenuItem) {
        Singleton.sharedInstance().image.epx()
        updateAllMenus()
    }
    
    // MARK: - Private Methods
    
    private func updateAllMenus() {
        if let image = Singleton.sharedInstance()?.image {
            if let menu = mainMenu.item(at: 2)?.submenu?.item(withTitle: "Scaling")?.submenu {
                if let item = menu.item(withTitle: "EPX") {
                    item.state = .on
                }
            }
        }
    }
    
}
