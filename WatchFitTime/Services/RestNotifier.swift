import UserNotifications

/// Notificación local de respaldo para el fin del descanso, por si el sistema
/// suspende la app (por ejemplo, si la sesión en segundo plano expira).
enum RestNotifier {
    private static let identifier = "rest-finished"

    static func requestAuthorization() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }

    static func schedule(at date: Date, nextSet: Int) {
        cancel()
        let interval = date.timeIntervalSinceNow
        guard interval > 1 else { return }

        let content = UNMutableNotificationContent()
        content.title = "¡Descanso terminado!"
        content.body = "Comienza la serie \(nextSet)"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
        UNUserNotificationCenter.current()
            .add(UNNotificationRequest(identifier: identifier, content: content, trigger: trigger))
    }

    static func cancel() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
}
