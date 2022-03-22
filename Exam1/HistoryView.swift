import SwiftUI

struct ListView: View {
  @EnvironmentObject var history: HistoryStore
  @State private var colorChange = 0
  let onColor = Color.red
  let offColor = Color.gray
  @State private var thing = ""

  let exerciseIndex: Int

  @AppStorage("ratings") private var ratings = ""
  @State private var rating = 0

  // 1
  init(exerciseIndex: Int) {
    self.exerciseIndex = exerciseIndex
    // 2
    let desiredLength = Exercise.exercises.count
    if ratings.count < desiredLength {
      // 3
      ratings = ratings.padding(
        toLength: desiredLength,
        withPad: "0",
        startingAt: 0)
    }
  }

  // swiftlint:disable:next strict_fileprivate
  fileprivate func convertRating() {
    // 2
    let index = ratings.index(
      ratings.startIndex,
      offsetBy: exerciseIndex)
    let character = ratings[index]
    // 3
    rating = character.wholeNumberValue ?? 0
  }

  var body: some View {
    VStack {
      Text("Reminder")
        .font(.title).padding()
      Form {
        ForEach(history.exerciseDays) { day in
          Section(
            header:
              Text(day.date.formatted(as: "MMM dd"))
              .font(.headline)
          ) {

              HStack {
                VStack {
                  ForEach(1..<5) { index in
                    Image(systemName: "circle")
                      .foregroundColor(
                        index > rating ? offColor : onColor
                      )
                      .onTapGesture {
                        updateRating(index: index)
                      }
                      .onChange(of: ratings) { _ in
                        convertRating()
                      }
                      .onAppear {
                        convertRating()
                      }
                  }
                }
                  
                    VStack {
            ForEach(day.exercises, id: \.self) { exercise in
              
                  Text(exercise)
                }
              }
            }
          }
        }
      }
      HStack {
        TextField("Add new!!!", text: $thing)
          .disableAutocorrection(true)
          .textFieldStyle(RoundedBorderTextFieldStyle())

        Button(action: { history.addDoneExercise(thing) }) {
          Image(systemName: "plus")
          Text("New!!! ")
        }
        .foregroundColor(.black)
        .font(.system(size: 19))
      }.padding()
    }.background(Color.gray)
  }

  func updateRating(index: Int) {
    rating = index
    let index = ratings.index(
      ratings.startIndex,
      offsetBy: exerciseIndex)
    ratings.replaceSubrange(index...index, with: String(rating))
  }
}

struct ListView_Previews: PreviewProvider {
  static var previews: some View {
    ListView(exerciseIndex: 0)
      .environmentObject(HistoryStore())
  }
}
