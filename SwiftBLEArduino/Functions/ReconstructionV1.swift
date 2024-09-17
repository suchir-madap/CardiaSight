//
//  ReconstructionV1.swift
//  SwiftBLEArduino
//
//  Created by Madap on 9/12/24.
//

import Foundation



func reconstruction(in streamedData: [[Double]]) -> [[Double]] {
    var result: [[Double]] = Array(repeating: [], count: 12)
    
    if (streamedData[0].count == 0) {
        return result
    }
    for index in 0...(streamedData[0].count - 1) {
        var parsedLead: [Double] = []
        for val in 0...2 {
            parsedLead.append(streamedData[val][index])
        }
        conversion3to12(in: parsedLead, in: &result)
        
    }
    
    
    
    for i in 0...11 {
        result[i] = smoothFunction(inputArray: result[i],  period: 5)
    }
    
    
//    print(result)
    
    
//    print("done reconstruction")
    return result
}


func reconstruction2(in streamedData: [String]) -> [[Double]] {
    var result: [[Double]] = Array(repeating: [], count: 12)
    
    for packet in streamedData {
        let sample = packet.split(separator: ";")
//        print(sample)
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
    
    for i in 0...11 {
        result[i] = smoothFunction(inputArray: result[i],  period: 5)
    }
    
    
//    print(result)
    
    
//    print("done reconstruction")
    return result
}


func dataExpansion(in liveData: String, in dataStore: inout [[Double]]) {
    let sample = liveData.split(separator: ";")
    for data in sample {
        let lead = data.split(separator: ",")
        for i in 1...3 {
            dataStore[i - 1].append(Double(lead[i])!)
        }
    }
    
}


func conversion3to12(in parsedLead: [Double], in result: inout [[Double]]) {
//    0 - l1, 1 - pl2, 2 - pv2
    let l1_original: Double = parsedLead[0] * 2.5
    let pl2: Double = parsedLead[1]
    let pv2: Double = parsedLead[2]
//    calculated leads
    
    let l2_original: Double = l1_original * 1.2
    let v2_chest: Double = pl2 - l2_original + (3 * pv2)/3
    
    let x_vector: Double = 0.0465 * (v2_chest) + 0.4651 * (l1_original) + 0.3463*(l2_original)
    let y_vector: Double = -0.1249 * (v2_chest) + -0.2010 * (l1_original) + 0.8280*(l2_original)
    let z_vector: Double = -1.1602 * (v2_chest) + 0.4591 * (l1_original) + -0.1397*(l2_original)
    
    
//    Final Result
    let V1 = -0.51291775 * x_vector + 0.15673116 * y_vector + -0.91745584 * z_vector

    let V2 = 0.04358253 * x_vector + 0.16353792 * y_vector + -1.38674177 * z_vector

    let V3 = 0.8829524 * x_vector + 0.09828608 * y_vector + -1.27847238 * z_vector

    let V4 = 1.21397425 * x_vector + 0.12660522 * y_vector + -0.60023889 * z_vector

    let V5 = 1.12436149 * x_vector + 0.12670267 * y_vector + -0.08535672 * z_vector

    let V6 = 0.83429147 * x_vector + 0.0762215 * y_vector + 0.22670162 * z_vector

    let l1 = 0.63219218 * x_vector + -0.23454475 * y_vector + 0.05969897 * z_vector

    let l2 = 0.23419118 * x_vector + 1.06570697 * y_vector + -0.13146203 * z_vector

    let l3 = l2 - l1

    let aVR = ((l1 + l2) * -1)/2

    let aVL = l1 - l2/2

    let aVF = l2 - (l1/2)
    
    result[0].append(l1)
    result[1].append(l2)
    result[2].append(l3)
    result[3].append(aVL)
    result[4].append(aVF)
    result[5].append(aVR)
    result[6].append(V1)
    result[7].append(V2)
    result[8].append(V3)
    result[9].append(V4)
    result[10].append(V5)
    result[11].append(V6)
//    ["Lead I", "Lead II", "Lead III", "aVL", "aVF", "aVR", "V1", "V2", "V3", "V4", "V5", "V6"]
    
}






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
