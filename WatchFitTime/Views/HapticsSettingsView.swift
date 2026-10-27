import SwiftUI

/// Elegir la vibración de cada fase del ejercicio. Tocar un patrón lo reproduce.
struct HapticsSettingsView: View {
    /// Fuerza a refrescar los subtítulos al volver de elegir.
    @State private var refresh = 0

    var body: some View {
        List {
            Section {
                ForEach(HapticEvent.allCases) { event in
                    NavigationLink {
                        HapticPatternPicker(event: event) { refresh += 1 }
                    } label: {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(event.title)
                            Text(Haptics.pattern(for: event).title)
                                .font(.footnote)
                                .foregroundStyle(.green)
                        }
                    }
                }
            } footer: {
                Text("Para más fuerza en todo el reloj: Ajustes › Sonidos y vibración › Vibración destacada.")
            }

            Button("Restaurar predeterminadas", role: .destructive) {
                Haptics.resetAll()
                refresh += 1
            }
        }
        .id(refresh)
        .navigationTitle("Vibraciones")
    }
}

private struct HapticPatternPicker: View {
    let event: HapticEvent
    let onChange: () -> Void
    @State private var selected: HapticPattern

    init(event: HapticEvent, onChange: @escaping () -> Void) {
        self.event = event
        self.onChange = onChange
        _selected = State(initialValue: Haptics.pattern(for: event))
    }

    var body: some View {
        List(HapticPattern.allCases) { pattern in
            Button {
                selected = pattern
                Haptics.setPattern(pattern, for: event)
                pattern.play()
                onChange()
            } label: {
                HStack {
                    Text(pattern.title)
                    Spacer()
                    if pattern == selected {
                        Image(systemName: "checkmark")
                            .foregroundStyle(.green)
                    }
                }
            }
        }
        .navigationTitle(event.shortTitle)
    }
}

#Preview {
    NavigationStack { HapticsSettingsView() }
}
