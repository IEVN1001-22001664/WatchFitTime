import SwiftUI

/// Cuenta regresiva antes de la primera serie, para acomodarse en la máquina.
/// Tocar la pantalla empieza ya.
struct CountdownView: View {
    @Environment(WorkoutController.self) private var controller

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1.0 / 30)) { context in
            let engine = controller.engine
            let remaining = engine.countdownRemaining(at: context.date)
            let seconds = Int(remaining.rounded(.up))

            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .stroke(.green.opacity(0.25), lineWidth: 12)
                    Circle()
                        .trim(from: 0, to: engine.countdownProgress(at: context.date))
                        .stroke(
                            AngularGradient(colors: [.green, .mint, .green],
                                            center: .center),
                            style: StrokeStyle(lineWidth: 12, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    Text(seconds > 0 ? "\(seconds)" : "¡Ya!")
                        .font(.system(size: 60, weight: .semibold, design: .rounded))
                        .monospacedDigit()
                        .contentTransition(.numericText(countsDown: true))
                        .animation(.snappy, value: seconds)
                }
                .padding(.horizontal, 18)

                Text("Prepárate · toca para empezar")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .contentShape(Rectangle())
            .onTapGesture { controller.skipCountdown() }
        }
    }
}

#Preview {
    let controller = WorkoutController()
    controller.startExercise()
    return CountdownView().environment(controller)
}
