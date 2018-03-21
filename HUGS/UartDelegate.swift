//
//  UartDelegate.swift
//  HUGS
//
//  Created by Becky Abramowitz on 3/18/18.
//  Copyright © 2018 HUGS. All rights reserved.
//

import CoreBluetooth

class UartDelegate : NSObject, CBPeripheralManagerDelegate {
    
    var peripheralManager: CBPeripheralManager?
    var peripheral : CBPeripheral
    
    init(_ inPeriph: CBPeripheral) {
        self.peripheral = inPeriph;
        super.init()
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    func updateIncomingData () {
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "Notify"), object: nil , queue: nil) {
            notification in
            let inString = characteristicASCIIValue as String
            print(inString)
        }
    }
    
    public func writeSettings() {
        writeValue(data: createSettingsString())
        writeValue(data: ""); writeValue(data: "")
    }
    
    public func writeThresholds() {
        writeValue(data: createThresholdString(heartRateThreshold))
        writeValue(data: ""); writeValue(data: "")
        writeValue(data: createThresholdString(noiseThreshold))
        writeValue(data: ""); writeValue(data: "")
        writeValue(data: createThresholdString(tempThreshold))
        writeValue(data: ""); writeValue(data: "")
        writeValue(data: createThresholdString(accelThreshold))
        writeValue(data: ""); writeValue(data: "")
        writeValue(data: createThresholdString(lightThreshold))
    }
    
    // Write functions
    func writeValue(data: String){
        let valueString = (data as NSString).data(using: String.Encoding.utf8.rawValue)
        if let blePeripheral = blePeripheral{
            if let txCharacteristic = txCharacteristic {
                blePeripheral.writeValue(valueString!, for: txCharacteristic, type: CBCharacteristicWriteType.withResponse)
            }
        }
    }
    
    func writeCharacteristic(val: Int8){
        var val = val
        let ns = NSData(bytes: &val, length: MemoryLayout<Int8>.size)
        blePeripheral!.writeValue(ns as Data, for: txCharacteristic!, type: CBCharacteristicWriteType.withResponse)
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
            return
        }
        
    }
    
    //Check when someone subscribe to our characteristic, start sending the data
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        print("Device subscribe to characteristic")
    }
    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        if let error = error {
            print("\(error)")
            return
        }
    }
    
}
