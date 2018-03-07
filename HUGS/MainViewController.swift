//
//  MainViewController.swift
//  HUGS
//
//  Created by Becky Abramowitz on 1/4/18.
//  Copyright © 2018 HUGS. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UINavigationItem!
    @IBOutlet weak var overrideStatusLabel: UILabel!
    @IBOutlet weak var currentHRLabel: UILabel!
    @IBOutlet weak var currentNoiseLabel: UILabel!
    @IBOutlet weak var currentTempLabel: UILabel!
    @IBOutlet weak var currentAccelLabel: UILabel!
    
    @IBOutlet weak var rangeHRLabel: UILabel!
    @IBOutlet weak var rangeNoiseLabel: UILabel!
    @IBOutlet weak var rangeTempLabel: UILabel!
    @IBOutlet weak var rangeAccelLabel: UILabel!
    
    @IBAction func overrideButtonClicked(_ sender: Any) {
        var popUpWord: String = "inflate";
        if (getActivationStatus()) { popUpWord = "deflate" }
        let popUpMessage : String = "This will override current inflation and " + popUpWord + " the vest."
        let overrideAlert = UIAlertController(title:"Override Confirmation", message:popUpMessage, preferredStyle: .alert)
        overrideAlert.addAction(UIAlertAction(title:"Confirm", style:.default, handler: {_ in NSLog("Override Confirmed");
            setActivationStatus(!getActivationStatus());
            self.setOverideStatusLabel()}))
        overrideAlert.addAction(UIAlertAction(title:"Cancel", style:.default, handler: {_ in NSLog("Override Cancelled")}))
        self.present(overrideAlert, animated:true, completion:nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Intialize Title
        titleLabel.title = userVars.userName + "'s HUGS"
        
        setCurrentLabels()
        setRangeLabels()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setOverideStatusLabel() {
        if getActivationStatus() {
            overrideStatusLabel.text = "Inflated"
        } else {
            overrideStatusLabel.text = "Deflated"
        }
    }
    
    func setCurrentLabels() {
        currentHRLabel.text = String(getHR())
        currentNoiseLabel.text = String(getNoise())
        currentTempLabel.text = String(getTemp())
        currentAccelLabel.text = String(getAccel())
        var textColor : UIColor;
        if isConnected { textColor = UIColor.black } else { textColor =  UIColor.gray }
        currentHRLabel.textColor = textColor
        currentNoiseLabel.textColor = textColor
        currentTempLabel.textColor = textColor
        currentAccelLabel.textColor = textColor
    }
    
    func setRangeLabels() {
        setRangeLabel(rangeHRLabel, thresholds: heartRateThreshold)
        setRangeLabel(rangeNoiseLabel, thresholds: noiseThreshold)
        setRangeLabel(rangeTempLabel, thresholds: tempThreshold)
        setRangeLabel(rangeAccelLabel, thresholds: accelThreshold)
    }
    
    func setRangeLabel(_ label : UILabel, thresholds: Threshold) {
        if (thresholds.lowerBound != nil && thresholds.upperBound != nil) {
            label.text = "|  <" + String(thresholds.lowerBound) + ", > " + String(thresholds.upperBound)
        }  else if (thresholds.lowerBound != nil ) {
            label.text = "|  <" + String(thresholds.lowerBound)
        } else if (thresholds.upperBound != nil ) {
            label.text = "|  >" + String(thresholds.upperBound)
        } else { label.text = "" }
        if (thresholds.isOn) {
            label.textColor = UIColor.black
        } else {
            label.textColor = UIColor.lightGray
        }
    }
}
