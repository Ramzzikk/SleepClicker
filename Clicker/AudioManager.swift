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
    private(set) var isMuted: Bool = false
    
    var isPlaying: Bool {
        return audioPlayer?.isPlaying ?? false
    }
    
    func playBackgroundMusic(named musicName: String) {
        guard !isPlaying else { return }  // Не начинать играть, если уже играет
        
        guard let url = Bundle.main.url(forResource: musicName, withExtension: "mp3") else {
            print("Failed to find \(musicName).mp3")
            return
        }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1
            audioPlayer?.volume = isMuted ? 0.0 : 0.4  // Установить громкость в зависимости от состояния mute
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("Error playing music: \(error.localizedDescription)")
        }
    }
    
    func toggleMute() {
        isMuted = !isMuted
        audioPlayer?.volume = isMuted ? 0.0 : 0.4
    }
}
