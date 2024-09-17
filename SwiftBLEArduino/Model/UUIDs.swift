//
//  UUIDs.swift
//  SwiftBLEArduino
//
//  Created by Madap on 8/23/24.
//

import Foundation
import CoreBluetooth

enum UUIDs {
    static let startEKGService = CBUUID(string: "cd48409a-f3cc-11ed-a05b-0242ac120003")
    static let startEKGCharacteristic = CBUUID(string:  "cd48409b-f3cc-11ed-a05b-0242ac120003") // Write
    
    static let EKGDataService = CBUUID(string: "d888a9c2-f3cc-11ed-a05b-0242ac120003")
    static let EKGDataCharacteristic = CBUUID(string:  "d888a9c3-f3cc-11ed-a05b-0242ac120003") // Read | Notify
}
