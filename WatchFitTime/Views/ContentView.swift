import SwiftUI

struct ContentView: View {
    @Environment(WorkoutController.self) private var controller
    @Environment(\.scenePhase) private var scenePhase
    @State private var confirmFinish = false

    private var isActive: Bool {
        switch controller.phase {
        case .working, .resting: true
        case .idle, .finished: false
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                switch controller.phase {
                case .idle: SetupView()
                case .working: WorkView()
                case .resting: RestView()
                case .finished: SummaryView()
                }
            }
            .animation(.easeInOut(duration: 0.2), value: controller.phase)
            .toolbar {
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
