//
//  Global.swift
//  HUGS
//
//  Created by Becky Abramowitz on 1/4/18.
//  Copyright © 2018 HUGS. All rights reserved.
//

import Foundation
import os.log
import CoreBluetooth

// STRUCTS
public class SystemVariables : NSObject, NSCoding {
    var userName : String;
    var userBirthday : Date;
    var userWeight : Double;
    
    
    init(userName: String, userBirthday: Date, userWeight: Double) {
        self.userName = userName;
        self.userBirthday = userBirthday;
        self.userWeight = userWeight;
    }
    
    public func encode(with aCoder:NSCoder) {
        aCoder.encode(self.userName, forKey: SystemKey.userName)
        aCoder.encode(self.userBirthday, forKey: SystemKey.userBirthday)
        aCoder.encode(self.userWeight, forKey: SystemKey.userWeight)
        aCoder.encode(pressureValue, forKey: SystemKey.pressureApp)

    }
    
    required convenience public init?(coder aDecoder:NSCoder) {
        guard let tempUN = aDecoder.decodeObject(forKey: SystemKey.userName) as? String else {
            os_log("Unable to decode User Name", log:OSLog.default, type: .default)
            return nil
        }
        guard let tempUB = aDecoder.decodeObject(forKey: SystemKey.userBirthday) as? Date else {
            os_log("Unable to decode User Birthday", log:OSLog.default, type: .default)
            return nil
        }
        let tempUW = aDecoder.decodeDouble(forKey: SystemKey.userWeight) as Double
        
        pressureValue = aDecoder.decodeDouble(forKey: SystemKey.pressureApp) as Double
        
        self.init(userName: tempUN, userBirthday: tempUB, userWeight: tempUW)
    }

}

public class Threshold : NSObject, NSCoding {
    var isOn : Bool;
    var upperBound : Double!;
    var lowerBound : Double!;
    
    init(isOn:Bool, upperBound:Double!, lowerBound:Double!) {
        self.isOn = isOn;
        self.upperBound = upperBound;
        self.lowerBound = lowerBound;
    }
    
    public func encode(with aCoder:NSCoder) {
        aCoder.encode(self.isOn, forKey: ThresholdKey.isOn)
        aCoder.encode(self.upperBound, forKey: ThresholdKey.upperBound)
        aCoder.encode(self.lowerBound, forKey: ThresholdKey.lowerBound)
    }
    
    required convenience public init?(coder aDecoder:NSCoder) {
        let tempIO = aDecoder.decodeObject(forKey: ThresholdKey.isOn) as? Bool ?? aDecoder.decodeBool(forKey: ThresholdKey.isOn)
        let tempUB = aDecoder.decodeObject(forKey: ThresholdKey.upperBound) as? Double
        let tempLB = aDecoder.decodeObject(forKey: ThresholdKey.lowerBound) as? Double
        
        self.init(isOn: tempIO, upperBound: tempUB, lowerBound: tempLB)
    }
}

let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
let VarsArchiveURL = DocumentsDirectory.appendingPathComponent("vars")
let HRArchiveURL = DocumentsDirectory.appendingPathComponent("hr_threshold")
let NoiseArchiveURL = DocumentsDirectory.appendingPathComponent("noise_threshold")
let AccelArchiveURL = DocumentsDirectory.appendingPathComponent("accel_threshold")
let TempArchiveURL = DocumentsDirectory.appendingPathComponent("temp_threshold")
let LightArchiveURL = DocumentsDirectory.appendingPathComponent("light_threshold")

// BLUETOOTH CONNECTIVITY
let bleDelegate : BluetoothDelegate = BluetoothDelegate()
var currPeriphDelegate: UartDelegate!


// PUBLIC VARIABLES
public var userVars = SystemVariables(userName: "",
                                      userBirthday: Date(),
                                      userWeight: 40.0);

public var heartRateThreshold = Threshold(isOn: false, upperBound: 75.0, lowerBound: 65.0)
public var noiseThreshold = Threshold(isOn: false, upperBound: 50.0, lowerBound: nil)
public var accelThreshold = Threshold(isOn: false, upperBound: 1.0, lowerBound: nil)
public var tempThreshold = Threshold(isOn: false, upperBound: 35.0, lowerBound: 5.0)
public var lightThreshold = Threshold(isOn: false, upperBound: nil, lowerBound: nil)

// READINGS
private var currentHR : Int = 70;
private var currentNoise : Double = 50.0;
private var currentTemp : Int = 20;
private var currentAccel : Double = 1.0;
private var currentPressure: Double = 0;

public func getHR() -> Int { return currentHR; }
public func getNoise() -> Double { return currentNoise; }
public func getTemp() -> Int { return currentTemp; }
public func getAccel() -> Double { return currentAccel; }
public func getCurrP() -> Double { return currentPressure; }

public func setHR(_ hr:Int) { currentHR = hr; }
public func setNoise(_ noise:Double) { currentNoise = noise; }
public func setTemp(_ temp:Int) { currentTemp = temp; }
public func setAccel(_ accel:Double) { currentAccel = accel; }
public func setCurrP(_ pressure:Double) { currentPressure = pressure/50.0; }

// TOGGLEABLE STATES
public var inProactiveMode : Bool = false;

private var configured : Bool = false;
public func getConfiguration() -> Bool { return configured; }
public func configure() { configured = true; }

private var isOn : Bool = false;
public func getActivationStatus() -> Bool { return isOn; }
public func setActivationStatus(_ newState: Bool) { isOn = newState; }
public var pressureValue : Double = 0.75;



// Stuff for Persistence
struct ThresholdKey {
    static let isOn = "isOn"
    static let upperBound = "upperBound"
    static let lowerBound = "lowerBound"
    static let pressureApp = "pressureApp"
}

struct SystemKey {
    static let userName = "userName"
    static let userBirthday = "userBirthday"
    static let userWeight = "userWeight"
    static let pressureApp = "pressureApp"
}

// String Manipulation
extension String {
    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }
    
    func substring(from: Int) -> String {
        let fromIndex = index(from: from)
        return substring(from: fromIndex)
    }
    
    func substring(to: Int) -> String {
        let toIndex = index(from: to)
        return substring(to: toIndex)
    }
    
    func substring(with r: Range<Int>) -> String {
        let startIndex = index(from: r.lowerBound)
        let endIndex = index(from: r.upperBound)
        return substring(with: startIndex..<endIndex)
    }
}
