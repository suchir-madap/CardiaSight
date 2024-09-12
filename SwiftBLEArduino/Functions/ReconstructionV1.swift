//
//  ReconstructionV1.swift
//  SwiftBLEArduino
//
//  Created by Madap on 9/12/24.
//

import Foundation



func reconstruction(in streamedData: [String]) -> [[Double]] {
    var result: [[Double]] = Array(repeating: [], count: 12)
    
    for packet in streamedData {
        let sample = packet.split(separator: ";")
        print(sample)
        for data in sample {
            let lead = data.split(separator: ",")
//            var parsedLead: [Double] = []
            
//            for i in 1...3 {
//                parsedLead.append(Double(lead[i])!)
//            }
            
            for i in 1...3 {
//                parsedLead.append(Double(lead[i])!)
                result[(i - 1) ].append(Double(lead[i])!)
                result[(i - 1) + 3].append(Double(lead[i])!)
                result[(i - 1) + 6].append(Double(lead[i])!)
                result[(i - 1) + 9].append(Double(lead[i])!)
            }
//            print(parsedLead)
            
        }
    }
    
    
    
    print("done reconstruction")
    return result
}


//func conversion3to12(in parsedLead: [Double], in result:[[Double]]) {
////    0 - l1, 1 - pl2, 2 - pv2
//    let l1 = parsedLead[0]
//    let pl2 = parsedLead[1]
//    let pv2 = parsedLead[2]
////    calculated leads
//    let l2 = l1 * 1.2
//    let pv2 = (pl2 - l2 + (3 * pv2))/3
//    
//
//    
//    
//}






func smoothFunction(inputArray: [Double], period: Int) -> [Double] { // simpleMovingAverage
    guard period > 0, inputArray.count >= period else {
        return [] // Return an empty array if the period is invalid
    }
    
    var smoothedArray: [Double] = []
    
    for i in 0...(inputArray.count - period) {
        let window = inputArray[i..<(i + period)]
        let average = window.reduce(0, +) / Double(period)
        smoothedArray.append(average)
    }
    
    return smoothedArray
}
