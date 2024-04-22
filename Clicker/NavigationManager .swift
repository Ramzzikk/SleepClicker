//
//  NavigationManager .swift
//  Clicker
//
//  Created by Рамазан Рахимов on 31.03.2024.
//

import Foundation

class NavigationManager: ObservableObject {
    @Published var currentDifficulty: Difficulty = .easy
    enum Screen {
        case mainMenu
        case gameView(difficulty: Difficulty)
        case gameOver(totalScore: Int)
    }

    
    @Published var currentScreen: Screen = .mainMenu
}
