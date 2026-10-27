import Foundation
import Observation

/// Conecta el `WorkoutEngine` con la interfaz: reloj interno, vibraciones,
/// ejecución en segundo plano y notificación de respaldo.
@MainActor
@Observable
final class WorkoutController {
    private static let restKey = "restDuration"

    private(set) var engine = WorkoutEngine()

    /// Descanso configurado (segundos). Se recuerda entre aperturas.
    var restDuration: TimeInterval {
        get { engine.restDuration }
        set {
            let value = min(WorkoutEngine.restRange.upperBound,
                            max(WorkoutEngine.restRange.lowerBound, newValue))
            engine.restDuration = value
            UserDefaults.standard.set(value, forKey: Self.restKey)
        }
    }

    @ObservationIgnored private var timer: Timer?
    @ObservationIgnored private let runtime = BackgroundRuntime()
    @ObservationIgnored private var lastCountdownSecond: Int?

    init() {
        let saved = UserDefaults.standard.double(forKey: Self.restKey)
        if saved > 0 { engine.restDuration = saved }
    }

    var phase: WorkoutPhase { engine.phase }

    // MARK: Acciones del usuario

    /// Botón Iniciar: cuenta regresiva para acomodarse y luego serie 1.
    func startExercise() {
        engine.startCountdown(at: .now)
        lastCountdownSecond = nil
        runtime.start()
        startTimer()
        Haptics.countdownTick()
    }

    func skipCountdown() {
        engine.skipCountdown(at: .now)
        Haptics.setStarted()
    }

    /// Cancela durante la cuenta regresiva y vuelve al inicio.
    func cancelCountdown() {
        reset()
    }

    func finishSet() {
        engine.finishSet(at: .now)
        lastCountdownSecond = nil
        scheduleRestNotification()
        Haptics.setFinished()
    }

    func skipRest() {
        engine.skipRest(at: .now)
        RestNotifier.cancel()
        Haptics.setStarted()
    }

    func adjustRest(by seconds: TimeInterval) {
        engine.adjustRest(by: seconds, at: .now)
        lastCountdownSecond = nil
        scheduleRestNotification()
    }

    func setReps(_ reps: Int) {
        engine.setReps(reps)
    }

    func finishExercise() {
        engine.finishExercise(at: .now)
        stopEverything()
        Haptics.setFinished()
    }

    func reset() {
        engine.reset()
        stopEverything()
    }

    /// Llamar al volver a primer plano: pone los relojes al día.
    func refresh() {
        tick()
    }

    // MARK: Reloj interno

    private func startTimer() {
        timer?.invalidate()
        let timer = Timer(timeInterval: 0.2, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated { self?.tick() }
        }
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }

    private func tick() {
        let now = Date.now

        switch engine.phase {
        case .countdown:
            // Un clic por cada segundo de la cuenta.
            let remaining = Int(engine.countdownRemaining(at: now).rounded(.up))
            if remaining >= 1, remaining != lastCountdownSecond {
                if lastCountdownSecond != nil { Haptics.countdownTick() }
                lastCountdownSecond = remaining
            }
        case .resting:
            let remaining = Int(engine.restRemaining(at: now).rounded(.up))
            if (1...3).contains(remaining), remaining != lastCountdownSecond {
                lastCountdownSecond = remaining
                Haptics.restWarning()
            }
        default:
            break
        }

        switch engine.tick(at: now) {
        case .exerciseStarted:
            lastCountdownSecond = nil
            Haptics.setStarted()
        case .restFinished:
            RestNotifier.cancel()
            Haptics.restFinished()
        case .none:
            break
        }
    }

    private func scheduleRestNotification() {
        guard case let .resting(_, end) = engine.phase else { return }
        // Con la sesión en segundo plano activa vibramos nosotros mismos;
        // la notificación solo hace falta si el sistema puede suspendernos.
        if runtime.isRunning {
            RestNotifier.cancel()
        } else {
            RestNotifier.schedule(at: end, nextSet: engine.currentSetNumber + 1)
        }
    }

    private func stopEverything() {
        timer?.invalidate()
        timer = nil
        runtime.stop()
        RestNotifier.cancel()
        lastCountdownSecond = nil
    }
}
