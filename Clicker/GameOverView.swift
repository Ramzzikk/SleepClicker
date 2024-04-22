import SwiftUI

struct GameOverView: View {
    let totalScore: Int
    var playAgainAction: () -> Void
    var goToMainMenuAction: () -> Void
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var navigationManager: NavigationManager
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Игра окончена!")
                .font(.largeTitle)
            Text("Итоговый счет: \(totalScore)")
            
            Button(action: {
                navigationManager.currentScreen = .gameView(difficulty: navigationManager.currentDifficulty)
                appState.allScore += totalScore
                playAgainAction()
            }) {
                Text("Играть снова")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(10)
            }
            
            Button(action: {
                appState.allScore += totalScore
                navigationManager.currentScreen = .mainMenu
            }) {
                Text("Главное меню")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}
