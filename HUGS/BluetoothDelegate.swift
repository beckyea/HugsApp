//
//  BluetoothDelegate.swift
//  HUGS
//
//  Created by Becky Abramowitz on 3/10/18.
//  Copyright © 2018 HUGS. All rights reserved.
//

import Foundation
import UIKit
import CoreBluetooth

var txCharacteristic : CBCharacteristic?
var rxCharacteristic : CBCharacteristic?
var blePeripheral : CBPeripheral?
var characteristicASCIIValue = NSString()


public class BluetoothDelegate : NSObject, CBCentralManagerDelegate, CBPeripheralDelegate, UITableViewDelegate, UITableViewDataSource {
    
    
    //Data
    var centralManager : CBCentralManager!
    var RSSIs = [NSNumber]()
    var data = NSMutableData()
    var writeData: String = ""
    var peripherals: [CBPeripheral] = []
    var characteristicValue = [CBUUID: NSData]()
    var timer = Timer()
    var characteristics = [String : CBCharacteristic]()
    var scanning_flag : Bool = false;
    
    public func isScanning() -> Bool {
        return scanning_flag
    }

    public func refresh() {
        scanning_flag = true
        disconnectFromDevice()
        if (centralManager == nil) {
            centralManager = CBCentralManager(delegate: self, queue: nil)
        }
        self.peripherals = []
        self.RSSIs = []
        startScan()
    }
    
