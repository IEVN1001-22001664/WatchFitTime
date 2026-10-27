import SwiftUI

/// Pantalla inicial: elegir descanso y arrancar.
struct SetupView: View {
    @Environment(WorkoutController.self) private var controller
    @State private var crown: Double = 60

    var body: some View {
        VStack(spacing: 6) {
            Text("Descanso")
                .font(.footnote)
                .foregroundStyle(.secondary)

            HStack {
                StepButton(systemImage: "minus") { change(by: -15) }
                Text(controller.restDuration.clockString)
                    .font(.system(size: 38, weight: .semibold, design: .rounded))
                    .monospacedDigit()
                    .frame(maxWidth: .infinity)
                    .minimumScaleFactor(0.6)
                StepButton(systemImage: "plus") { change(by: 15) }
            }
            .focusable()
            .digitalCrownRotation($crown,
                                  from: WorkoutEngine.restRange.lowerBound,
                                  through: WorkoutEngine.restRange.upperBound,
                                  by: 5,
                                  sensitivity: .medium,
                                  isContinuous: false,
                                  isHapticFeedbackEnabled: true)

            Spacer(minLength: 0)

            Button(action: controller.startExercise) {
                Label("Iniciar", systemImage: "play.fill")
                    .font(.title3.bold())
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
        }
        .navigationTitle("WatchFitTime")
        .onAppear { crown = controller.restDuration }
        .onChange(of: crown) { _, value in controller.restDuration = value }
    }

    private func change(by seconds: TimeInterval) {
        controller.restDuration += seconds
        crown = controller.restDuration
    }
}

/// Botón redondo pequeño de +/−.
struct StepButton: View {
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.headline)
                .frame(width: 32, height: 32)
        }
        .buttonStyle(.bordered)
        .buttonBorderShape(.circle)
    }
}

#Preview {
    SetupView().environment(WorkoutController())
}
