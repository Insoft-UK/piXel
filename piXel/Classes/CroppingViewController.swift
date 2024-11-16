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

@objc class CroppingViewController: NSViewController {
    @IBOutlet weak var leftCropMargin: NSTextField!
    @IBOutlet weak var rightCropMargin: NSTextField!
    @IBOutlet weak var topCropMargin: NSTextField!
    @IBOutlet weak var bottomCropMargin: NSTextField!
    
    @IBOutlet weak var leftCropMarginStepper: NSStepper!
    @IBOutlet weak var rightCropMarginStepper: NSStepper!
    @IBOutlet weak var topCropMarginStepper: NSStepper!
    @IBOutlet weak var bottomCropMarginStepper: NSStepper!
    
    
    let image = Singleton.sharedInstance()!.mainScene.image!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        image.showGuide()
        updateUI()
     }
    
    override func viewWillDisappear() {
        image.hideGuide()
    }
    
    @IBAction func closeWindow(_ sender: NSButton) {
        self.view.window?.close()
    }
    

    @IBAction private func updateLeftCropMargin(to sender: NSTextField) {
        image.leftCropMargin = sender.integerValue
        updateUI()
    }
    
    @IBAction private func updateRightCropMargin(to sender: NSTextField) {
        image.rightCropMargin = sender.integerValue
        updateUI()
    }
    
    @IBAction private func updateTopCropMargin(to sender: NSTextField) {
        image.topCropMargin = sender.integerValue
        updateUI()
    }
    
    @IBAction private func updateBottomCropMargin(to sender: NSTextField) {
        image.bottomCropMargin = sender.integerValue
        updateUI()
    }
    
    @IBAction private func stepperLeftCropMargin(to sender: NSStepper) {
        image.leftCropMargin = sender.integerValue
        updateUI()
    }
    
    @IBAction private func stepperRightCropMargin(to sender: NSStepper) {
        image.rightCropMargin = sender.integerValue
        updateUI()
    }
    
    @IBAction private func stepperTopCropMargin(to sender: NSStepper) {
        image.topCropMargin = sender.integerValue
        updateUI()
    }
    
    @IBAction private func stepperBottomCropMargin(to sender: NSStepper) {
        image.bottomCropMargin = sender.integerValue
        updateUI()
    }
    
    private func updateUI() {
        leftCropMargin.integerValue = image.leftCropMargin
        rightCropMargin.integerValue = image.rightCropMargin
        topCropMargin.integerValue = image.topCropMargin
        bottomCropMargin.integerValue = image.bottomCropMargin
        
        leftCropMarginStepper.integerValue = image.leftCropMargin
        rightCropMarginStepper.integerValue = image.rightCropMargin
        topCropMarginStepper.integerValue = image.topCropMargin
        bottomCropMarginStepper.integerValue = image.bottomCropMargin
    }

}
