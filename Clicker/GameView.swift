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
    
    let difficulty: Difficulty
    @EnvironmentObject var navigationManager: NavigationManager
    var onExit: (() -> Void)?
    
    @StateObject private var characterManager = CharacterManager()
    
    @State private var gameDuration: Int = 0 // Длительность игры в минутах
    @State private var timeMultiplier: Double = 1.0 // Коэффициент ускорения времени
    
    @State private var resetKey = UUID()
    @State private var showGameOver = false
    @State private var gameCurrentTime = Date()
    @State private var gameSpeed = 2
    @State private var score = 0
    @State private var isActive = true
    @State private var characters: [Character] = []
    
    @EnvironmentObject var appState: AppState
    
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
            
            // Кнопка "Сдаться"
            Button("Сдаться") {
                let awakenedCharacters = characters.filter { $0.lives > 0 }.count
                navigationManager.currentScreen = .gameOver(totalScore: score, awakenedCharacters: awakenedCharacters)
            }
            .padding()
            .background(Color.red)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .onAppear {
            setupInitialGameTime()
            // Вызываем метод для генерации персонажей, не ожидая от него возвращаемого значения
            characterManager.generateCharacters(for: difficulty, currentGameTime: gameCurrentTime)
            // Теперь characters будут доступны напрямую из characterManager
            characters = characterManager.characters
        }
        
        
        
        .onAppear {
            NotificationCenter.default.addObserver(forName: NSNotification.Name("GameOver"), object: nil, queue: .main) { _ in
                showGameOver = true
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            isActive = false
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            isActive = true
        }
        .onReceive(gameTimer) { _ in
            if isActive {
                updateGameTime()
            }
        }
        .fullScreenCover(isPresented: $showGameOver) {
            GameOverView(
                
                totalScore: score,
                awakenedCharacters: characters.filter { $0.lives > 0 }.count, // Пример подсчета разбуженных персонажей
                playAgainAction: {
                    resetGame()
                },
                goToMainMenuAction: {
                }
            )
        }
    }
    
    func resetGame() {
        showGameOver = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { // Добавляем небольшую задержку
            self.resetKey = UUID()
            self.navigationManager.currentScreen = .gameView(self.difficulty)
        }
    }

    
    func setupInitialGameTime() {
        // установка времени на 5 утра
        let now = Date()
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        var components = calendar.dateComponents([.year, .month, .day], from: now)
        components.hour = 5
        components.minute = 0
        if let startGameTime = calendar.date(from: components) {
            gameCurrentTime = startGameTime
        }
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
