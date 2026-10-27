import WatchKit

/// Mantiene la app viva al bajar la muñeca mientras dura un ejercicio, para que
/// los relojes sigan corriendo y la vibración de fin de descanso llegue a tiempo.
/// Usa una sesión de "physical-therapy" (ver `WKBackgroundModes` en Info.plist).
final class BackgroundRuntime: NSObject, WKExtendedRuntimeSessionDelegate {
    private var session: WKExtendedRuntimeSession?

    var isRunning: Bool { session?.state == .running }

    func start() {
        guard session == nil || session?.state == .invalid else { return }
        let session = WKExtendedRuntimeSession()
        session.delegate = self
        session.start()
        self.session = session
    }

    func stop() {
        session?.invalidate()
        session = nil
    }

    func extendedRuntimeSessionDidStart(_ extendedRuntimeSession: WKExtendedRuntimeSession) {}

    func extendedRuntimeSessionWillExpire(_ extendedRuntimeSession: WKExtendedRuntimeSession) {}

    func extendedRuntimeSession(_ extendedRuntimeSession: WKExtendedRuntimeSession,
                                didInvalidateWith reason: WKExtendedRuntimeSessionInvalidationReason,
                                error: Error?) {
        if session === extendedRuntimeSession { session = nil }
    }
}
