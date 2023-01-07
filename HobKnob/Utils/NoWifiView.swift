//
//  NoWifiView.swift
//  HobKnob
//
//  Created by Natanael Jop on 16/12/2022.
//

import SwiftUI
import Network

enum NetworkStatus: String {
    case connected
    case disconnected
}

class Monitor: ObservableObject {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "Monitor")

    @Published var status: NetworkStatus = .connected

    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if path.status == .satisfied {
                    self.status = .connected
                } else {
                    self.status = .disconnected
                }
            }
        }
        monitor.start(queue: queue)
    }
}


import SwiftUI

struct NoWifiView: View {
    @ObservedObject var monitor: Monitor
    var body: some View {
        VStack{
            Image(systemName: "wifi.slash")
                .font(.system(size: 100))
            Text(monitor.status.rawValue)
                .padding(30)
        }
    }
}
