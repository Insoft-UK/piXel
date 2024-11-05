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

@objc class ImageSettingsViewController: NSViewController {
    @IBOutlet weak var leftCropMargin: NSTextField!
    @IBOutlet weak var rightCropMargin: NSTextField!
    @IBOutlet weak var topCropMargin: NSTextField!
    @IBOutlet weak var bottomCropMargin: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        leftCropMargin.integerValue = image.leftCropMargin
        rightCropMargin.integerValue = image.rightCropMargin
        topCropMargin.integerValue = image.topCropMargin
        bottomCropMargin.integerValue = image.bottomCropMargin
    }
    
    let image = Singleton.sharedInstance()!.image!
    
    @IBAction private func updateLeftCropMargin(to sender: NSTextField) {
        image.leftCropMargin = sender.integerValue
        leftCropMargin.integerValue = image.leftCropMargin
    }
    
    @IBAction private func updateRightCropMargin(to sender: NSTextField) {
        image.rightCropMargin = sender.integerValue
        rightCropMargin.integerValue = image.rightCropMargin
    }
    
    @IBAction private func updateTopCropMargin(to sender: NSTextField) {
        image.topCropMargin = sender.integerValue
        topCropMargin.integerValue = image.topCropMargin
    }
    
    @IBAction private func updateBottomCropMargin(to sender: NSTextField) {
        image.bottomCropMargin = sender.integerValue
        bottomCropMargin.integerValue = image.bottomCropMargin
    }

}
