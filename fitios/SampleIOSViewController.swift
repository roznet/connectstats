//
//  ViewController.swift
//  fitios
//
//  Created by Brice Rosenzweig on 11/02/2019.
//

import UIKit
import RZFitFile
import RZFitFileTypes

class SampleIOSViewController: UIViewController {

    @IBOutlet weak var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if let rp = Bundle.main.resourceURL {
            let fp = rp.appendingPathComponent("running.fit")
            let file = RZFitFile(file: fp)
            if let msg = file?.messages(forMessageType: FIT_MESG_NUM_RECORD) {
                self.label.text = "Loaded \(msg.count) records"
            }else{
                self.label.text = "Failed to load"
            }
            
        }
        

        
    }


}

