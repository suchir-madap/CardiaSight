//
//  PeripheralUseCase.swift
//  SwiftBLEArduino
//
//  Created by Madap on 8/23/24.
//

import Foundation
import CoreBluetooth

protocol PeripheralUseCaseProtocol {
    
    var peripheral: Peripheral? { get set }
    
    var onWriteEKGStartState: ((Bool) -> Void)? { get set }
    var onReadTemperature: ((String) -> Void)? { get set } // On Read will most likely be deprecated
    var onPeripheralReady: (() -> Void)? { get set }
    var onError: ((Error) -> Void)? { get set }


    func writeLedState(isOn: Bool)
    func readTemperature()
    func notifyTemperature(_ isOn: Bool)
//    func notifyEKG(_ isOn: Bool)
}

class PeripheralUseCase: NSObject, PeripheralUseCaseProtocol {
    
    var peripheral: Peripheral? {
        didSet {
            self.peripheral?.cbPeripheral?.delegate = self
            discoverServices()
        }
    }
    
    var cbPeripheral: CBPeripheral? {
        peripheral?.cbPeripheral
    }
    
    var onWriteEKGStartState: ((Bool) -> Void)?
    var onReadTemperature: ((String) -> Void)? // var onReadTemperature: ((Int) -> Void)?
    var onPeripheralReady: (() -> Void)?
    var onError: ((Error) -> Void)?
    
   
    var discoveredServices = [CBUUID : CBService]()
    var discoveredCharacteristics = [CBUUID : CBCharacteristic]()
    
    func discoverServices() {
        cbPeripheral?.discoverServices([UUIDs.startEKGService, UUIDs.EKGDataService])
    }
    
    func writeLedState(isOn: Bool) {
        guard let ledCharacteristic = discoveredCharacteristics[UUIDs.startEKGCharacteristic] else {
            return
        }
        cbPeripheral?.writeValue(Data(isOn ? [0x01] : [0x00]), for: ledCharacteristic, type: .withResponse)
    }
    
    func readTemperature() {
        guard let tempCharacteristic = discoveredCharacteristics[UUIDs.EKGDataCharacteristic] else {
            return
        }
        cbPeripheral?.readValue(for: tempCharacteristic)
    }
    
    func notifyTemperature(_ isOn: Bool) {
        guard let tempCharacteristic = discoveredCharacteristics[UUIDs.EKGDataCharacteristic] else {
            return
        }
        cbPeripheral?.setNotifyValue(isOn, for: tempCharacteristic)
    }
    
//    var ekgDataArray: [Data] = [] // Array to store EKG data
//    var ekgTimer: Timer?
//    
//    func notifyEKG(_ isOn: Bool) {
//        guard let ekgCharacteristic = discoveredCharacteristics[UUIDs.EKGDataCharacteristic] else {
//            return
//        }
//        cbPeripheral?.setNotifyValue(isOn, for: ekgCharacteristic)
//        
//        if isOn {
//            // Start a timer to stop notifications after 10 seconds
//            ekgTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false) { [weak self] _ in
//                self?.cbPeripheral?.setNotifyValue(false, for: ekgCharacteristic)
//            }
//        } else {
//            // Invalidate the timer if notifications are turned off manually
//            ekgTimer?.invalidate()
//        }
//    }
//    
//    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
//        guard error == nil else {
//            print("Error receiving data: \(error!)")
//            return
//        }
//        
//        if characteristic.uuid == UUIDs.EKGDataCharacteristic, let data = characteristic.value {
//            ekgDataArray.append(data) // Store the received data in the array
//        }
//    }
    
    
    
    fileprivate func requiredCharacteristicUUIDs(for service: CBService) -> [CBUUID] {
        switch service.uuid {
        case UUIDs.startEKGService where discoveredCharacteristics[UUIDs.startEKGCharacteristic] == nil:
            return [UUIDs.startEKGCharacteristic]
        case UUIDs.EKGDataService where discoveredCharacteristics[UUIDs.EKGDataCharacteristic] == nil:
            return [UUIDs.EKGDataCharacteristic]
        default:
            return []
        }
    }
}

extension PeripheralUseCase: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services, error == nil else {
            return
        }
        for service in services {
            discoveredServices[service.uuid] = service
            let uuids = requiredCharacteristicUUIDs(for: service)
            guard !uuids.isEmpty else {
                return
            }
            peripheral.discoverCharacteristics(uuids, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else {
            return
        }
        for characteristic in characteristics {
            discoveredCharacteristics[characteristic.uuid] = characteristic
        }

        if discoveredCharacteristics[UUIDs.EKGDataCharacteristic] != nil &&
            discoveredCharacteristics[UUIDs.startEKGCharacteristic] != nil {
            onPeripheralReady?()
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error {
            onError?(error)
            return
        }
        switch characteristic.uuid {
        case UUIDs.startEKGCharacteristic:
            let value: UInt8 = {
                guard let value = characteristic.value?.first else {
                    return 0
                }
                return value
            }()
            onWriteEKGStartState?(value != 0 ? true : false)
        default:
            fatalError()
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        switch characteristic.uuid {
        case UUIDs.EKGDataCharacteristic:
            let stringValue: String = {
                guard let data = characteristic.value,
                      let string = String(data: data, encoding: .utf8) else {
                    return "Unable to read data"
                }
                return string
            }()
            onReadTemperature?(stringValue)
//            let value: UInt8 = {
//                guard let value = characteristic.value?.first else {
//                    return 0
//                }
//                return value
//            }()
//            onReadTemperature?(String(value))
        default:
            fatalError()
        }
    }
}
