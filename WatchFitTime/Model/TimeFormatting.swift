import Foundation

extension TimeInterval {
    /// "1:05" o "1:02:05" si pasa de una hora.
    var clockString: String {
        let total = Int(self)
        let h = total / 3600, m = (total % 3600) / 60, s = total % 60
        return h > 0
            ? String(format: "%d:%02d:%02d", h, m, s)
            : String(format: "%d:%02d", m, s)
    }

    /// Cuenta regresiva: redondea hacia arriba para no mostrar "0:00" antes de tiempo.
    var countdownString: String {
        TimeInterval(rounded(.up)).clockString
    }

    /// Décima de segundo (0–9) para el cronómetro.
    var tenths: Int {
        Int((self * 10).truncatingRemainder(dividingBy: 10))
    }
}
