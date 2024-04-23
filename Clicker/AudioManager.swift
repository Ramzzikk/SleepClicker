//
//  AudioManager.swift
//  Clicker
//
//  Created by Рамазан Рахимов on 02.04.2024.
//

import Foundation
import AVFoundation

// MARK: - AudioManager

class AudioManager {
    static let shared = AudioManager()  // Singleton instance
    
    // MARK: - Private Properties
    private var audioPlayer: AVAudioPlayer?

    // MARK: - Public Methods
    
    /// Plays background music infinitely from the provided file name.
    func playBackgroundMusic(named musicName: String) {
        guard let url = Bundle.main.url(forResource: musicName, withExtension: "mp3") else {
            print("Failed to find \(musicName).mp3")
            return
        }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1 // Loop indefinitely
            audioPlayer?.volume = 0.4
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("Error playing music: \(error.localizedDescription)")
        }
    }

    /// Stops the currently playing background music.
    func stopBackgroundMusic() {
        audioPlayer?.stop()
    }
}