    public func startScan() {
        if (centralManager == nil) {
            centralManager = CBCentralManager(delegate: self, queue: nil)
        }
        peripherals = []
        print("Now Scanning...")
        self.timer.invalidate()
        centralManager?.scanForPeripherals(withServices: [BLEService_UUID] , options: [CBCentralManagerScanOptionAllowDuplicatesKey:false])
        Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.cancelScan), userInfo: nil, repeats: false)
    }
    
    @objc func cancelScan() {
        self.centralManager?.stopScan()
        scanning_flag = false
        print("Scan Stopped")
        print("Number of Peripherals Found: \(peripherals.count)")
    }
    
    func disconnectFromDevice () {
        if blePeripheral != nil {
            currPeriphDelegate = nil
            scanning_flag = false
            print("Disconnected")
            centralManager?.cancelPeripheralConnection(blePeripheral!)
        }
    }
    
    func restoreCentralManager() {
        centralManager?.delegate = self
    }
    
    // Wen the central manager discovers a peripheral while scanning.
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,advertisementData: [String : Any], rssi RSSI: NSNumber) {
        blePeripheral = peripheral
        self.peripherals.append(peripheral)
        self.RSSIs.append(RSSI)
        peripheral.delegate = self
        if blePeripheral == nil {
            print("Found new pheripheral devices with services")
            print("Peripheral name: \(String(describing: peripheral.name))")
            print ("Advertisement Data : \(advertisementData)")
        }
    }
    
    func connectToDevice () {
        centralManager?.connect(blePeripheral!, options: nil)
    }
    
    // Invoked when a connection is successfully created with a peripheral.
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connection complete")
        print("Peripheral info: \(String(describing: blePeripheral))")
        centralManager?.stopScan()
        print("Scan Stopped")
        data.length = 0 // erase data
        peripheral.delegate = self
        //Only look for services that matches transmit uuid
        peripheral.discoverServices([BLEService_UUID])
        currPeriphDelegate = UartDelegate(peripheral)
    }
    
    // Invoked when the central manager fails to create a connection with a peripheral.
    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        if error != nil {
            currPeriphDelegate = nil
            print("Failed to connect to peripheral")
            return
        }
    }
    
    public func disconnectAllConnections() {
        currPeriphDelegate = nil
        centralManager.cancelPeripheralConnection(blePeripheral!)
    }
    
    /* This method is invoked when your app calls the discoverServices(_:) method. If the services of the peripheral are successfully discovered, you can access them through the peripheral’s services property. If successful, the error parameter is nil. If unsuccessful, the error parameter returns the cause of the failure.*/
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if ((error) != nil) {
            print("Error discovering services: \(error!.localizedDescription)")
            return
        }
        guard let services = peripheral.services else { return }
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
            // bleService = service
        }
        print("Discovered Services: \(services)")
    }
    
    /* This method is invoked when your app calls the discoverCharacteristics(_:for:) method. If the characteristics of the specified service are successfully discovered, you can access them through the service's characteristics property. If successful, the error parameter is nil. If unsuccessful, the error parameter returns the cause of the failure. */
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if ((error) != nil) {
            print("Error discovering services: \(error!.localizedDescription)")
            return
        }
        guard let characteristics = service.characteristics else { return }
        print("Found \(characteristics.count) characteristics!")
        for characteristic in characteristics {
            if characteristic.uuid.isEqual(BLE_Characteristic_uuid_Rx)  {
                rxCharacteristic = characteristic
                peripheral.setNotifyValue(true, for: rxCharacteristic!)
                peripheral.readValue(for: characteristic)
                print("Rx Characteristic: \(characteristic.uuid)")
            }
            if characteristic.uuid.isEqual(BLE_Characteristic_uuid_Tx){
                txCharacteristic = characteristic
                print("Tx Characteristic: \(characteristic.uuid)")
            }
            peripheral.discoverDescriptors(for: characteristic)
        }
    }
    
    /*After you've found a characteristic of a service that you are interested in, you can read the characteristic's value by calling the peripheral "readValueForCharacteristic" method within the "didDiscoverCharacteristicsFor service" delegate. */
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if characteristic == rxCharacteristic {
            if let ASCIIstring = NSString(data: characteristic.value!, encoding: String.Encoding.utf8.rawValue) {
                characteristicASCIIValue = ASCIIstring
                print("Value Recieved: \((characteristicASCIIValue as String))")
                NotificationCenter.default.post(name:NSNotification.Name(rawValue: "Notify"), object: nil)
                parseCurrValueString(characteristicASCIIValue as String)
            }
        }
    }
    
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        if error != nil {
            print("\(error.debugDescription)")
            return
        }
        if ((characteristic.descriptors) != nil) {
            for x in characteristic.descriptors!{
                let descript = x as CBDescriptor!
                print("function name: DidDiscoverDescriptorForChar \(String(describing: descript?.description))")
                print("Rx Value \(String(describing: rxCharacteristic?.value))")
                print("Tx Value \(String(describing: txCharacteristic?.value))")
            }
        }
    }
    
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if (error != nil) {
            print("Error changing notification state:\(String(describing: error?.localizedDescription))")
        } else {
            print("Characteristic's value subscribed")
        }
        if (characteristic.isNotifying) {
            print ("Subscribed. Notification has begun for: \(characteristic.uuid)")
        }
    }
    
    
    
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        currPeriphDelegate = nil
        print("Disconnected")
    }
    
    
    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil else {
            print("Error discovering services: error")
            return
        }
        print("Message sent")
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?) {
        guard error == nil else {
            print("Error discovering services: error")
            return
        }
        print("Succeeded!")
    }
    
    public func bluetoothEnabled() -> Bool {
        if (centralManager == nil) {
            centralManager = CBCentralManager(delegate: self, queue: nil)
        }
        print(centralManager.state)
        return centralManager.state != .poweredOff
    }
    /*
     Invoked when the central manager’s state is updated.
     This is where we kick off the scan if Bluetooth is turned on.
     */
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == CBManagerState.poweredOn {
            print("Bluetooth Enabled")
            startScan()
        } else {
            print("Bluetooth Disabled - Make sure your Bluetooth is turned on")
        }
    }
    
    
    //Table View Functions
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.peripherals.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Connect to device where the peripheral is connected
        let cell = tableView.dequeueReusableCell(withIdentifier: "hugsCell") as! PeripheralTableViewCell
        let peripheral = self.peripherals[indexPath.row]
        
        if peripheral.name == nil {
            cell.peripheralLabel.text = "nil"
        } else {
            cell.peripheralLabel.text = peripheral.name
        }
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        blePeripheral = peripherals[indexPath.row]
        connectToDevice()
    }
    
}
