import SwiftUI

/// Resumen del ejercicio: tiempos y repeticiones por serie y totales.
struct SummaryView: View {
    @Environment(WorkoutController.self) private var controller

    var body: some View {
        let engine = controller.engine

        List {
            Section {
                StatRow(title: "Series", value: "\(engine.sets.count)")
                StatRow(title: "Repeticiones", value: "\(engine.totalReps)")
                StatRow(title: "Tiempo total", value: engine.totalElapsed(at: .now).clockString)
                StatRow(title: "En serie", value: engine.totalWorkTime.clockString)
                StatRow(title: "Descanso", value: engine.totalRestTime.clockString)
            }

            Section("Series") {
                ForEach(engine.sets) { set in
                    HStack {
                        Text("\(set.id)")
                            .font(.headline)
                            .foregroundStyle(.green)
                            .frame(width: 22, alignment: .leading)
                        VStack(alignment: .leading, spacing: 0) {
                            Text(set.workDuration.clockString)
                                .monospacedDigit()
                            if set.restDuration > 0 {
                                Text("desc. \(set.restDuration.clockString)")
                                    .font(.caption2)
                                    .foregroundStyle(.blue)
                            }
                        }
                        Spacer()
                        Text("\(set.reps) reps")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Button {
                controller.reset()
            } label: {
                Label("Nuevo ejercicio", systemImage: "arrow.counterclockwise")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
            .listRowBackground(Color.clear)
        }
        .navigationTitle("Resumen")
    }
}

private struct StatRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title).foregroundStyle(.secondary)
            Spacer()
            Text(value).bold().monospacedDigit()
        }
        .font(.footnote)
    }
}
