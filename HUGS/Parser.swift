//
//  Parser.swift
//  HUGS
//
//  Created by Becky Abramowitz on 3/19/18.
//  Copyright © 2018 HUGS. All rights reserved.
//

public func parseCurrValueString(_ str: String) {
    print(str);
    var h_index : Int!;
    var n_index : Int!;
    var t_index : Int!;
    var a_index : Int!;
    var i_index : Int!;
    var c_index : Int!;
    for (index, char) in str.enumerated() {
        if (char == "h" && h_index == nil) { h_index = index; }
        else if (char == "h") { h_index = nil; }
        if (char == "n" && n_index == nil) { n_index = index; }
        else if (char == "n") { n_index = nil; }
        if (char == "t" && t_index == nil) { t_index = index; }
        else if (char == "t") { t_index = nil; }
        if (char == "a" && a_index == nil) { a_index = index; }
        else if (char == "a") { a_index = nil; }
        if (char == "i" && i_index == nil) { i_index = index; }
        else if (char == "i") { i_index = nil; }
        if (char == "c" && c_index == nil) { c_index = index; }
        else if (char == "c") { c_index = nil; }

    }
    if (h_index != nil && n_index != nil && n_index > h_index) {
        let tempHR = str.substring(with:h_index+1..<n_index);
        setHR(Int(tempHR)!);
    }
    if (n_index != nil && t_index != nil && t_index > n_index) {
        let tempNoise = str.substring(with:n_index+1..<t_index);
        setNoise(Double(tempNoise)!);
    }
    if (t_index != nil && a_index != nil && a_index > t_index) {
        let tempTemp = str.substring(with:t_index+1..<a_index);
        setTemp(Int(tempTemp)!);
    }
    if (a_index != nil && c_index != nil && c_index > a_index) {
        let tempAccel = str.substring(with: a_index+1..<c_index);
        setAccel(Double(tempAccel)!);
    }
    if (c_index != nil && i_index != nil && i_index > c_index) {
        let tempPressure = str.substring(with: c_index+1..<i_index);
        setCurrP(Double(tempPressure)!);
    }
    if (i_index != nil && i_index + 1 < str.count) {
        if (inProactiveMode) {
            setActivationStatus(str.substring(with: i_index+1..<i_index+2) == "1");
        }
    }
}

public func createThresholdString(_ threshold:Threshold) -> String {
    var s : String = ""
    if (threshold == heartRateThreshold) { s += "h"; }
    if (threshold == noiseThreshold) { s += "n"; }
    if (threshold == tempThreshold) { s += "t"; }
    if (threshold == accelThreshold) { s += "a"; }
    if (threshold == lightThreshold) { s += "l"; }
    s += ",";
    s += String(threshold.isOn ? 1 : 0);
    if (threshold.lowerBound != nil) {
        s += "," + String(format: "%.2f", threshold.lowerBound);
    }
    if (threshold.upperBound != nil) {
        s += "," + String(format: "%.2f", threshold.upperBound);
    }
    s+="\n";
//    print(s);
    return s;
}

public func createSettingsString() -> String {
    var s : String = "s,";
    s += String(inProactiveMode ? 1 : 0);
    s += ",";
    s += String(getActivationStatus() ? 1 : 0);
    s += ",";
    s += String(userVars.userWeight);
    s += ",";
    s += String(pressureValue);
    s+="\n";
    print(s);
    return s;
}
