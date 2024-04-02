//
//  AudioManager.swift
//  Clicker
//
//  Created by Рамазан Рахимов on 02.04.2024.
//

import Foundation
import AVFoundation

class AudioManager {
    static let shared = AudioManager()
    private var audioPlayer: AVAudioPlayer?

    func playBackgroundMusic(named musicName: String) {
        guard let url = Bundle.main.url(forResource: musicName, withExtension: "mp3") else { return }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1 // Бесконечный цикл
            audioPlayer?.volume = 0.4
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("Ошибка воспроизведения музыки: \(error.localizedDescription)")
        }
    }

    func stopBackgroundMusic() {
        audioPlayer?.stop()
    }
}
