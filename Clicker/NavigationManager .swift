//
//  NavigationManager .swift
//  Clicker
//
//  Created by Рамазан Рахимов on 31.03.2024.
//

import Foundation

class NavigationManager: ObservableObject {
    enum Screen {
        case mainMenu
        case gameView(Difficulty)
        case gameOver(totalScore: Int, awakenedCharacters: Int)
    }
    
    @Published var currentScreen: Screen = .mainMenu {
            didSet {
                print("Смена экрана на: \(currentScreen)")
            }
        }
}
