import Foundation

/// Registro de una serie terminada.
struct SetRecord: Identifiable, Equatable {
    /// Número de serie (1, 2, 3…).
    let id: Int
    /// Tiempo que duró la serie (cronómetro).
    var workDuration: TimeInterval
    /// Descanso real que siguió a la serie.
    var restDuration: TimeInterval
    /// Repeticiones hechas en la serie.
    var reps: Int
}

enum WorkoutPhase: Equatable {
    /// Antes de empezar el ejercicio.
    case idle
    /// Cuenta regresiva para acomodarse antes de la primera serie.
    case countdown(start: Date, end: Date)
    /// Cronómetro de serie corriendo.
    case working(start: Date)
    /// Temporizador de descanso corriendo hasta `end`.
    case resting(start: Date, end: Date)
    /// Ejercicio terminado: todos los relojes detenidos.
    case finished
}

/// Lógica pura de un ejercicio (series + descansos). No depende de WatchKit,
/// recibe siempre la hora actual para poder probarse de forma determinista.
struct WorkoutEngine {
    static let restRange: ClosedRange<TimeInterval> = 5...600
    static let countdownDuration: TimeInterval = 5

    var restDuration: TimeInterval = 60
    private(set) var phase: WorkoutPhase = .idle
    private(set) var sets: [SetRecord] = []
    private(set) var exerciseStart: Date?
    private(set) var exerciseEnd: Date?

    /// Lo que ocurrió en un `tick`.
    enum TickEvent {
        case none
        /// Terminó la cuenta regresiva y arrancó la serie 1.
        case exerciseStarted
        /// Terminó un descanso y arrancó la siguiente serie.
        case restFinished
    }

    // MARK: Acciones

    /// Inicia la cuenta regresiva previa a la primera serie.
    mutating func startCountdown(at now: Date) {
        sets = []
        exerciseStart = nil
        exerciseEnd = nil
        phase = .countdown(start: now, end: now.addingTimeInterval(Self.countdownDuration))
    }

    /// Salta la cuenta regresiva y arranca la serie 1 ya.
    mutating func skipCountdown(at now: Date) {
        guard case .countdown = phase else { return }
        startExercise(at: now)
    }

    mutating func startExercise(at now: Date) {
        sets = []
        exerciseStart = now
        exerciseEnd = nil
        phase = .working(start: now)
    }

    /// Detiene el cronómetro de la serie e inicia el descanso.
    mutating func finishSet(at now: Date) {
        guard case let .working(start) = phase else { return }
        sets.append(SetRecord(id: sets.count + 1,
                              workDuration: now.timeIntervalSince(start),
                              restDuration: 0,
                              reps: sets.last?.reps ?? 0))
        phase = .resting(start: now, end: now.addingTimeInterval(restDuration))
    }

    /// Avanza el reloj. Si terminó la cuenta regresiva o un descanso, arranca
    /// la serie en el instante exacto en que acabó (no cuando se notó).
    @discardableResult
    mutating func tick(at now: Date) -> TickEvent {
        switch phase {
        case let .countdown(_, end) where now >= end:
            startExercise(at: end)
            return .exerciseStarted
        case let .resting(_, end) where now >= end:
            startNextSet(at: end)
            return .restFinished
        default:
            return .none
        }
    }

    /// Termina el descanso antes de tiempo y arranca la siguiente serie.
    mutating func skipRest(at now: Date) {
        guard case .resting = phase else { return }
        startNextSet(at: now)
    }

    /// Alarga (o acorta, con valor negativo) el descanso en curso.
    mutating func adjustRest(by seconds: TimeInterval, at now: Date) {
        guard case let .resting(start, end) = phase else { return }
        phase = .resting(start: start, end: max(now, end.addingTimeInterval(seconds)))
    }

    /// Cambia las repeticiones de la última serie terminada.
    mutating func setReps(_ reps: Int) {
        guard !sets.isEmpty else { return }
        sets[sets.count - 1].reps = max(0, reps)
    }

    /// Detiene todos los relojes. Si había una serie en curso se registra.
    mutating func finishExercise(at now: Date) {
        switch phase {
        case let .working(start):
            sets.append(SetRecord(id: sets.count + 1,
                                  workDuration: now.timeIntervalSince(start),
                                  restDuration: 0,
                                  reps: sets.last?.reps ?? 0))
        case .resting:
            // El descanso tras la última serie no cuenta.
            break
        case .countdown:
            // Aún no empezó: volver al inicio.
            reset()
            return
        case .idle, .finished:
            return
        }
        exerciseEnd = now
        phase = .finished
    }

    mutating func reset() {
        phase = .idle
        sets = []
        exerciseStart = nil
        exerciseEnd = nil
    }

    private mutating func startNextSet(at time: Date) {
        if case let .resting(start, _) = phase, !sets.isEmpty {
            sets[sets.count - 1].restDuration = time.timeIntervalSince(start)
        }
        phase = .working(start: time)
    }

    // MARK: Consultas

    /// Número de la serie en curso (o de la última terminada al descansar).
    var currentSetNumber: Int {
        if case .working = phase { return sets.count + 1 }
        return sets.count
    }

    var lastReps: Int { sets.last?.reps ?? 0 }

    func setElapsed(at now: Date) -> TimeInterval {
        guard case let .working(start) = phase else { return 0 }
        return max(0, now.timeIntervalSince(start))
    }

    func countdownRemaining(at now: Date) -> TimeInterval {
        guard case let .countdown(_, end) = phase else { return 0 }
        return max(0, end.timeIntervalSince(now))
    }

    /// Fracción de cuenta regresiva transcurrida (0 → 1).
    func countdownProgress(at now: Date) -> Double {
        guard case let .countdown(start, end) = phase else { return 0 }
        let total = end.timeIntervalSince(start)
        guard total > 0 else { return 1 }
        return min(1, max(0, now.timeIntervalSince(start) / total))
    }

    func restRemaining(at now: Date) -> TimeInterval {
        guard case let .resting(_, end) = phase else { return 0 }
        return max(0, end.timeIntervalSince(now))
    }

    /// Fracción de descanso restante (1 → 0).
    func restProgress(at now: Date) -> Double {
        guard case let .resting(start, end) = phase else { return 0 }
        let total = end.timeIntervalSince(start)
        guard total > 0 else { return 0 }
        return min(1, max(0, end.timeIntervalSince(now) / total))
    }

    func totalElapsed(at now: Date) -> TimeInterval {
        guard let start = exerciseStart else { return 0 }
        return max(0, (exerciseEnd ?? now).timeIntervalSince(start))
    }

    var totalWorkTime: TimeInterval { sets.reduce(0) { $0 + $1.workDuration } }
    var totalRestTime: TimeInterval { sets.reduce(0) { $0 + $1.restDuration } }
    var totalReps: Int { sets.reduce(0) { $0 + $1.reps } }
}
