//  MIT License
//
//  Created on 26/11/2020 for ConnectStats
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
import RZUtilsTouch

extension GCActivityDetailViewController {
    
    @objc func tableView(_ tableView: UITableView, fieldCellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        guard let cell = GCCellGrid(tableView) else { return UITableViewCell(frame: CGRect.zero)}
        
        if let organizedFields = self.organizedFields {
        
            if indexPath.row < organizedFields.groupedPrimaryFields.count {
                let fields = organizedFields.groupedPrimaryFields[ indexPath.row ]
                cell.setupActivityDetail(fields: fields, activity: self.activity, geometry: self.organizedFields.geometry)
                if indexPath.row % 2 == 0 {
                    if let color = GCViewConfig.defaultColor(gcSkinDefaultColor.backgroundEven) {
                        cell.setupBackgroundColors([color])
                    }
                }else{
                    if let color = GCViewConfig.defaultColor(gcSkinDefaultColor.backgroundOdd) {
                        cell.setupBackgroundColors([color])
                    }
                }
            }
        
        }
        return cell
    }
}
