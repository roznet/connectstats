//  MIT License
//
//  Created on 10/04/2021 for ConnectStats
//
//  Copyright (c) 2021 Brice Rosenzweig
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



import UIKit

class GCTooltipView: UIView {
    @IBOutlet var title: UILabel!
    @IBOutlet var descriptionText: UITextView!
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    static func newTooltip() -> GCTooltipView? {
        guard let views = Bundle(for: self).loadNibNamed("GCTooltipView", owner: self, options: nil),
              let tooltip = views[0] as? GCTooltipView
        else {
            return nil
        }
        return tooltip
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

extension UIViewController {
    
    @objc func addTooltipInfo(view : UIView) {
        if let tooltip = GCTooltipView.newTooltip() {
            self.view.addSubview(tooltip)
            
            NSLayoutConstraint.activate( [
                tooltip.topAnchor.constraint(equalTo: view.bottomAnchor),
                tooltip.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0.0),
                tooltip.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0.0),
                tooltip.leadingAnchor.constraint(greaterThanOrEqualTo: self.view.leadingAnchor,constant: 30.0),
                tooltip.trailingAnchor.constraint(greaterThanOrEqualTo: self.view.trailingAnchor, constant: 30.0)
            ])
        }
    }
}
