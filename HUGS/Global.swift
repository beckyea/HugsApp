//
//  Global.swift
//  HUGS
//
//  Created by Becky Abramowitz on 1/4/18.
//  Copyright © 2018 HUGS. All rights reserved.
//

import Foundation

// STRUCTS
public struct SystemVariables {
    var userName : String;
    var userBirthday : Date;
    var userWeight : Double;
}

public struct Threshold {
    var isOn : Bool!;
    var upperBound : Double!;
    var lowerBound : Double!;
}

// PUBLIC VARIABLES
public var userVars = SystemVariables(userName: "",
                                      userBirthday: Date(),
                                      userWeight: 40.0);

public var heartRateThreshold = Threshold(isOn: false, upperBound: 75.0, lowerBound: 65.0)
public var noiseThreshold = Threshold(isOn: false, upperBound: 50.0, lowerBound: nil)
public var accelThreshold = Threshold(isOn: false, upperBound: 1.0, lowerBound: nil)
public var tempThreshold = Threshold(isOn: false, upperBound: 70.0, lowerBound: 60.0)
public var lightThreshold = Threshold(isOn: false, upperBound: nil, lowerBound: nil)

// READINGS
private var currentHR : Int = 70;
private var currentNoise : Double = 50.0;
private var currentTemp : Int = 60;
private var currentAccel : Double = 1.0;

public func getHR() -> Int { return currentHR; }
public func getNoise() -> Double { return currentNoise; }
public func getTemp() -> Int { return currentTemp; }
public func getAccel() -> Double { return currentAccel; }

// TOGGLEABLE STATES
public var isConnected : Bool = true;

private var configured : Bool = false;
public func getConfiguration() -> Bool { return configured; }
public func configure() { configured = true; }

private var isOn : Bool = false;
public func getActivationStatus() -> Bool { return isOn; }
public func setActivationStatus(_ newState: Bool) { isOn = newState; }
