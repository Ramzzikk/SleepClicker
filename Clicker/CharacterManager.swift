//
//  CharacterManager.swift
//  Clicker
//
//  Created by Рамазан Рахимов on 30.03.2024.
//

import Foundation

class CharacterManager: ObservableObject {
    
    @Published var characters: [Character] = []
    var appState: AppState?
    init(appState: AppState) {
        self.appState = appState
        print("CharacterManager инициализирован с appState: \(appState)")

    }
    func createRandomCharacter(lives: Int, currentGameTime: Date, appState: AppState) -> Character {
        print("Создание случайного персонажа")
        let randomNumber = Int.random(in: 0..<3)
        switch randomNumber {
        case 0:
            return Human(lives: lives, manager: self, appState: appState)
        case 1:
            return Pony(lives: lives, manager: self, appState: appState)
        case 2:
            return Owl(lives: lives, manager: self, appState: appState)
        default:
            fatalError("Unsupported index for creating a character")
        }
    }



    
    
    func generateCharacters(for difficulty: Difficulty, currentGameTime: Date, appState: AppState) {
        self.characters.removeAll() // Очищаем текущий список персонажей
        print("Генерация персонажей для уровня сложности: \(difficulty)")
        let numberOfCharacters: Int = {
            switch difficulty {
            case .easy: return 4
            case .medium: return 8
            case .hard: return 12
            }
        }()
        
        for _ in 0..<numberOfCharacters {
            let character = createRandomCharacter(lives: 3, currentGameTime: currentGameTime, appState: appState)
            character.updateWakeUpTime(currentGameTime: currentGameTime)
            self.characters.append(character)
        }
    }


    
    func replaceCharacter(_ character: Character, currentGameTime: Date, appState: AppState) {
        print("Замена персонажа с ID: \(character.id)")
        
        guard let index = characters.firstIndex(where: { $0.id == character.id }) else {
            print("Персонаж для замены не найден")
            return
        }

        let currentLives = character.lives  // Сохраняем текущее количество жизней
        let successfulWakeUps = character.successfulWakeUps // Сохраняем количество успешных пробуждений

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            var newCharacters = self.characters
            let newCharacter = self.createRandomCharacter(lives: currentLives, currentGameTime: currentGameTime, appState: appState)
            newCharacter.updateWakeUpTime(currentGameTime: currentGameTime)
            newCharacter.successfulWakeUps = successfulWakeUps // Передаем значение успешных пробуждений новому персонажу
            newCharacters[index] = newCharacter
            self.characters = newCharacters
        }
    }

    func resetCharacters(for difficulty: Difficulty, currentGameTime: Date, appState: AppState) {
        characters.removeAll() // Очищаем текущий список персонажей
        generateCharacters(for: difficulty, currentGameTime: currentGameTime, appState: appState)
    }

    func updateCharactersSkin(appState: AppState) {
        for character in characters {
            // Определяем имя скина на основе текущего скина персонажа или используем "default".
            let skinName = appState.currentSkins[character.characterType] ?? "default_\(character.characterType)"
            // Создаем скин с использованием имени и типа персонажа.
            let skin = Skin(name: skinName, cost: 0, imageName: skinName, characterType: character.characterType)
            // Применяем новый скин к персонажу.
            character.applySkin(skin: skin)
        }
    }



}
