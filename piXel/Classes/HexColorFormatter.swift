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
import Foundation

class HexColorFormatter: Formatter {

    // Regular expression pattern for 6-digit hex colors (no "#")
    private let hexPattern = "^[0-9A-Fa-f]{1,6}$"
    
    override func string(for obj: Any?) -> String? {
        // If input is an integer, convert it to a hex color string
        if let intValue = obj as? Int {
            return hexString(from: intValue)
        }
        // If input is a string, validate and return it in lowercase
        if let colorString = obj as? String, isValidHexColor(colorString) {
            return colorString.uppercased()
        }
        return nil
    }
    
    override func getObjectValue(_ obj: AutoreleasingUnsafeMutablePointer<AnyObject?>?,
                                 for string: String,
                                 errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
        // Validate the input string to ensure it is a valid hex color
        guard isValidHexColor(string) else {
            error?.pointee = "Invalid hex color format" as NSString
            return false
        }
        
        // Convert the hex color string to an integer and assign it to the object
        if let intValue = intValue(from: string) {
            obj?.pointee = intValue as NSNumber
            return true
        } else {
            error?.pointee = "Invalid hex color format" as NSString
            return false
        }
    }
    
    // MARK: - Helper Methods
    
    private func isValidHexColor(_ string: String) -> Bool {
        // Check if the string matches the 6-digit hex color pattern
        let regex = try! NSRegularExpression(pattern: hexPattern)
        let range = NSRange(location: 0, length: string.utf16.count)
        return regex.firstMatch(in: string, options: [], range: range) != nil
    }
    
    private func intValue(from hexString: String) -> Int? {
        // Convert hex string to an integer
        return Int(hexString, radix: 16)
    }
    
    private func hexString(from intValue: Int) -> String {
        // Format integer as a 6-character hex string in lowercase, no "#" prefix
        return String(format: "%06X", intValue & 0xFFFFFF) // Mask to limit to 6 hex digits
    }
}
