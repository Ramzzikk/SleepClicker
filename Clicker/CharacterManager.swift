//
//  CharacterManager.swift
//  Clicker
//
//  Created by Рамазан Рахимов on 30.03.2024.
//

import Foundation

class CharacterManager: ObservableObject {
    @Published var characters: [Character] = []
    
    func createRandomCharacter(lives: Int, currentGameTime: Date) -> Character {
        let randomNumber = Int.random(in: 0..<3) // Генерируем случайное число от 0 до 2
        switch randomNumber {
        case 0:
            return Human(lives: lives, manager: self)
        case 1:
            return Pony(lives: lives, manager: self)
        case 2:
            return Owl(lives: lives, manager: self)
        default:
            fatalError("Неподдерживаемый индекс для создания персонажа")
        }
    }
    
    
    
    func generateCharacters(for difficulty: Difficulty, currentGameTime: Date) {
        self.characters.removeAll() // Очищаем текущий список персонажей
        let numberOfCharacters: Int = {
            switch difficulty {
            case .easy: return 4
            case .medium: return 8
            case .hard: return 12
            }
        }()
        
        for _ in 0..<numberOfCharacters {
            let character = createRandomCharacter(lives: 3, currentGameTime: currentGameTime)
            character.updateWakeUpTime(currentGameTime: currentGameTime)
            self.characters.append(character)
        }
    }
    
    func replaceCharacter(_ character: Character, currentGameTime: Date) {
        guard let index = characters.firstIndex(where: { $0.id == character.id }) else { return }
        let currentLives = character.lives
        let successfulWakeUps = character.successfulWakeUps // Сохраняем значение успешных пробуждений

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            var newCharacters = self.characters
            let newCharacter = self.createRandomCharacter(lives: currentLives, currentGameTime: currentGameTime)
            newCharacter.updateWakeUpTime(currentGameTime: currentGameTime)
            newCharacter.successfulWakeUps = successfulWakeUps // Передаем значение успешных пробуждений новому персонажу
            newCharacters[index] = newCharacter
            self.characters = newCharacters
        }
    }
}
