import SwiftUI

/// Cronómetro de la serie en curso.
struct WorkView: View {
    @Environment(WorkoutController.self) private var controller
    @Environment(\.isLuminanceReduced) private var isLuminanceReduced

    var body: some View {
        TimelineView(.periodic(from: .now, by: 0.1)) { context in
            let engine = controller.engine
            let elapsed = engine.setElapsed(at: context.date)

            VStack(spacing: 2) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("SERIE \(engine.currentSetNumber)")
                            .font(.headline)
                            .foregroundStyle(.green)
                        if engine.lastReps > 0 {
                            Text("Anterior: \(engine.lastReps) \(engine.lastReps == 1 ? "rep" : "reps")")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                    Spacer()
                    Label(engine.totalElapsed(at: context.date).clockString, systemImage: "clock")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }
                .padding(.horizontal, 6)

                Spacer(minLength: 0)

                HStack(alignment: .firstTextBaseline, spacing: 0) {
                    Text(elapsed.clockString)
                        .font(.system(size: 48, weight: .semibold, design: .rounded))
                    if !isLuminanceReduced {
                        Text(".\(elapsed.tenths)")
                            .font(.system(size: 24, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                }
                .monospacedDigit()
                .minimumScaleFactor(0.5)
                .lineLimit(1)

                Spacer(minLength: 0)

                Button(action: controller.finishSet) {
                    Label("Terminar serie", systemImage: "stop.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity, minHeight: 38)
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
