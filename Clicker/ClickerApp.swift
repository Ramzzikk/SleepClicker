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
    @StateObject var characterManager: CharacterManager
    
    init() {
        let initialState = AppState()
        _appState = StateObject(wrappedValue: initialState)
        _characterManager = StateObject(wrappedValue: CharacterManager(appState: initialState))
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(characterManager)
                .environmentObject(navigationManager)
        }
    }
}
