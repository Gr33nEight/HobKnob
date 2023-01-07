//
//  ContentView.swift
//  HobKnob
//
//  Created by Natanael Jop on 16/11/2022.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("darkMode") private var darkMode = false
    @StateObject var userVM = UserViewModel()
    @StateObject var monitor = Monitor()
    @StateObject var purchaseManager = PurchaseManager()
    var body: some View {
        if monitor.status == .disconnected {
            NoWifiView(monitor: monitor)
        }else{
            MainView()
                .environmentObject(userVM)
                .environmentObject(purchaseManager)
                .preferredColorScheme(darkMode ? .dark : .light)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .loadingOverlay(show: $userVM.isLoading)
                .loadingOverlay(show: $purchaseManager.isWaiting)
                .errorAlert(errorService: $userVM.errorService)
                .task {
                    await purchaseManager.updatePurchaseProducts()
                    do {
                        try await purchaseManager.loadProducts()
                    } catch {
                        userVM.errorService = .error(message: error.localizedDescription)
                    }
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
