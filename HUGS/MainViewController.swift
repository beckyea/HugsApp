//
//  MainViewController.swift
//  HUGS
//
//  Created by Becky Abramowitz on 1/4/18.
//  Copyright © 2018 HUGS. All rights reserved.
//

import UIKit
import os.log

class MainViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UINavigationItem!
    @IBOutlet weak var overrideStatusLabel: UILabel!
    @IBOutlet weak var currentHRLabel: UILabel!
    @IBOutlet weak var currentNoiseLabel: UILabel!
    @IBOutlet weak var currentTempLabel: UILabel!
    @IBOutlet weak var currentAccelLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var modeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var rangeHRLabel: UILabel!
    @IBOutlet weak var rangeNoiseLabel: UILabel!
    @IBOutlet weak var rangeTempLabel: UILabel!
    @IBOutlet weak var rangeAccelLabel: UILabel!
    @IBOutlet weak var pressureSlider: UISlider!
    
    var refreshTimer: Timer!
    
    @IBAction func modeControlChanged(_ sender: Any) {
        switch modeSegmentedControl.selectedSegmentIndex {
        case 0: inProactiveMode = true;
        case 1: inProactiveMode = false;
        default: break;
        }
        broadcastSettings()
        
    }
    
    @IBAction func pressureSliderChanged(_ sender: UISlider) {
        pressureValue = Double(Int(sender.value*10)) * 0.1
        broadcastSettings()

    }
    
    @IBAction func overrideButtonClicked(_ sender: Any) {
        var popUpWord: String = "inflate";
        if (getActivationStatus()) { popUpWord = "deflate" }
        let popUpMessage : String = "This will override current inflation and " + popUpWord + " the vest."
        let overrideAlert = UIAlertController(title:"Override Confirmation", message:popUpMessage, preferredStyle: .alert)
        overrideAlert.addAction(UIAlertAction(title:"Confirm", style:.default, handler: {_ in NSLog("Override Confirmed");
            setActivationStatus(!getActivationStatus());
            if (!getActivationStatus()) {
                inProactiveMode = false;
                self.modeSegmentedControl.selectedSegmentIndex = 1;
            }
            self.setOverideStatusLabel();
            self.broadcastSettings()
        }))
        overrideAlert.addAction(UIAlertAction(title:"Cancel", style:.default, handler: {_ in NSLog("Override Cancelled")}))
        self.present(overrideAlert, animated:true, completion:nil)
    }
    
    @objc func refreshAction() {
        setCurrentLabels()
        setOverideStatusLabel()
        setDeviceStatusButton()
    }
    
    override func viewDidLoad() {
        
        let font = UIFont.systemFont(ofSize: 24)
        modeSegmentedControl.setTitleTextAttributes([NSAttributedStringKey.font: font],
                                                for: .normal)
        super.viewDidLoad()
        
        if !getConfiguration() {
            if let savedSystemVars = NSKeyedUnarchiver.unarchiveObject(withFile: VarsArchiveURL.path) as? SystemVariables {
                os_log("Successfully loaded system variables", log: OSLog.default, type:.debug)
                userVars = savedSystemVars
                configure()
            } else {
                let createVC = self.storyboard?.instantiateViewController(withIdentifier: "createViewController") as! CreateViewController
                self.navigationController?.pushViewController(createVC, animated: true)
            }
        }
        
        // Intialize Title
        titleLabel.title = userVars.userName + "'s HUGS"
        
        loadThresholds()
        setDeviceStatusButton()
        
        setCurrentLabels()
        setRangeLabels()
        broadcastNewThresholds()
        broadcastSettings()
        
        if inProactiveMode {
            modeSegmentedControl.selectedSegmentIndex = 0
        } else {
            modeSegmentedControl.selectedSegmentIndex = 1
        }
        
        
        pressureSlider.setValue(Float(pressureValue), animated: true)
        
        refreshTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(refreshAction), userInfo: nil, repeats: true)
        
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
    
    func setDeviceStatusButton() {
        if (currPeriphDelegate == nil) {
            statusLabel.text = "Not Connected";
        } else {
            statusLabel.text = "Connected";
        }
    }
    
    func broadcastSettings() {
        if (currPeriphDelegate != nil) {
            currPeriphDelegate.writeSettings();
        }
    }
    
    func broadcastNewThresholds() {
        if (currPeriphDelegate != nil) {
            currPeriphDelegate.writeThresholds();
        }
    }
    
    func setCurrentLabels() {
        currentHRLabel.text = String(getHR())
        currentNoiseLabel.text = String(format: "%.1f", getNoise())
        currentTempLabel.text = String(getTemp())
        currentAccelLabel.text = String(getAccel())
        var textColor : UIColor;
        if (currPeriphDelegate != nil) { textColor = UIColor.black } else { textColor =  UIColor.white }
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
    
    func loadThresholds() {
        if let savedHRThreshold = loadThreshold(fromPath: HRArchiveURL) {
            os_log("Successfully loaded HR thresholds", log: OSLog.default, type:.debug)
            heartRateThreshold = savedHRThreshold
        } else {os_log("Did not load HR thresholds", log: OSLog.default, type:.error) }
        if let savedNoiseThreshold = loadThreshold(fromPath: NoiseArchiveURL) {
            os_log("Successfully loaded Noise thresholds", log: OSLog.default, type:.debug)
            noiseThreshold = savedNoiseThreshold
        } else {os_log("Did not load Noise thresholds", log: OSLog.default, type:.error) }
        if let savedAccelThreshold = loadThreshold(fromPath: AccelArchiveURL) {
            os_log("Successfully loaded Accel thresholds", log: OSLog.default, type:.debug)
            accelThreshold = savedAccelThreshold
        } else {os_log("Did not load Accel thresholds", log: OSLog.default, type:.error) }
        if let savedTempThreshold = loadThreshold(fromPath: TempArchiveURL) {
            os_log("Successfully loaded Temp thresholds", log: OSLog.default, type:.debug)
            tempThreshold = savedTempThreshold
        } else {os_log("Did not load Temp thresholds", log: OSLog.default, type:.error) }
        if let savedLightThreshold = loadThreshold(fromPath: LightArchiveURL) {
            os_log("Successfully loaded Light thresholds", log: OSLog.default, type:.debug)
            lightThreshold = savedLightThreshold
        } else {os_log("Did not load Light thresholds", log: OSLog.default, type:.error) }
    }
    
    func loadThreshold(fromPath: URL) -> Threshold? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: fromPath.path) as? Threshold
    }
}
