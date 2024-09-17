//
//  SwiftBLEArduinoApp.swift
//  SwiftBLEArduino
//
//  Created by Madap on 8/23/24.
//


import SwiftUI

@main
struct SwiftBLEArduinoApp: App {
    
//    @StateObject var viewModel = ScanViewModel(useCase: CentralUseCase())
    
    @StateObject private var viewModel: ScanViewModel
        
    init() {
        let viewModel = ScanViewModel(useCase: CentralUseCase())
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ScanView(viewModel: viewModel)
            }
        }
    }
}
