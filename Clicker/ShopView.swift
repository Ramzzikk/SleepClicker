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
}


class ShopViewModel: ObservableObject {
    @Published var skins: [Skin] = [
        Skin(name: "Стандартный человек", cost: 100, imageName: "man_1_1"),
        Skin(name: "Милая пони", cost: 200, imageName: "horse_1")
    ]
}


struct ShopView: View {
    @ObservedObject var viewModel = ShopViewModel()

    var body: some View {
        NavigationView {
            List(viewModel.skins) { skin in
                HStack {
                    
                    Image(skin.imageName) // Изображение товара
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80) // Размер изображения
                        .padding(.trailing, 25
                        )
                        .padding(.leading, 15)// Отступ справа от изображения
                    
                    // Текстовая информация по левому краю от центра
                    VStack(alignment: .leading) {
                        Text(skin.name) // Название скина
                            .font(.headline)
                        Text("\(skin.cost) очков") // Стоимость скина
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading) // Выравнивание текста к левому краю

                    Spacer() // Спейсер, чтобы выровнять все элементы в HStack
                }
                .padding(.leading, -20) // Дополнительный отступ слева, если нужно сдвинуть блок ближе к середине
            }
            .navigationBarTitle(Text("Магазин"), displayMode: .inline)
        }
    }
}


#Preview {
    ShopView()
}
