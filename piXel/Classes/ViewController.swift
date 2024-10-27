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
import SpriteKit
import GameplayKit


@objc class ViewController: NSViewController {

    @IBOutlet var skView: SKView!
    @IBOutlet var widthText: NSTextField!
    @IBOutlet var heightText: NSTextField!
    @IBOutlet var zoomText: NSTextField!
    @IBOutlet var infoText: NSTextField!
    @IBOutlet var imageView: NSImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let  mainMenu =  NSApplication.shared.mainMenu

            if let editMenu = mainMenu?.item(at: 1)?.submenu{
                for item in editMenu.items{
                    item.isEnabled = true
                }
            }
        
        let scene:SKScene = MainScene.init()
        scene.scaleMode = .aspectFill
        skView.presentScene(scene)
        
        skView.preferredFramesPerSecond = 60
    }
    
    @objc func redrawPalette(_ bytes: UnsafePointer<UInt8>, colorCount colors: Int) {
        if let cgImage: CGImage = .create(fromPixelData: bytes, ofSize: CGSize(width: colors, height: 1)) {
            if let resized = cgImage.resize(CGSize(width: 512, height: 12)) {
                if let nsImage: NSImage = .create(fromCGImage: resized) {
                    self.imageView.image = nsImage
                }
            }
        }
    }
    
    
}

extension NSImage {
    @discardableResult static func create(fromCGImage cgImage: CGImage) -> NSImage? {
        return NSImage(cgImage: cgImage, size: .zero)
    }
}
