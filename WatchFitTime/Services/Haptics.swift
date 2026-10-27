import WatchKit

/// Momentos del ejercicio que vibran. Cada uno usa el patrón que elija el usuario.
enum HapticEvent: String, CaseIterable, Identifiable {
    case countdownTick
    case setStarted
    case setFinished
    case restWarning
    case restFinished

    var id: String { rawValue }

    var title: String {
        switch self {
        case .countdownTick: "Cuenta inicial"
        case .setStarted: "Inicio de serie"
        case .setFinished: "Fin de serie"
        case .restWarning: "Últimos 3 s de descanso"
        case .restFinished: "Fin del descanso"
        }
    }

    /// Para títulos de navegación, donde cabe poco.
    var shortTitle: String {
        switch self {
        case .countdownTick: "Cuenta inicial"
        case .setStarted: "Inicio serie"
        case .setFinished: "Fin serie"
        case .restWarning: "Aviso descanso"
        case .restFinished: "Fin descanso"
        }
    }

    var defaultPattern: HapticPattern {
        switch self {
        case .countdownTick: .click
        case .setStarted: .start
        case .setFinished: .stop
        case .restWarning: .directionUp
        case .restFinished: .tripleStrong
        }
    }
}

/// Vibraciones disponibles: las del sistema y combinaciones más fuertes.
/// watchOS no permite cambiar la intensidad; se gana fuerza repitiendo golpes.
/// Si el reloj no está en silencio, cada una suena además de vibrar.
enum HapticPattern: String, CaseIterable, Identifiable {
    case none
    case click
    case start
    case stop
    case directionUp
    case directionDown
    case success
    case retry
    case failure
    case notification
    case doubleStrong
    case tripleStrong
    case alarm

    var id: String { rawValue }

    var title: String {
        switch self {
        case .none: "Sin vibración"
        case .click: "Clic (muy suave)"
        case .start: "Inicio"
        case .stop: "Alto"
        case .directionUp: "Ascendente"
        case .directionDown: "Descendente"
        case .success: "Éxito"
        case .retry: "Reintentar"
        case .failure: "Error"
        case .notification: "Notificación"
        case .doubleStrong: "Doble fuerte"
        case .tripleStrong: "Triple fuerte"
        case .alarm: "Alarma (profundidad)"
        }
    }

    /// Golpes que lo forman, separados por `spacing`.
    private var steps: [WKHapticType] {
        switch self {
        case .none: []
        case .click: [.click]
        case .start: [.start]
        case .stop: [.stop]
        case .directionUp: [.directionUp]
        case .directionDown: [.directionDown]
        case .success: [.success]
        case .retry: [.retry]
        case .failure: [.failure]
        case .notification: [.notification]
        case .doubleStrong: [.notification, .notification]
        case .tripleStrong: [.notification, .start, .start]
        case .alarm: [.underwaterDepthCriticalPrompt]
        }
    }

    private var spacing: TimeInterval { 0.35 }

    func play() {
        for (index, type) in steps.enumerated() {
            if index == 0 {
                WKInterfaceDevice.current().play(type)
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + spacing * Double(index)) {
                    WKInterfaceDevice.current().play(type)
                }
            }
        }
    }
}

enum Haptics {
    private static func key(_ event: HapticEvent) -> String { "haptic.\(event.rawValue)" }

    static func pattern(for event: HapticEvent) -> HapticPattern {
        UserDefaults.standard.string(forKey: key(event)).flatMap(HapticPattern.init) ?? event.defaultPattern
    }

    static func setPattern(_ pattern: HapticPattern, for event: HapticEvent) {
        UserDefaults.standard.set(pattern.rawValue, forKey: key(event))
    }

    static func resetAll() {
        HapticEvent.allCases.forEach { UserDefaults.standard.removeObject(forKey: key($0)) }
    }

    static func play(_ event: HapticEvent) { pattern(for: event).play() }

    static func countdownTick() { play(.countdownTick) }
    static func setStarted() { play(.setStarted) }
    static func setFinished() { play(.setFinished) }
    static func restWarning() { play(.restWarning) }
    static func restFinished() { play(.restFinished) }
}
