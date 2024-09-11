//
//  Peripheral.swift
//  SwiftBLEArduino
//
//  Created by Madap on 8/23/24.
//

import Foundation
import CoreBluetooth


struct Peripheral: Identifiable, Equatable, Hashable {
    var cbPeripheral: CBPeripheral?
    let name: String?
    let id: UUID
    
    init(name: String) {
        self.name = name
        self.id = UUID()
    }
    
    init(cbPeripheral: CBPeripheral) {
        self.cbPeripheral = cbPeripheral
        self.id = cbPeripheral.identifier
        self.name = cbPeripheral.name
    }
}

