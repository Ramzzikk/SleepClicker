//
//  ClickerApp.swift
//  Clicker
//
//  Created by Рамазан Рахимов on 25.03.2024.
//

import SwiftUI

@main
struct ClickerApp: App {
    @StateObject var appState = AppState()
    @StateObject var navigationManager = NavigationManager()

    var body: some Scene {
        WindowGroup {
            ContentView() 
                .environmentObject(appState)
                .environmentObject(navigationManager)
        }
    }
}
