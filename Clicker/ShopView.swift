//
//  ShopView.swift
//  Clicker
//
//  Created by Рамазан Рахимов on 01.04.2024.
//

import Foundation
import SwiftUI

struct Skin: Identifiable {
    let id = UUID()
    let name: String
    let cost: Int
    let imageName: String
    let characterType: String // Добавлено новое поле
}



class ShopViewModel: ObservableObject {
    @Published var skins: [Skin] = [
        Skin(name: "Стандартный человек", cost: 0, imageName: "man_1_sleep", characterType: "Human"),
        Skin(name: "Стандартная сова", cost: 200, imageName: "owl_1_sleep", characterType: "Owl"),
        Skin(name: "Звездная ночь", cost: 300, imageName: "horse_2_sleep", characterType: "Pony"),
        Skin(name: "Милая пони", cost: 200, imageName: "horse_1_sleep", characterType: "Pony"),
        Skin(name: "Легендарная пони", cost: 2100, imageName: "horse_3_sleep", characterType: "Pony"),
        Skin(name: "Добрый человек", cost: 200, imageName: "man_2_sleep", characterType: "Human"),
        Skin(name: "Няшная сова", cost: 800, imageName: "owl_2_sleep", characterType: "Owl"),
        Skin(name: "Легендарная сова", cost: 2100, imageName: "owl_3_sleep", characterType: "Owl")
    ]
}



struct ShopView: View {
    @ObservedObject var viewModel = ShopViewModel()
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var characterManager: CharacterManager
    
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            List(viewModel.skins) { skin in
                HStack {
                    Image(skin.imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .padding(.trailing, 25)
                        .padding(.leading, 15)
                    
                    VStack(alignment: .leading) {
                        Text(skin.name)
                            .font(.headline)
                        Text("\(skin.cost) очков")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    if appState.isSkinOwned(skin) {
                        let isCurrentSkin = appState.currentSkins[skin.characterType] == skin.imageName
                        Button(isCurrentSkin ? "Выбрано" : "Выбрать") {
                            if !isCurrentSkin {
                                print("Выбор скина: \(skin.name)")
                                appState.updateSkin(for: skin.characterType, to: skin.imageName)
                                alertMessage = "Скин '\(skin.name)' теперь активен."
                                showingAlert = true
                            }
                        }
                    }
                    else {
                        Button("Купить") {
                            if appState.allScore >= skin.cost {
                                appState.allScore -= skin.cost
                                appState.buySkin(skin)
                                alertMessage = "Скин '\(skin.name)' успешно приобретен!"
                                showingAlert = true
                            } else {
                                alertMessage = "Недостаточно очков для покупки скина '\(skin.name)'."
                                showingAlert = true
                            }
                        }
                    }
                    Spacer()
                }
                .padding(.leading, -20)
            }
            .navigationBarTitle(Text("Магазин"), displayMode: .inline)
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Уведомление"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
}

struct ShopView_Previews: PreviewProvider {
    static var previews: some View {
        let appState = AppState()
        let characterManager = CharacterManager(appState: appState)  // Предполагаем, что у CharacterManager есть такой инициализатор
        
        return ShopView()
            .environmentObject(appState)
            .environmentObject(characterManager)
    }
}
