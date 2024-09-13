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
    
    @State private var showGraphs = false
    @State var isToggleOn: Bool = false
    @State var isPeripheralReady: Bool = false
    @State var lastEKGval: String = "" // @State var lastTemperature: Int = 0
    @State var ekgData: [String] = []
    @State var leads3: [[Double]] = [[], [], []]
    @State var leads12: [[Double]] = []
    @State private var isBluetooth: Bool = true
    
    var body: some View {
        NavigationStack {
            
            VStack {
                Text(viewModel.connectedPeripheral.name ?? "Unknown")
                    .font(.title)
                    .bold()
                
                ZStack {
                    CardView()
                    VStack {
                        Spacer()
//                           .frame(alignment: .trailing)
//                        Text("\(lastEKGval) EKG")
//                            .font(.largeTitle)
                        VStack(alignment: .center, spacing: 16) {
//                            Spacer()
//                                .frame(alignment: .trailing)
                            
                            Image("CardiaRing2") // Replace "YourImageName" with the actual name of your image file
                                .resizable() // Makes the image resizable
                                .aspectRatio(contentMode: .fit) // Maintains the aspect ratio
                                .frame(width: 120, height: 120) // Sets the frame size
                                .clipShape(Circle()) // Clips the image to a circle shape
                                .overlay(Circle().stroke(isBluetooth ? Color.green : Color.red, lineWidth: 4)) // Adds a border
                                .shadow(radius: 10) // Adds a shadow
                                .padding()
                                .rotationEffect(Angle(degrees: 10))
                            
                            Button("Record EKG") {
                                isToggleOn.toggle()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.10) {
                                    viewModel.turnOnLed()
                                }
                            }
                            .disabled(!isPeripheralReady)
                            .buttonStyle(.borderedProminent)
                            .frame(width: 200, height: 50) // Adjust width and height as needed
                            .font(.title) 
                            .bold()
                            .tint(Color(red: 0.9, green: 0.2, blue: 0.2))
                            

                            NavigationLink(destination: GraphView(dataArrays: leads12)) {
                                Text("Show Recordings")
                                    .buttonStyle(.borderedProminent)
                                    .frame(maxWidth: .infinity) // Make sure the text is centered
                                    .multilineTextAlignment(.center)
                                    .bold()
                                
                            }
                            .disabled(leads12.isEmpty)
                            .buttonStyle(.borderedProminent)
                            .frame(width: 200, height: 50)
                            .tint(Color(red: 0.9, green: 0.2, blue: 0.2))
                            
//                            Spacer()
//                                .frame(alignment: .trailing)
                            
                        }
                        .frame(maxWidth: .infinity) // Center the VStack within the parent
                        .padding()

                        Spacer()
                    }
                }
                
                ZStack {
                    CardView()
                    VStack {
                        Spacer()
                            .frame(alignment: .trailing)
                    }
                    let lead1val: [Double] = smoothFunction(inputArray: leads3[0],  period: 5)
                    ChartView(data: lead1val, title: "Lead I")
                }
                
                
//                if !leads12.isEmpty {
//                    GraphView(dataArrays: leads12)
//                }
                
//                Spacer()
//                    .frame(maxHeight:.infinity)
                Button {
                    dismiss()
                } label: {
                    Text("Disconnect")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal)
                .tint(Color(red: 0.9, green: 0.2, blue: 0.2))
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
                if (newValue != "done") {
                    ekgData.append(newValue)
                    dataExpansion(in: newValue, in: &leads3)
                } else {
                    leads12 = reconstruction(in: leads3)
                    showGraphs = true
                    // call GraphView(dataArrays: leads12)
                }
                
            }
            .sheet(isPresented: $showGraphs) {
                GraphView(dataArrays: leads12)
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
