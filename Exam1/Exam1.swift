import SwiftUI

@main
struct MidtermApp: App {
  @StateObject private var historyStore: HistoryStore
  @State private var showAlert = false

  init() {
    let historyStore: HistoryStore
    do {
      historyStore = try HistoryStore(withChecking: true)
    } catch {
      print("Could not load history data")
      historyStore = HistoryStore()
      showAlert = true
    }
    _historyStore = StateObject(wrappedValue: historyStore)
  }

  var body: some Scene {
    WindowGroup {
      ListView(exerciseIndex: 0)
        .environmentObject(historyStore)
        .onAppear {
          print(
            FileManager.default.urls(
              for: .documentDirectory,
              in: .userDomainMask))
        }
    }
  }
}
