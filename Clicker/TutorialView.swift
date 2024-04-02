//
//  TutorialView.swift
//  Clicker
//
//  Created by Рамазан Рахимов on 01.04.2024.
//

import Foundation
import SwiftUI
struct TutorialView: View {
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Как играть")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Жмите на персонажа, чтобы его разбудить. Когда персонаж просыпается, вы зарабатываете очки. Со временем игра ускоряется!")
                    .font(.title)
                
                Spacer()
            }
            .padding()
            .navigationBarTitle("Обучение", displayMode: .inline)
        }
    }
}
