//
//  GraphView.swift
//  SwiftBLEArduino
//
//  Created by Madap on 9/12/24.
//

import Foundation
import SwiftUI
import Charts

struct ChartView: View {
    let data: [Double]
    let title: String

    var body: some View {
        VStack {
            Text(title)
                .font(.headline)
                .padding(.top)
            
            ScrollView(.horizontal) {
                ZStack {
                    // EKG-like grid
                    GridShape()
                        .stroke(Color.red.opacity(0.3), lineWidth: 1)
//                        .frame(width: 1000, height: (UIScreen.main.bounds.height / 5) * 1.66)
                        .frame(width: 1000, height: UIScreen.main.bounds.height / 3)
                    
                    
                    
                    // Chart
                    Chart {
                        ForEach(data.indices, id: \.self) { index in
                            LineMark(
                                x: .value("Index", index),
                                y: .value("mV", data[index])
                            )
                            .foregroundStyle(Color.black.opacity(0.9)) // Set line color to black
                        }
                    }
                    .frame(width: 1000, height: UIScreen.main.bounds.height / 3)
                    .chartXAxis {
                        AxisMarks(values: [0]) { _ in
                            AxisValueLabel {
                                Text("ms")
                                    .font(.caption)
                                    .foregroundColor(.black)
                            }
                        }
                    }
                    .chartYAxis {
                        AxisMarks(position: .leading, values: [0]) { _ in
                            AxisValueLabel {
//                                Text("mV")
                                    
                            }
                        }
                    }
                    
                    VStack {
                        Spacer()
                        Text("mV")
                            .font(.caption) // Rotate the label to be vertical
                            .padding(.bottom, 20) // Adjust padding to position the label
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 0)
                    
                }
                .padding()
            }
        }
    }
}

struct GridShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Draw vertical lines
        for x in stride(from: 0, to: rect.width, by: 20) {
            path.move(to: CGPoint(x: x, y: 0))
            path.addLine(to: CGPoint(x: x, y: rect.height))
        }
        
        // Draw horizontal lines
        for y in stride(from: 0, to: rect.height, by: 20) {
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: rect.width, y: y))
        }
        
        return path
    }
}

struct GraphView: View {
    let labels = ["Lead I", "Lead II", "Lead III", "aVF", "aVR", "aVL", "V1", "V2", "V3", "V4", "V5", "V6"]
    var dataArrays: [[Double]] = []

    init(dataArrays: [[Double]]) {
        self.dataArrays = dataArrays
    }

    var body: some View {
        VStack {
            Text("Raghav's EKG Recording 9/12/24")
                .bold()
                .padding(.top)
            
            ScrollView {
                LazyVStack(spacing: 20) {
                    ForEach(labels.indices, id: \.self) { index in
                        if index < dataArrays.count {
                            ChartView(data: dataArrays[index], title: labels[index])
                        }
                    }
                }
                .padding()
            }
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.red.opacity(0.3), Color.white]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all) // Extend the gradient to the edges
        )
    }
}
