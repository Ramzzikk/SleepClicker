////
////  Shop.swift
////  Clicker
////
////  Created by Рамазан Рахимов on 31.03.2024.
////
//
//import Foundation
//import SwiftUI
//
//// Элемент магазина, представляющий товар
//struct ShopItem: Identifiable {
//    var id = UUID()
//    let name: String
//    let cost: Int
//    let type: ItemType
//    let imageName: String
//
//    enum ItemType {
//        case characterSkin, background
//    }
//}
//
//// ViewModel для магазина, управляет логикой покупки
//class ShopViewModel: ObservableObject {
//    @Published var items: [ShopItem] = [
//        ShopItem(name: "Кожа Героя 1", cost: 100, type: .characterSkin, imageName: "man_skin_1"),
//        ShopItem(name: "Кожа Пони 1", cost: 150, type: .characterSkin, imageName: "horse_skin_1"),
//        ShopItem(name: "Фон Мечты", cost: 200, type: .background, imageName: "dreamBackground")
//    ]
//    
//    var appState: AppState
//    
//    init(appState: AppState) {
//        self.appState = appState
//    }
//    
//    // Функция покупки товара
//    func purchase(item: ShopItem) {
//        guard appState.allScore >= item.cost else { return }
//        
//        appState.allScore -= item.cost
//        
//        switch item.type {
//        case .characterSkin:
//            // Обновление скина в AppState
//            if item.imageName.contains("man") {
//                appState.activeSkins["Human"] = item.imageName
//            } else if item.imageName.contains("horse") {
//                appState.activeSkins["Pony"] = item.imageName
//            }
//            appState.saveActiveSkins() // Сохраняем изменения в UserDefaults
//        default:
//            // Пока не обрабатываем другие типы товаров, как например .background
//            break
//        }
//    }
//
//    
//    // Представление магазина
//    
//}
