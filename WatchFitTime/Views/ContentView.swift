import SwiftUI

struct ContentView: View {
    @Environment(WorkoutController.self) private var controller
    @Environment(\.scenePhase) private var scenePhase
    @State private var confirmFinish = false
    @State private var showHaptics = false

    private var isActive: Bool {
        switch controller.phase {
        case .working, .resting: true
        case .idle, .countdown, .finished: false
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                switch controller.phase {
                case .idle: SetupView()
                case .countdown: CountdownView()
                case .working: WorkView()
                case .resting: RestView()
                case .finished: SummaryView()
                }
            }
            .animation(.easeInOut(duration: 0.2), value: controller.phase)
            .toolbar {
                if case .idle = controller.phase {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            showHaptics = true
                        } label: {
                            Image(systemName: "waveform.path")
                        }
                        .accessibilityLabel("Vibraciones")
                    }
                }
                if case .countdown = controller.phase {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: controller.cancelCountdown) {
                            Image(systemName: "xmark")
                        }
                        .accessibilityLabel("Cancelar")
                    }
                }
                if isActive {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            confirmFinish = true
                        } label: {
                            Image(systemName: "flag.checkered")
                        }
                        .accessibilityLabel("Terminar ejercicio")
                    }
                }
            }
            .navigationDestination(isPresented: $showHaptics) {
                HapticsSettingsView()
            }
            .confirmationDialog("¿Terminar ejercicio?", isPresented: $confirmFinish) {
                Button("Terminar", role: .destructive) { controller.finishExercise() }
                Button("Seguir", role: .cancel) {}
            }
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { controller.refresh() }
        }
    }
}

#Preview {
    ContentView().environment(WorkoutController())
}
