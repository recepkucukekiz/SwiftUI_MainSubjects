//
//  ApiTestApp.swift
//  ApiTest
//
//  Created by Recep Küçükekiz on 6.01.2023.
//

import SwiftUI

@main
struct ApiTestApp: App {
    var network = Network()
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(network)
        }
    }
}
