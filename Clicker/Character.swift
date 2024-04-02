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
    let id = UUID()
    @Published var lives: Int = 3
    var successfulWakeUps = 0
    var wakeUpTime: Date?
    var currentGameTime: Date?
    var lastAwakeTime: Date? // Время последнего пробуждения
    let sleepImageName: String
    let awakeImageName: String
    @Published var isAwake: Bool = false
    var onWakeUp: (() -> Void)? // Замыкание, вызываемое при пробуждении
    weak var manager: CharacterManager? // Добавляем ссылку на менеджера
    
    init(sleepImageName: String, awakeImageName: String, lives: Int, manager: CharacterManager? = nil) {
        self.sleepImageName = sleepImageName
        self.awakeImageName = awakeImageName
        self.lives = lives
        self.manager = manager
    }
    
    
    func wakeUp(currentGameTime: Date) {
        self.isAwake = true
        lastAwakeTime = currentGameTime
        successfulWakeUps += 1 // Увеличиваем счетчик успешных пробуждений
        self.objectWillChange.send()
        onWakeUp?()
        manager?.replaceCharacter(self, currentGameTime: currentGameTime)
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

class Human: Character {
    init(lives: Int, manager: CharacterManager? = nil) {
        super.init(sleepImageName: "man_1_1", awakeImageName: "man_1_2", lives: lives, manager: manager)
    }
}

class Pony: Character {
    init(lives: Int, manager: CharacterManager? = nil) {
        super.init(sleepImageName: "horse_1", awakeImageName: "horse_2", lives: lives, manager: manager)
    }
}

class Owl: Character {
    init(lives: Int, manager: CharacterManager? = nil) {
        super.init(sleepImageName: "owl_1_1", awakeImageName: "owl_1_2", lives: lives, manager: manager)
    }
}
