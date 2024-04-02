//
//  ContentView.swift
//  Clicker
//
//  Created by Рамазан Рахимов on 25.03.2024.
//

// ContentView.swift

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var appState: AppState // Убедитесь, что appState также доступен как EnvironmentObject
    
    var body: some View {
        switch navigationManager.currentScreen {
        case .mainMenu:
            MainMenuView()
                .environmentObject(appState) // Передайте AppState как EnvironmentObject
        case .gameView(let difficulty):
            GameView(difficulty: difficulty)
                .environmentObject(appState) // Передайте AppState как EnvironmentObject
        case .gameOver(let totalScore, let awakenedCharacters):
            GameOverView(totalScore: totalScore, awakenedCharacters: awakenedCharacters, playAgainAction: {
                
                navigationManager.currentScreen = .gameView(.easy) // Пример
            }, goToMainMenuAction: {
                navigationManager.currentScreen = .mainMenu
            })
            .environmentObject(appState) // Передайте AppState как EnvironmentObject
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(NavigationManager())
            .environmentObject(AppState()) // Добавьте AppState для предварительного просмотра
    }
}

