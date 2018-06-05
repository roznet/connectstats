//
//  GCHealthZonesViewController.swift
//  GarminConnect
//
//  Created by Brice Rosenzweig on 09/07/2016.
//  Copyright © 2016 Brice Rosenzweig. All rights reserved.
//

import UIKit
import RZUtils
import RZUtilsSwift

class GCHealthZonesViewController: UIViewController, RZMultiSliderControlDelegate {

    let multiSlider:RZMultiSliderControl = RZMultiSliderControl()
    let healthZoneCalc:GCHealthZoneCalculator
    
    @objc init( withZone zoneCalc:GCHealthZoneCalculator ){
        self.healthZoneCalc = zoneCalc
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.white
        let zones:Array<GCHealthZone> = self.healthZoneCalc.zones;
        let floors:Array<Double> = zones.map( { x in x.floor});
        let ceilings:Array<Double> = zones.map( { x in x.ceiling});
        
        self.multiSlider.values = zones.map( { x in x.floor} );
        
        self.multiSlider.maximumValue = CGFloat(ceilings.max()!);
        self.multiSlider.minimumValue = CGFloat(floors.min()!);
        self.multiSlider.multiDelegate = self
        self.view.addSubview(multiSlider)
        // Do any additional setup after loading the view.
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.save, target: self, action: #selector(GCHealthZonesViewController.saveButton));

    }

    @objc func saveButton(){
        if let key = self.healthZoneCalc.key {
            let dict = [ key : self.healthZoneCalc ]
            GCAppGlobal.health().registerZoneCalculators(dict);
            GCAppGlobal.saveSettings(); // force refresh/notify setting change
            _ = self.navigationController?.popViewController(animated: true);
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.view.backgroundColor = UIColor.lightGray
        multiSlider.backgroundColor = UIColor.white
        multiSlider.frame = self.view.frame
        multiSlider.frame.origin.y += 70.0
        multiSlider.frame.size.height -= 140.0
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }

    func updateZonesWithValues(values newValues:Array<Double>){
        let n = newValues.count
        
        for idx in 0..<n{
            if idx < self.healthZoneCalc.zones.count {
                let zone = self.healthZoneCalc.zones[idx];
                let floor:Double = newValues[idx];
                let ceiling:Double = idx+1<n ? newValues[idx+1] :Double(self.multiSlider.maximumValue)
                zone.floor = floor
                zone.ceiling = ceiling
            }
        }
    }
    

    func multiSlider(_ multi: RZMultiSliderControl!, valuesChanged newValues: [NSNumber]!) {
        if let newValues = newValues as? Array<Double> {
            self.updateZonesWithValues(values: newValues)
        }
    }
    func multiSlider(_ multi: RZMultiSliderControl!, describeRange idx: UInt) -> NSAttributedString! {
        let zones:Array<GCHealthZone> = self.healthZoneCalc.zones;
        let useidx:Int = min(zones.count-1, Int(idx))
        let zone:GCHealthZone = zones[useidx];
        return NSAttributedString(string: zone.rangeLabel(), attributes:  NSAttributedString.convertObjcAttributesDict( attributes:GCViewConfig.attribute14()));
    }

    func multiSlider(_ multi: RZMultiSliderControl!, formatValue val: CGFloat) -> NSAttributedString! {
        var label = ""
        if let unit = self.healthZoneCalc.unit(){
            label = unit.formatDoubleNoUnits(Double(val));
        }else{
            label = "\(val)";
        }
        
        
        return NSAttributedString(string: label, attributes: NSAttributedString.convertObjcAttributesDict(attributes: GCViewConfig.attribute14White()));
        
    }
}
