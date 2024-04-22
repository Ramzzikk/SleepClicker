//
//  GameView.swift
//  Clicker
//
//  Created by Рамазан Рахимов on 25.03.2024.
//

import Foundation
import SwiftUI

enum Difficulty {
    case easy, medium, hard
}

private let columns = [GridItem(.adaptive(minimum: 80))]

struct GameView: View {
    @State private var characterCheckTimer = Timer.publish(every: 7, on: .main, in: .common).autoconnect()
    @State private var viewKey = UUID()
    @State private var isGameOver = false
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var characterManager: CharacterManager  
    let difficulty: Difficulty
    @EnvironmentObject var navigationManager: NavigationManager
    var onExit: (() -> Void)?
    
    
    @State private var gameDuration: Int = 0 // Длительность игры в минутах
    @State private var timeMultiplier: Double = 1.0 // Коэффициент ускорения времени
    
    @State private var resetKey = UUID()
    @State private var showGameOver = false
    @State private var gameCurrentTime = Date()
    @State private var gameSpeed = 2
    @State private var score = 0
    @State private var isActive = true
    @State private var characters: [Character] = []
    
    
    let gameTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    
    var body: some View {
        VStack {
            // Кнопки управления скоростью игры
            HStack {
                SpeedButton(title: "1x", isSelected: gameSpeed == 1) { gameSpeed = 1 }
                SpeedButton(title: "2x", isSelected: gameSpeed == 2) { gameSpeed = 2 }
                SpeedButton(title: "5x", isSelected: gameSpeed == 5) { gameSpeed = 5 }
                Spacer()
                Text("Очки: \(score)")
            }
            .padding()
            
            // Отображение текущего игрового времени
            Text("Игровое время: \(gameCurrentTime, formatter: gameDateFormatter)")
                .font(.title3)
                .padding()
                .bold()
                .italic()
                .underline(color: .blue)
            
            Spacer()
            Text("Скорость времени: \(String(format: "%.1f", timeMultiplier))x")
                .padding()
            Spacer()
            
            // Персонажи
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(characters) { character in
                    CharacterView(character: character, characterManager: self.characterManager, currentTime: gameCurrentTime, addScore: { points in
                        score += points*Int(timeMultiplier) // Обновляем общий счёт игры
                    })
                    .frame(width: 100, height: 100)
                }
            }
            .padding(.horizontal)
            .onReceive(characterManager.$characters) { updatedCharacters in
                self.characters = updatedCharacters
            }
            
            
            Spacer()
            
            Button("Сдаться") {
                isGameOver = true
                navigationManager.currentScreen = .gameOver(totalScore: score)
            }




            .padding()
            .background(Color.red)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .onAppear {
            let initialTime = setupInitialGameTime()
            gameCurrentTime = initialTime
            isGameOver = false // Сброс при входе в игровой экран
            characterManager.generateCharacters(for: difficulty, currentGameTime: initialTime, appState: appState)
            characters = characterManager.characters
        }



        
        
        
        .onAppear {
            NotificationCenter.default.addObserver(forName: NSNotification.Name("GameOver"), object: nil, queue: .main) { _ in
                showGameOver = true
                isGameOver = true  // Установка флага окончания игры
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            isActive = false
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            isActive = true
        }
        .onReceive(gameTimer) { _ in
            if isActive && !isGameOver {
                updateGameTime()
            }
        }
        .onReceive(characterCheckTimer) { _ in
            if isActive && !isGameOver {
                checkForUnawakenedCharacters()
            }
        }

        .fullScreenCover(isPresented: $showGameOver) {
            GameOverView(
                totalScore: score,
                playAgainAction: resetGame,
                goToMainMenuAction: endGame
            )

        }



    }
    func checkForUnawakenedCharacters() {
        let now = gameCurrentTime  // Используем текущее игровое время
        let twoHours = 2 * 3600.0 // Две часа в секундах

        for index in characters.indices {
            if let wakeUpTime = characters[index].wakeUpTime, !characters[index].isAwake {
                let timeSinceWakeUp = now.timeIntervalSince(wakeUpTime)
                if timeSinceWakeUp > twoHours {
                    print("Два часа прошли для персонажа на позиции \(index), теряет жизнь.")
                    characters[index].loseLife()
                    replaceCharacter(at: index)
                }
            }
        }
    }

    func endGame() {
        isGameOver = true
        showGameOver = false
        navigationManager.currentScreen = .mainMenu
    }


    func resetGame() {
        showGameOver = false
        gameDuration = 0
        score = 0
        timeMultiplier = 1.0
        isGameOver = false  // Ensure game over is reset
        gameCurrentTime = setupInitialGameTime()  // Reset game time

        // Reset characters
        characterManager.resetCharacters(for: difficulty, currentGameTime: gameCurrentTime, appState: appState)
        characters = characterManager.characters

        viewKey = UUID()
    }



    func resetCharactersAndGameSettings() {
        let currentTime = setupInitialGameTime() // Получаем начальное время для новой игры
        characterManager.resetCharacters(for: difficulty, currentGameTime: currentTime, appState: appState)
    }


    func replaceCharacter(at index: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            let currentCharacter = self.characters[index]
            let newCharacter = self.characterManager.createRandomCharacter(lives: currentCharacter.lives, currentGameTime: self.gameCurrentTime, appState: self.appState)

            // Устанавливаем новое время пробуждения так, чтобы оно было корректно интегрировано с текущим игровым временем
            newCharacter.wakeUpTime = self.gameCurrentTime.addingTimeInterval(Double.random(in: 30...120) * 60)

            // Важно сохранять число успешных пробуждений при замене персонажа
            newCharacter.successfulWakeUps = currentCharacter.successfulWakeUps
            
            self.characters[index] = newCharacter
            print("Персонаж на позиции \(index) заменен с новым временем пробуждения.")
        }
    }




    

