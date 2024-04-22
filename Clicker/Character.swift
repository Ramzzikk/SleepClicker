//
//  Character.swift
//  Clicker
//
//  Created by Рамазан Рахимов on 30.03.2024.
//

import Foundation
import SwiftUI

// Класс Character с ObservableObject для отслеживания изменений состояния
class Character: ObservableObject, Identifiable {
    var appState: AppState
    var characterType: String // Добавьте эту строку
    let id = UUID()
    @Published var lives: Int = 3
    var successfulWakeUps = 0
    var wakeUpTime: Date?
    var currentGameTime: Date?
    var lastAwakeTime: Date? // Время последнего пробуждения
    @Published var sleepImageName: String
    @Published var awakeImageName: String
    @Published var isAwake: Bool = false
    var onWakeUp: (() -> Void)? // Замыкание, вызываемое при пробуждении
    weak var manager: CharacterManager? // Ссылка на менеджера
    @Published var currentSkin: Skin
    
    init(characterType: String, sleepImageName: String, awakeImageName: String, lives: Int, currentSkin: Skin, manager: CharacterManager? = nil, appState: AppState) {
        self.appState = appState
        self.sleepImageName = sleepImageName
        self.awakeImageName = awakeImageName
        self.lives = lives
        self.currentSkin = currentSkin
        self.manager = manager
        self.characterType = characterType
        
    }
    
    // Функция для смены скина
    // Метод для применения нового скина персонажу
    func applySkin(skin: Skin) {
        // Это будет переопределено в подклассах
        fatalError("This method should be overridden")
    }
    
    
    
    
    func wakeUp(currentGameTime: Date) {
        self.isAwake = true
        lastAwakeTime = currentGameTime
        successfulWakeUps += 1 // Увеличиваем счетчик успешных пробуждений

        if successfulWakeUps % 3 == 0 { // Каждые три успешных пробуждения
            if lives < 3 { // Проверяем, не достигли ли мы максимального количества жизней
                lives += 1 // Восстанавливаем одну жизнь
            }
        }

        self.objectWillChange.send()
        onWakeUp?()
        manager?.replaceCharacter(self, currentGameTime: currentGameTime, appState: self.appState)
    }

    
    
    func loseLife() {
        if lives > 0 {
            lives -= 1
            if lives == 0 {
                // Оповещаем GameView о необходимости показать GameOverView
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: NSNotification.Name("GameOver"), object: nil)
                }
            }
        }
    }

    
    func updateWakeUpTime(currentGameTime: Date) {
        self.wakeUpTime = Character.randomWakeUpTime(from: currentGameTime)
        self.objectWillChange.send() // Оповещаем о изменении
    }
    
    static func randomWakeUpTime(from currentTime: Date) -> Date {
        let randomMinutes = Int.random(in: 30...120)
        return Calendar.current.date(byAdding: .minute, value: randomMinutes, to: currentTime)!
    }}


// Отдельный вид для персонажа, позволяющий взаимодействовать с его состоянием
struct CharacterView: View {
    @ObservedObject var character: Character
    var characterManager: CharacterManager
    let currentTime: Date // Текущее игровое время
    var addScore: (Int) -> Void // Функция для добавления очков
    
    var body: some View {
        VStack {
            Image(character.isAwake ? character.awakeImageName : character.sleepImageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 60, height: 60)
            // В CharacterView
                .onTapGesture {
                    let wakeUpTime = character.wakeUpTime ?? currentTime
                    let wakeUpTimeDifference = Calendar.current.dateComponents([.minute], from: currentTime, to: wakeUpTime).minute ?? 0
                    
                    // В CharacterView, внутри .onTapGesture
                    if abs(wakeUpTimeDifference) <= 20 && !character.isAwake {
                        // Если персонаж разбужен вовремя
                        character.wakeUp(currentGameTime: currentTime) // Теперь передаем currentTime
                        addScore(20)
                    } else {
                        // Если персонаж не разбужен вовремя
                        character.loseLife()
                        character.updateWakeUpTime(currentGameTime: currentTime) // Обновляем время пробуждения
                    }
                    
                }
            HStack {
                ForEach(0..<3, id: \.self) { index in
                    Image(systemName: index < character.lives ? "heart.fill" : "heart")
                        .foregroundColor(.red)
                }
            }
            
            if let wakeUpTime = character.wakeUpTime {
                Text(wakeUpTime, formatter: dateFormatter)
            } else {
                Text("Error")
            }
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
}

extension Character {
    // Обновление времени пробуждения с передачей текущего игрового времени
    func refreshWakeUpTime(currentGameTime: Date) {
        let newWakeUpTime = Character.randomWakeUpTime(from: currentGameTime)
        print("Новое время пробуждения: \(newWakeUpTime)")
        wakeUpTime = newWakeUpTime
    }
}

// Пример начального скина для Human
let defaultHumanSkin = Skin(name: "Стандартный человек", cost: 0, imageName: "man_1", characterType: "Human")

// Пример начального скина для Pony
let defaultPonySkin = Skin(name: "Милая пони", cost: 0, imageName: "horse_1", characterType: "Pony")

// Пример начального скина для Owl
let defaultOwlSkin = Skin(name: "Мудрая сова", cost: 0, imageName: "owl_1", characterType: "Owl")

class Pony: Character {
    init(lives: Int, manager: CharacterManager, appState: AppState) {
        let skinNameBase = appState.currentSkins["Pony"] ?? "horse_1"
        let skinName = skinNameBase.contains("_sleep") ? skinNameBase : skinNameBase + "_sleep"
        let skin = Skin(name: skinName, cost: 0, imageName: skinName, characterType: "Pony")
        super.init(characterType: "Pony", sleepImageName: skin.imageName, awakeImageName: skin.imageName.replacingOccurrences(of: "_sleep", with: "_awake"), lives: lives, currentSkin: skin, manager: manager, appState: appState)
    }
}

class Human: Character {
    init(lives: Int, manager: CharacterManager, appState: AppState) {
        let skinNameBase = appState.currentSkins["Human"] ?? "man_1"
        let skinName = skinNameBase.contains("_sleep") ? skinNameBase : skinNameBase + "_sleep"
        let skin = Skin(name: skinName, cost: 0, imageName: skinName, characterType: "Human")
        super.init(characterType: "Human", sleepImageName: skin.imageName, awakeImageName: skin.imageName.replacingOccurrences(of: "_sleep", with: "_awake"), lives: lives, currentSkin: skin, manager: manager, appState: appState)
    }
}

class Owl: Character {
    init(lives: Int, manager: CharacterManager, appState: AppState) {
        let baseSkinName = appState.currentSkins["Owl"] ?? "owl_1"
        let skinName = baseSkinName + (baseSkinName.contains("_sleep") ? "" : "_sleep")
        let skin = Skin(name: skinName, cost: 0, imageName: skinName, characterType: "Owl")
        super.init(characterType: "Owl", sleepImageName: skin.imageName, awakeImageName: skin.imageName.replacingOccurrences(of: "_sleep", with: "_awake"), lives: lives, currentSkin: skin, manager: manager, appState: appState)
    }
}



