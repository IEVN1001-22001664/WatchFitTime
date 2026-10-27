import WatchKit

/// Vibraciones (y sonido, si el reloj no está en silencio) de la app.
enum Haptics {
    static func setStarted() { play(.start) }
    static func setFinished() { play(.stop) }
    static func countdownTick() { play(.click) }

    /// Aviso fuerte de fin de descanso: dos golpes seguidos.
    static func restFinished() {
        play(.notification)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { play(.start) }
    }

    private static func play(_ type: WKHapticType) {
        WKInterfaceDevice.current().play(type)
    }
}
