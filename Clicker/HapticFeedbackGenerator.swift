//
//  HapticFeedbackGenerator.swift
//  Clicker
//
//  Created by Рамазан Рахимов on 31.03.2024.
//

import Foundation
import UIKit

class HapticFeedbackGenerator {
    static let shared = HapticFeedbackGenerator()
    
    private init() {} // Закрытый инициализатор предотвращает создание экземпляров извне
    
    func triggerImpactFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
    
    func triggerSelectionFeedback() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
    
    func triggerNotificationFeedback(type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }
}
