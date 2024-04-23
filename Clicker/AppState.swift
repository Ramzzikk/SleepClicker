//
//  AppState.swift
//  Clicker
//
//  Created by Рамазан Рахимов on 31.03.2024.
//

import Foundation

class AppState: ObservableObject {
    // MARK: - Published Properties
    @Published var allScore: Int = 0 {
        didSet {
            saveAllScore()
        }
    }
    
    @Published var currentSkins: [String: String] = ["Human": "man_1", "Pony": "horse_1", "Owl": "owl_1"] {
        didSet {
            saveCurrentSkins()
        }
    }
    
    @Published var ownedSkins: [String] = []
    
    // MARK: - Managers
    var characterManager: CharacterManager?
    
    // MARK: - Initialization
    init() {
        loadAllScore()
        loadCurrentSkins()
        ownedSkins = UserDefaults.standard.stringArray(forKey: "OwnedSkins") ?? []
    }
    
    // MARK: - Persistence Handling
    private func saveAllScore() {
        UserDefaults.standard.set(allScore, forKey: "AllScore")
    }
    
    private func loadAllScore() {
        allScore = UserDefaults.standard.integer(forKey: "AllScore")
    }
    
    private func saveCurrentSkins() {
        UserDefaults.standard.set(currentSkins, forKey: "CurrentSkins")
    }
    
    private func loadCurrentSkins() {
        if let skins = UserDefaults.standard.dictionary(forKey: "CurrentSkins") as? [String: String] {
            currentSkins = skins
        }
    }
    
    // MARK: - Skin Management
    func updateSkin(for characterType: String, to newSkinBaseName: String) {
        print("Попытка обновить скин для \(characterType) на \(newSkinBaseName)")
        currentSkins[characterType] = newSkinBaseName
        saveCurrentSkins()
        characterManager?.updateCharactersSkin(appState: self)
    }
    
    func buySkin(_ skin: Skin) {
        ownedSkins.append(skin.imageName)
        UserDefaults.standard.set(ownedSkins, forKey: "OwnedSkins")
    }
    
    func isSkinOwned(_ skin: Skin) -> Bool {
        return ownedSkins.contains(skin.imageName)
    }
}
