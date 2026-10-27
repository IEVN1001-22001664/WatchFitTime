import SwiftUI

/// Temporizador regresivo de descanso + registro de repeticiones de la serie.
struct RestView: View {
    @Environment(WorkoutController.self) private var controller
    @State private var crownReps: Double = 0

    var body: some View {
        TimelineView(.periodic(from: .now, by: 0.1)) { context in
            let engine = controller.engine
            let remaining = engine.restRemaining(at: context.date)

            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .stroke(.blue.opacity(0.25), lineWidth: 7)
                    Circle()
                        .trim(from: 0, to: engine.restProgress(at: context.date))
                        .stroke(.blue, style: StrokeStyle(lineWidth: 7, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    VStack(spacing: 0) {
                        Text("DESCANSO")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(.blue)
                        Text(remaining.countdownString)
                            .font(.system(size: 30, weight: .semibold, design: .rounded))
                            .monospacedDigit()
                    }
                }
                .frame(height: 78)

                repsEditor(setNumber: engine.currentSetNumber, reps: engine.lastReps)

                HStack(spacing: 6) {
                    Button("+15s") { controller.adjustRest(by: 15) }
                        .buttonStyle(.bordered)
                    Button {
                        controller.skipRest()
                    } label: {
                        Label("Saltar", systemImage: "forward.fill")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                }
                .font(.footnote.bold())
            }
        }
        .onAppear { crownReps = Double(controller.engine.lastReps) }
        .onChange(of: crownReps) { _, value in controller.setReps(Int(value)) }
    }

    private func repsEditor(setNumber: Int, reps: Int) -> some View {
        HStack {
            StepButton(systemImage: "minus") { crownReps = Double(max(0, reps - 1)) }
            VStack(spacing: -2) {
                Text("\(reps)")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .monospacedDigit()
                Text("reps serie \(setNumber)")
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            StepButton(systemImage: "plus") { crownReps = Double(reps + 1) }
        }
        .focusable()
        .digitalCrownRotation($crownReps,
                              from: 0,
                              through: 500,
                              by: 1,
                              sensitivity: .low,
                              isContinuous: false,
                              isHapticFeedbackEnabled: true)
    }
}

#Preview {
    let controller = WorkoutController()
    controller.startExercise()
    controller.finishSet()
    return RestView().environment(controller)
}
