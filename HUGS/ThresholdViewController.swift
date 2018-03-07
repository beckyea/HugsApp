//
//  ThresholdViewController.swift
//  HUGS
//
//  Created by Becky Abramowitz on 3/4/18.
//  Copyright © 2018 HUGS. All rights reserved.
//

import UIKit

class ThresholdViewController : UIViewController {
        
    var tempHRThreshold : Threshold!;
    var tempNoiseThreshold : Threshold!;
    var tempAccelThreshold : Threshold!;
    var tempTempThreshold : Threshold!;
    var tempLightThreshold : Threshold!;
    
    
    @IBOutlet weak var hrSwitch: UISwitch!
    @IBOutlet weak var hrUpperStepper: UIStepper!
    @IBOutlet weak var hrLowerStepper: UIStepper!
    @IBOutlet weak var hrUpperLabel: UILabel!
    @IBOutlet weak var hrLowerLabel: UILabel!
    @IBOutlet weak var hrCurrentLabel: UILabel!
    
    @IBOutlet weak var noiseSwitch: UISwitch!
    @IBOutlet weak var noiseUpperStepper: UIStepper!
    @IBOutlet weak var noiseUpperLabel: UILabel!
    @IBOutlet weak var noiseCurrentLabel: UILabel!
    
    @IBOutlet weak var accelSwitch: UISwitch!
    @IBOutlet weak var accelUpperStepper: UIStepper!
    @IBOutlet weak var accelUpperLabel: UILabel!
    @IBOutlet weak var accelCurrentLabel: UILabel!
    
    @IBOutlet weak var tempSwitch: UISwitch!
    @IBOutlet weak var tempUnitControl: UISegmentedControl!
    @IBOutlet weak var tempUpperStepper: UIStepper!
    @IBOutlet weak var tempLowerStepper: UIStepper!
    @IBOutlet weak var tempUpperLabel: UILabel!
    @IBOutlet weak var tempLowerLabel: UILabel!
    @IBOutlet weak var tempCurrentLabel: UILabel!
    
    @IBOutlet weak var lightSwitch: UISwitch!
    
    @IBAction func hrSwitchToggled(_ sender: Any) {
        tempHRThreshold.isOn = hrSwitch.isOn;
        hrUpperStepper.isEnabled = hrSwitch.isOn;
        hrLowerStepper.isEnabled = hrSwitch.isOn;
    }
    
    @IBAction func noiseSwitchToggled(_ sender: Any) {
        tempNoiseThreshold.isOn = noiseSwitch.isOn;
        noiseUpperStepper.isEnabled = noiseSwitch.isOn;
    }
    
    @IBAction func accelSwitchToggled(_ sender: Any) {
        tempAccelThreshold.isOn = accelSwitch.isOn;
        accelUpperStepper.isEnabled = accelSwitch.isOn;
    }
    
    @IBAction func tempSwitchToggled(_ sender: Any) {
        tempTempThreshold.isOn = tempSwitch.isOn;
        tempUpperStepper.isEnabled = tempSwitch.isOn;
        tempLowerStepper.isEnabled = tempSwitch.isOn;
    }
    
    @IBAction func lightSwitchToggled(_ sender: Any) {
        tempLightThreshold.isOn = lightSwitch.isOn;
    }
    
    @IBAction func hrUpperChanged(_ sender: Any) {
        tempHRThreshold.upperBound = hrUpperStepper.value
        setUpperBoundLabel(hrUpperLabel, threshold: tempHRThreshold)
        hrLowerStepper.maximumValue = tempHRThreshold.upperBound - 1
    }
    
    @IBAction func hrLowerChanged(_ sender: Any) {
        tempHRThreshold.lowerBound = hrLowerStepper.value
        setLowerBoundLabel(hrLowerLabel, threshold: tempHRThreshold)
        hrUpperStepper.minimumValue = tempHRThreshold.lowerBound + 1
    }
    
    @IBAction func noiseUpperChanged(_ sender: Any) {
        tempNoiseThreshold.upperBound = noiseUpperStepper.value
        setUpperBoundLabel(noiseUpperLabel, threshold: tempNoiseThreshold)
    }
    
