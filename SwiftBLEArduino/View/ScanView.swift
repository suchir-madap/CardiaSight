//
//  ScanView.swift
//  SwiftBLEArduino
//
//  Created by Madap on 8/23/24.
//

import Foundation
import CoreBluetooth
import SwiftUI

struct ScanView: View {
    @ObservedObject var viewModel: ScanViewModel
    
    @State var shouldShowDetail = false
    @State var peripheralList = [Peripheral]()
    @State var isScanButtonEnabled = false
    
    var body: some View {
        VStack{
            Image("CardiaSightBanner2")
                .resizable() // Makes the image resizable
                .aspectRatio(contentMode: .fit)
                .frame(width: 350) // Adjust width to 80% of the original
                .padding()
            List(peripheralList, id: \.id) { peripheral  in
                Text("\(peripheral.name ?? "N/A")")
                    .font(.headline)
                    .foregroundColor(.blue)
                    .onTapGesture {
                        viewModel.connect(to: peripheral)
                    }
            }
            .listStyle(.plain)
//            Spacer()
            Button {
                viewModel.scan()
            } label: {
                Text("Connect to Device")
                    .frame(maxWidth: .infinity)
            }
            .tint(Color(red: 0.9, green: 0.2, blue: 0.2))
            .disabled(!isScanButtonEnabled)
            .buttonStyle(.borderedProminent)
            .padding(.horizontal)
        }
        .onReceive(viewModel.$state) { state in
            switch state {
            case .connected:
                shouldShowDetail = true
            case .scan(let list):
                peripheralList = list
            case .ready:
                isScanButtonEnabled = true
            default:
                print("Not handled")
            }
        }
//        .navigationTitle("CardiaSight")
//        .navigationBarTitleDisplayMode(.inline) // Ensure the title is inline
//        .toolbar {
//            ToolbarItem(placement: .navigationBarTrailing) {
//                Image("CardiaSightLogo") // Replace "logo" with the name of your image asset
//                    .resizable()
//                    .frame(width: 50, height: 50) // Adjust size as needed
//            }
//        }
        .navigationDestination(isPresented: $shouldShowDetail) {
            if case let .connected(peripheral) = viewModel.state  {
                let viewModel = ConnectViewModel(useCase: PeripheralUseCase(),
                    connectedPeripheral:peripheral)
                ConnectView(viewModel: viewModel)
            }
        }
        .onAppear {
            viewModel.disconnectIfConnected()
        }
    }
}

struct ScanAndConnectView_Previews: PreviewProvider {
    
    final class FakeUseCase: CentralManagerUseCaseProtocol {
        
        var onPeripheralDiscovery: ((Peripheral) -> Void)?
        
        var onCentralState: ((CBManagerState) -> Void)?
        
        var onConnection: ((Peripheral) -> Void)?
        
        var onDisconnection: ((Peripheral) -> Void)?
        
        func start() {
            onCentralState?(.poweredOn)
        }
        
        func scan(for services: [CBUUID]) {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                self.onPeripheralDiscovery?(Peripheral(name: "iOSArduinoBoard_1"))
                self.onPeripheralDiscovery?(Peripheral(name: "iOSArduinoBoard_2"))
            }
        }
        
        func connect(to peripheral: Peripheral) {
            print("Connecting")
            onConnection?(.init(name: "iOSArduinoBoard_1"))
        }
        
        func disconnect(from peripheral: Peripheral) {
            onDisconnection?(.init(name: "iOSArduinoBoard_1"))
        }
        
    }
    
    static var viewModel = {
        ScanViewModel(useCase: FakeUseCase())
    }()
    
    static var previews: some View {
        NavigationStack {
            ScanView(viewModel: viewModel)
        }
    }
}
