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
                    Label("bus", systemImage: "bus")
                }
                MyTicketView().tabItem {
                    Label("My Ticket", systemImage: "qrcode")
                }
            }
            .accentColor(.indigo)
        }

    }
}
