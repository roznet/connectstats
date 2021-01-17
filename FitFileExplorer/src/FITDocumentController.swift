//  MIT License
//
//  Created on 25/12/2020 for FitFileExplorer
//
//  Copyright (c) 2020 Brice Rosenzweig
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//



import Foundation
import FitFileParser

class FITDocumentController : NSDocumentController{
    override func runModalOpenPanel(_ openPanel: NSOpenPanel, forTypes types: [String]?) -> Int {
        let sb = NSStoryboard(name: "Main", bundle: nil)
        var rv : Int = 0
        if let wc = sb.instantiateController(withIdentifier:"FIT Accessory View Controller") as? FITAccessoryViewController{
            openPanel.isAccessoryViewDisclosed = true
            openPanel.accessoryView = wc.view
            rv = super.runModalOpenPanel(openPanel, forTypes: types)
            if( rv == 1){//not cancel
                
                var parsingType : FitFile.ParsingType = .fast
                if wc.parsingType.indexOfSelectedItem == 1 {
                    parsingType = .generic
                }
                for url in openPanel.urls {
                    FITAppGlobal.shared.parsingTypes[ url ] = parsingType
                }
            }
        }else{
            openPanel.accessoryView = nil
            rv = super.runModalOpenPanel(openPanel, forTypes: types)
        }
        return rv
    }
}
