//
//  AppView.swift
//  SwiftBLEArduino
//
//  Created by Madap on 10/2/24.
//

import Supabase
import SwiftUI

struct AppView: View {
    @EnvironmentObject var viewModel: ScanViewModel
    @EnvironmentObject var model: Model
    
    let scanViewModel = ScanViewModel(useCase: CentralUseCase())
//    _scanViewModel = StateObject(wrappedValue: scanViewModel)
    
    let client = SupabaseClient(supabaseURL: URL(string: Secrets.supabaseURL)!,
                                supabaseKey: Secrets.supabaseKey)

    

    func checkSession() {
        Task {
            do {
                _ = try await client.auth.session
                model.loggedIn = true
            } catch {
                print("### ignore if session not found: \(error)")
            }
        }
    }

    var body: some View {
        HStack {
            if !model.loggedIn {
                LoginView()
            } else {
                ScanView(viewModel: scanViewModel)
            }
        }.onAppear {
            checkSession()
        }
    }
}

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView()
            .environmentObject(ScanViewModel(useCase: CentralUseCase()))
            .environmentObject(Model())
    }
}
