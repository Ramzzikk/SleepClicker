//
//  MainView.swift
//  Clicker
//
//  Created by Рамазан Рахимов on 25.03.2024.
//

import SwiftUI
import AVFoundation

struct DesignConstants {
    static let buttonHeight: CGFloat = 30
    static let buttonWidth: CGFloat = 150
    static let cornerRadius: CGFloat = 10
    static let opacity: Double = 0.7
    
    struct Colors {
        static let easy = Color.green.opacity(opacity)
        static let medium = Color.yellow.opacity(opacity)
        static let hard = Color.red.opacity(opacity)
        static let tutorial = Color.blue.opacity(opacity)
        static let shop = Color.orange.opacity(opacity)
    }
}

struct MainMenuView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var navigationManager: NavigationManager
    
    @State private var showingShop = false
    @State private var showingTutorial = false
    
    init() {
        AudioManager.shared.playBackgroundMusic(named: "02 Whirling-In-Rags, 8 AM")
    }
    
    var body: some View {
        VStack {
            Text("Будильник")
                .font(.largeTitle)
                .padding()
            
            Text("Общий счет: \(appState.allScore)")
                .font(.title2)
                .padding()
            
            Spacer()
            
            DifficultyButton(title: "Легкий", color: DesignConstants.Colors.easy) {
                navigationManager.currentDifficulty = .easy
                navigationManager.currentScreen = .gameView(difficulty: .easy)
            }

            DifficultyButton(title: "Средний", color: DesignConstants.Colors.medium) {
                navigationManager.currentDifficulty = .medium
                navigationManager.currentScreen = .gameView(difficulty: .medium)
            }

            DifficultyButton(title: "Сложный", color: DesignConstants.Colors.hard) {
                navigationManager.currentDifficulty = .hard
                navigationManager.currentScreen = .gameView(difficulty: .hard)
            }

            
            Spacer()
            
            HStack(spacing: 20) {
                FeatureButton(label: "Обучение", icon: "lightbulb", color: DesignConstants.Colors.tutorial) {
                    showingTutorial = true
                }
                
                FeatureButton(label: "Магазин", icon: "cart", color: DesignConstants.Colors.shop) {
                    showingShop = true
                }
            }.padding()
        }
        .sheet(isPresented: $showingTutorial) { TutorialView() }
        .sheet(isPresented: $showingShop) { ShopView().environmentObject(appState) }
    }
}

struct DifficultyButton: View {
    var title: String
    var color: Color
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .frame(width: DesignConstants.buttonWidth, height: DesignConstants.buttonHeight)
                .contentShape(Rectangle())
        }
        .padding()
        .background(color)
        .foregroundColor(.white)
        .cornerRadius(DesignConstants.cornerRadius)
    }
}

struct FeatureButton: View {
    var label: String
    var icon: String
    var color: Color
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Label(label, systemImage: icon)
                .frame(width: DesignConstants.buttonWidth)
        }
        .padding()
        .background(color)
        .foregroundColor(.white)
        .cornerRadius(DesignConstants.cornerRadius)
    }
}
