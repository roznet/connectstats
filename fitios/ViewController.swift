//
//  ViewController.swift
//  fitios
//
//  Created by Brice Rosenzweig on 11/02/2019.
//

import UIKit
import RZFitFile
import RZFitFilePrivate

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if let rp = Bundle.main.resourceURL {
            let fp = rp.appendingPathComponent("running.fit")
            let file = RZFitFile(file: fp)
            if let msg = file?.messages(forMessageType: FIT_MESG_NUM_RECORD) {
                print("\(msg.count)")
            }
            
        }
        

        
    }


}

