//
//  ContentView.swift
//  Clicker
//
//  Created by Рамазан Рахимов on 25.03.2024.
//

import SwiftUI

struct ContentView: View {
    // MARK: - Environment Objects
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var characterManager: CharacterManager

    // MARK: - Body
    var body: some View {
        switch navigationManager.currentScreen {
        case .mainMenu:
            MainMenuView()
                .environmentObject(appState)

        case .gameView(let difficulty):
            GameView(difficulty: difficulty)
                .environmentObject(characterManager)
                .environmentObject(appState)
                .environmentObject(navigationManager)

        case .gameOver(let totalScore):
            GameOverView(totalScore: totalScore, playAgainAction: {
                // Перезапуск игры с текущим выбранным уровнем сложности
                navigationManager.currentScreen = .gameView(difficulty: navigationManager.currentDifficulty)
            }, goToMainMenuAction: {
                navigationManager.currentScreen = .mainMenu
            })
            .environmentObject(appState)
        }
    }
}
