//
//  ConnectView.swift
//  SwiftBLEArduino
//
//  Created by Madap on 8/23/24.
//

import Foundation
import SwiftUI
import UIKit

struct ConnectView: View {
    
    @ObservedObject var viewModel: ConnectViewModel
    
    @Environment(\.dismiss) var dismiss
    
    @State var isToggleOn: Bool = false
    @State var isPeripheralReady: Bool = false
    @State var lastEKGval: String = "" // @State var lastTemperature: Int = 0
    @State var ekgData: [String] = []
    @State var leads12: [[Double]] = []
    
    var body: some View {
        NavigationStack {
            
            VStack {
                Text(viewModel.connectedPeripheral.name ?? "Unknown")
                    .font(.title)
                ZStack {
                    CardView()
                    HStack {
                        Text("Led")
                            .padding(.horizontal)
                        Button("On") {
                            viewModel.turnOnLed()
                        }
                        .disabled(!isPeripheralReady)
                        .buttonStyle(.borderedProminent)
                        Button("Off") {
                            print($ekgData)
                            //                        viewModel.turnOffLed()
                        }
                        .disabled(!isPeripheralReady)
                        .buttonStyle(.borderedProminent)
                    }
                }
                ZStack {
                    CardView()
                    VStack {
                        Text("\(lastEKGval) EKG")
                            .font(.largeTitle)
                        HStack {
                            Spacer()
                                .frame(alignment: .trailing)
                            
                            Button("Start Recording") {
                                isToggleOn.toggle()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.10) {
                                    viewModel.turnOnLed()
                                }
                            }
                            .disabled(!isPeripheralReady)
                            .buttonStyle(.borderedProminent)
                            
                            
                            Spacer()
                                .frame(alignment: .trailing)
                            
                        }
                    }
                }
                
                ZStack {
                    CardView()
                    VStack {
                        Text("Compute Reconstruction")
                            .font(.largeTitle)
                        VStack {
                            Spacer()
                                .frame(alignment: .trailing)
                            
                            Button("Reconstruct") {
                                leads12 = reconstruction(in: ekgData)
                                //                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.20) {
                                //                                GraphView(dataArrays: leads12)
                                //                            }
                            }
                            .buttonStyle(.borderedProminent)
                            
                            NavigationLink(destination: GraphView(dataArrays: leads12)) {
                                Text("Show Graphs")
                                    .buttonStyle(.borderedProminent)
                            }
                            .disabled(leads12.isEmpty)
                            
                            
                            Spacer()
                                .frame(alignment: .trailing)
                            
                        }
                    }
                }
                
//                if !leads12.isEmpty {
//                    GraphView(dataArrays: leads12)
//                }
                
                Spacer()
                    .frame(maxHeight:.infinity)
                Button {
                    dismiss()
                } label: {
                    Text("Disconnect")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal)
            }
            .onChange(of: isToggleOn) {
                if isToggleOn {
                    viewModel.startNotifyEKG()
                } else {
                    viewModel.stopNotifyEKG()
                }
            }
            .onReceive(viewModel.$state) { state in
                switch state {
                case .ready:
                    isPeripheralReady = true
                case let .temperature(temp):
                    lastEKGval = temp
                default:
                    print("Not handled")
                }
            }
            .onChange(of: lastEKGval) { oldValue, newValue in
                
                ekgData.append(newValue)
            }
        }
    }
}

struct PeripheralView_Previews: PreviewProvider {
    
    final class FakeUseCase: PeripheralUseCaseProtocol {
        var onWriteEKGStartState: ((Bool) -> Void)?
        
        var peripheral: Peripheral?
        
        var onWriteLedState: ((Bool) -> Void)?
        var onReadTemperature: ((String) -> Void)?  // var onReadTemperature: ((Int) -> Void)?
        var onPeripheralReady: (() -> Void)?
        var onError: ((Error) -> Void)?

        func writeLedState(isOn: Bool) {}
        
        func readTemperature() {
            onReadTemperature?("25")
        }
        
        func notifyTemperature(_ isOn: Bool) {}
    }
    
    static var viewModel = {
        ConnectViewModel(useCase: FakeUseCase(),
                            connectedPeripheral: .init(name: "iOSArduinoBoard"))
    }()
    
    
    static var previews: some View {
        ConnectView(viewModel: viewModel, isPeripheralReady: true)
    }
}

struct CardView: View {
  var body: some View {
    RoundedRectangle(cornerRadius: 16, style: .continuous)
      .shadow(color: Color(white: 0.5, opacity: 0.2), radius: 6)
      .foregroundColor(.init(uiColor: .secondarySystemBackground))
  }
}
