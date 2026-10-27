import SwiftUI

/// Cronómetro de la serie en curso.
struct WorkView: View {
    @Environment(WorkoutController.self) private var controller
    @Environment(\.isLuminanceReduced) private var isLuminanceReduced

    var body: some View {
        TimelineView(.periodic(from: .now, by: 0.1)) { context in
            let engine = controller.engine
            let elapsed = engine.setElapsed(at: context.date)

            VStack(spacing: 4) {
                HStack {
                    Text("SERIE \(engine.currentSetNumber)")
                        .font(.headline)
                        .foregroundStyle(.green)
                    Spacer()
                    Label(engine.totalElapsed(at: context.date).clockString, systemImage: "clock")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }

                Spacer(minLength: 0)

                HStack(alignment: .firstTextBaseline, spacing: 0) {
                    Text(elapsed.clockString)
                        .font(.system(size: 54, weight: .semibold, design: .rounded))
                    if !isLuminanceReduced {
                        Text(".\(elapsed.tenths)")
                            .font(.system(size: 26, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                }
                .monospacedDigit()
                .minimumScaleFactor(0.5)
                .lineLimit(1)

                if engine.lastReps > 0 {
                    Text("Anterior: \(engine.lastReps) reps")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 0)

                Button(action: controller.finishSet) {
                    Label("Terminar serie", systemImage: "stop.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity, minHeight: 44)
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)
            }
        }
    }
}

#Preview {
    let controller = WorkoutController()
    controller.startExercise()
    return WorkView().environment(controller)
}
