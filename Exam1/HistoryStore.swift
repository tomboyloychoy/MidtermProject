import Foundation

struct ExerciseDay: Identifiable {
  let id = UUID()
  let date: Date
  var exercises: [String] = []
}

class HistoryStore: ObservableObject {
  @Published var exerciseDays: [ExerciseDay] = []

  enum FileError: Error {
    case loadFailure
    case saveFailure
    case urlFailure
  }

  init() {}

  init(withChecking: Bool) throws {
    #if DEBUG
      // createDevData()
    #endif
    do {
      try load()
    } catch {
      throw error
    }
  }

  func getURL() -> URL? {
    // 1
    guard
      let documentsURL = FileManager.default.urls(
        for: .documentDirectory, in: .userDomainMask
      ).first
    else {
      // 2
      return nil
    }
    // 3
    return documentsURL.appendingPathComponent("history.plist")
  }

  func load() throws {
    // 1
    guard let dataURL = getURL() else {
      throw FileError.urlFailure
    }
    do {
      // 2
      let data = try Data(contentsOf: dataURL)
      // 3
      let plistData = try PropertyListSerialization.propertyList(
        from: data,
        options: [],
        format: nil)
      // 4
      let convertedPlistData = plistData as? [[Any]] ?? []
      // 5
      exerciseDays = convertedPlistData.map {
        ExerciseDay(
          date: $0[1] as? Date ?? Date(),
          exercises: $0[2] as? [String] ?? [])
      }
    } catch {
      throw FileError.loadFailure
    }
  }

  func save() throws {
    guard let dataURL = getURL() else {
      throw FileError.urlFailure
    }
    let plistData = exerciseDays.map {
      [$0.id.uuidString, $0.date, $0.exercises]
    }
    do {
      // 1
      let data = try PropertyListSerialization.data(
        fromPropertyList: plistData,
        format: .binary,
        options: .zero)
      // 2
      try data.write(to: dataURL, options: .atomic)
    } catch {
      // 3
      throw FileError.saveFailure
    }
  }

  func addDoneExercise(_ exerciseName: String) {
    let today = Date()
    if let firstDate = exerciseDays.first?.date,
      today.isSameDay(as: firstDate)
    {
      exerciseDays[0].exercises.append(exerciseName)
    } else {
      exerciseDays.insert(
        ExerciseDay(date: today, exercises: [exerciseName]),
        at: 0)
    }
    do {
      try save()
    } catch {
      fatalError(error.localizedDescription)
    }
  }
}
