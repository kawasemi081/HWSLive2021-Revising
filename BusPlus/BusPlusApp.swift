//
//  BusPlusApp.swift
//  BusPlus
//
//  Created by misono on 2021/08/05.
//

import SwiftUI

@main
struct BusPlusApp: App {
    @StateObject private var userData = UserData()
    
    var  isDisplay = true
    var body: some Scene {
        WindowGroup {

            TabView {
                ContentView().tabItem {
                    Label("bus", systemImage: "bus")
                }
                MyTicketView().tabItem {
                    Label("My Ticket", systemImage: "qrcode")
                }
                .badge(userData.identifier.isEmpty ? "!" : nil)
            }
            .environmentObject(userData)
            .accentColor(.indigo)
        }

    }
}
