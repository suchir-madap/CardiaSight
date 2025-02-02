//
//  ConnectViewModel.swift
//  SwiftBLEArduino
//
//  Created by Madap on 8/23/24.
//

import Foundation

final class ConnectViewModel: ObservableObject {
    @Published var state = State.idle
    
    var useCase: PeripheralUseCaseProtocol
    let connectedPeripheral: Peripheral
    
    init(useCase: PeripheralUseCaseProtocol,
         connectedPeripheral: Peripheral) {
        self.useCase = useCase
        self.useCase.peripheral = connectedPeripheral
        self.connectedPeripheral = connectedPeripheral
        self.setCallbacks()
    }
    
    private func setCallbacks() {
        useCase.onPeripheralReady = { [weak self] in
            self?.state = .ready
        }
        
        useCase.onReadTemperature = { [weak self] value in
            self?.state = .temperature(value)
        }
        
        useCase.onWriteEKGStartState = { [weak self] value in
            self?.state = .ledState(value)
        }
        
        useCase.onError = { error in
            print("Error \(error)")
        }
    }
    
    func startNotifyEKG() {
        useCase.notifyTemperature(true)
    }
    
    func stopNotifyEKG() {
        useCase.notifyTemperature(false)
    }
    
    func recordEKG() {
        useCase.readTemperature()
    }
    
//    func recordEKGdata() {
//        useCase.notifyEKG(false)
//    }
    
    func turnOnLed() {
        useCase.writeLedState(isOn: true)
    }
    
    func turnOffLed() {
        useCase.writeLedState(isOn: false)
    }
}

extension ConnectViewModel {
    enum State {
        case idle
        case ready
        case temperature(String) //case temperature(Int)
        case ledState(Bool)
    }
}
