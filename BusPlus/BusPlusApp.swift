//
//  BusPlusApp.swift
//  BusPlus
//
//  Created by misono on 2021/08/05.
//

import SwiftUI

@main
struct BusPlusApp: App {
    var body: some Scene {
        WindowGroup {

            TabView {
                ContentView().tabItem {
                    Image(systemName: "bus")
                    Text("bus")
                }
                FormView().tabItem {
                    Image(systemName: "ticket").tint(.indigo)
                    Text("ticket")
                }
            }
            .accentColor(.indigo)
        }

    }
}