    @IBAction func accelUpperChanged(_ sender: Any) {
        tempAccelThreshold.upperBound = accelUpperStepper.value
        setUpperBoundLabel(accelUpperLabel, threshold: tempAccelThreshold)
    }
    
    @IBAction func tempUpperChanged(_ sender: Any) {
        tempTempThreshold.upperBound = tempUpperStepper.value
        setUpperBoundLabel(tempUpperLabel, threshold: tempTempThreshold)
        tempLowerStepper.maximumValue = tempTempThreshold.upperBound - 1
    }
    
    @IBAction func tempLowerChanged(_ sender: Any) {
        tempTempThreshold.lowerBound = tempLowerStepper.value
        setLowerBoundLabel(tempLowerLabel, threshold: tempTempThreshold)
        tempUpperStepper.minimumValue = tempTempThreshold.lowerBound + 1
    }
    
    func setUpperBoundLabel(_ label:UILabel, threshold:Threshold) {
        label.text = "HUGS will activate above " + String(threshold.upperBound)
    }
    
    func setLowerBoundLabel(_ label:UILabel, threshold:Threshold) {
        label.text = "HUGS will activate below " + String(threshold.lowerBound)
    }
    
    func setCurrentLabel(_ label:UILabel, currentReading:Double) {
        label.text = "Current Reading: " + String(currentReading)
    }
    @IBAction func saveButtonClicked(_ sender: Any) {
        heartRateThreshold = tempHRThreshold;
        noiseThreshold = tempNoiseThreshold;
        accelThreshold = tempAccelThreshold;
        tempThreshold = tempTempThreshold;
        lightThreshold = tempLightThreshold;
        
        let mainViewController = self.storyboard?.instantiateViewController(withIdentifier: "mainViewController") as! MainViewController
        self.navigationController?.pushViewController(mainViewController, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tempHRThreshold = heartRateThreshold;
        tempNoiseThreshold = noiseThreshold;
        tempAccelThreshold = accelThreshold;
        tempTempThreshold = tempThreshold;
        tempLightThreshold = lightThreshold;
        
        initializeFromExistingThresholds();
        
        setFromCurrent();
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initializeFromExistingThresholds() {
        hrSwitch.isOn = tempHRThreshold.isOn;
        noiseSwitch.isOn = tempNoiseThreshold.isOn;
        accelSwitch.isOn = tempAccelThreshold.isOn;
        tempSwitch.isOn = tempTempThreshold.isOn;
        lightSwitch.isOn = tempLightThreshold.isOn;
        
        setUpperBoundLabel(hrUpperLabel, threshold: tempHRThreshold)
        setLowerBoundLabel(hrLowerLabel, threshold: tempHRThreshold)
        setUpperBoundLabel(noiseUpperLabel, threshold: tempNoiseThreshold)
        setUpperBoundLabel(accelUpperLabel, threshold: tempAccelThreshold)
        setUpperBoundLabel(tempUpperLabel, threshold: tempTempThreshold)
        setLowerBoundLabel(tempLowerLabel, threshold: tempTempThreshold)
        
        hrUpperStepper.value = tempHRThreshold.upperBound
        hrLowerStepper.value = tempHRThreshold.lowerBound
        noiseUpperStepper.value = tempNoiseThreshold.upperBound
        accelUpperStepper.value = tempAccelThreshold.upperBound
        tempUpperStepper.value = tempTempThreshold.upperBound
        tempLowerStepper.value = tempTempThreshold.lowerBound
        
        hrUpperStepper.isEnabled = hrSwitch.isOn;
        hrLowerStepper.isEnabled = hrSwitch.isOn;
        noiseUpperStepper.isEnabled = noiseSwitch.isOn;
        accelUpperStepper.isEnabled = accelSwitch.isOn;
        tempUpperStepper.isEnabled = tempSwitch.isOn;
        tempLowerStepper.isEnabled = tempSwitch.isOn;
    }
    
    func setFromCurrent() {
        setCurrentLabel(hrCurrentLabel, currentReading: Double(getHR()))
        setCurrentLabel(noiseCurrentLabel, currentReading: getNoise())
        setCurrentLabel(accelCurrentLabel, currentReading: getAccel())
        setCurrentLabel(tempCurrentLabel, currentReading: Double(getTemp()))
    }
        
}