    func setupInitialGameTime() -> Date {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current

        let now = Date()
        var components = calendar.dateComponents([.year, .month, .day], from: now)
        components.hour = 6
        components.minute = 0
        components.second = 0

        return calendar.date(from: components) ?? now
    }


    
    func updateGameTime() {
        let baseAdditionalSeconds: Int // Базовое добавление секунд к времени игры, в зависимости от выбранной скорости
        switch gameSpeed {
        case 1:
            baseAdditionalSeconds = 120 // 2 минуты в секундах
        case 2:
            baseAdditionalSeconds = 240 // 4 минуты в секундах
        case 5:
            baseAdditionalSeconds = 600 // 10 минут в секундах
        default:
            baseAdditionalSeconds = 120 // Значение по умолчанию
        }
        
        // Применяем коэффициент ускорения к базовому времени добавления
        let additionalSeconds = Int(Double(baseAdditionalSeconds) * timeMultiplier)
        
        // Обновляем текущее игровое время
        gameCurrentTime = Calendar.current.date(byAdding: .second, value: additionalSeconds, to: gameCurrentTime) ?? gameCurrentTime
        
        // Увеличиваем длительность игры
        gameDuration += additionalSeconds
        
        // Условие увеличения коэффициента ускорения, например, каждые 300 секунд (5 минут) игрового времени
        if gameDuration % 15 == 0 {
            timeMultiplier += 0.05 // Увеличиваем коэффициент на 5%
        }
        
    }
    
    @ViewBuilder
    func SpeedButton(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .fontWeight(isSelected ? .bold : .regular)
                .padding()
                .background(isSelected ? Color.blue : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(10)
                .scaleEffect(isSelected ? 1.2 : 1)
        }
    }
}

private var gameDateFormatter: DateFormatter {
    let formatter = DateFormatter()
    formatter.dateStyle = .none
    formatter.timeStyle = .short
    return formatter
}

//struct GameView_Previews: PreviewProvider {
//    static var previews: some View {
//        GameView(difficulty: .easy)
//    }
//}
