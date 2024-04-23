//
//  TutorialView.swift
//  Clicker
//
//  Created by Рамазан Рахимов on 01.04.2024.
//

import SwiftUI

struct TutorialView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Как играть")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top)

                    Group {
                        Text("Основная задача - **разбудить персонажа**. Нажмите на персонажа в нужный момент, чтобы он проснулся и вы заработали очки.")
                            .font(.title3)
                            .fontWeight(.medium)
                            .padding(.bottom)

                        Text("Время пробуждения:")
                            .font(.headline)
                            .underline()
                        Text("Каждый персонаж имеет своё уникальное время пробуждения. Если нажать в интервале ±20 минут от заданного времени, пробуждение будет успешным.")
                            .font(.subheadline)

                        Text("Игровое время:")
                            .font(.headline)
                            .underline()
                            .padding(.top)
                        Text("В игре используется ускоренное время. Игровое время и время пробуждения обновляется в реальном времени на экране.")
                            .font(.subheadline)
                    }
                    .padding(.vertical)

                    Group {
                        Text("Жизни персонажа:")
                            .font(.headline)
                            .underline()
                        Text("Каждый персонаж имеет три жизни. Потеря всех жизней приводит к смерти персонажа. Успешное пробуждение три раза подряд восстанавливает одну жизнь.")
                            .font(.subheadline)
                            .padding(.bottom)

                        Text("Очки:")
                            .font(.headline)
                            .underline()
                        Text("За каждое успешное пробуждение начисляется 20 очков. Очки можно тратить в магазине на покупку новых скинов для персонажей.")
                            .font(.subheadline)

                        Text("Магазин:")
                            .font(.headline)
                            .underline()
                            .padding(.top)
                        Text("В магазине доступен выбор скинов, каждый из которых изменяет внешний вид персонажей. Скины покупаются за очки, заработанные в игре.")
                            .font(.subheadline)
                    }
                    .padding(.vertical)

                    Spacer()
                }
                .padding(.horizontal)
            }
            .navigationBarTitle("Обучение", displayMode: .inline)
        }
    }
}
