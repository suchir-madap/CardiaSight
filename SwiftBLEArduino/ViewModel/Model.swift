//
//  Model.swift
//  SwiftBLEArduino
//
//  Created by Madap on 10/2/24.
//

import Foundation
import SwiftUI

class Model: ObservableObject {
    // Tab Bar
    @Published var showTab: Bool = true

    // Navigation Bar
    @Published var showNav: Bool = true

    @Published var loggedIn: Bool = false

    @Published var showSafari: Bool = false
}
