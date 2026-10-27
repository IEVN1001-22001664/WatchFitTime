// Pruebas del WorkoutEngine (lógica pura, corre en macOS).
// Uso: Tests/run_engine_tests.sh
import Foundation

var failures = 0
func check(_ condition: Bool, _ message: String) {
    print(condition ? "OK  " : "FAIL", message)
    if !condition { failures += 1 }
}

let t0 = Date(timeIntervalSince1970: 1000)

// Ciclo serie → descanso → serie
var e = WorkoutEngine()
e.restDuration = 60
e.startExercise(at: t0)
check(e.currentSetNumber == 1, "serie 1 en curso")
check(e.setElapsed(at: t0 + 30) == 30, "cronómetro 30s")
e.finishSet(at: t0 + 40)
check(e.sets.count == 1 && e.sets[0].workDuration == 40, "serie 1 = 40s")
check(e.restRemaining(at: t0 + 50) == 50, "descanso restante 50s")
e.setReps(12)
check(e.tick(at: t0 + 99) == .none, "aún descansando")
check(e.tick(at: t0 + 105) == .restFinished, "descanso terminó -> serie 2 automática")
check(e.sets[0].restDuration == 60, "descanso registrado 60s")
check(e.setElapsed(at: t0 + 105) == 5, "serie 2 empezó al acabar el descanso")
e.finishSet(at: t0 + 130)
check(e.lastReps == 12, "reps prellenadas de la serie anterior")
e.adjustRest(by: 15, at: t0 + 131)
check(e.restRemaining(at: t0 + 130) == 75, "+15s")
e.skipRest(at: t0 + 140)
check(e.sets[1].restDuration == 10, "saltar descanso registra 10s")
e.finishExercise(at: t0 + 170)
check(e.phase == .finished && e.sets.count == 3, "terminar registra la serie en curso")
check(e.totalWorkTime == 40 + 30 + 30, "tiempo total en serie")
check(e.totalReps == 36 && e.totalElapsed(at: t0 + 999) == 170, "totales")

// Cuenta regresiva inicial
var c = WorkoutEngine()
c.startCountdown(at: t0)
check(c.countdownRemaining(at: t0 + 2) == 3, "cuenta: quedan 3s")
check(c.tick(at: t0 + 4.9) == .none, "cuenta: aún no termina")
check(c.tick(at: t0 + 5.3) == .exerciseStarted, "cuenta terminó -> serie 1")
check(c.exerciseStart == t0 + 5 && c.setElapsed(at: t0 + 6) == 1,
      "la serie 1 empieza al acabar la cuenta, no cuando se notó")
c.reset(); c.startCountdown(at: t0); c.skipCountdown(at: t0 + 1)
check(c.currentSetNumber == 1 && c.exerciseStart == t0 + 1, "tocar salta la cuenta")
c.reset(); c.startCountdown(at: t0); c.finishExercise(at: t0 + 1)
check(c.phase == .idle, "cancelar durante la cuenta vuelve al inicio")

// Formato
check(TimeInterval(65).clockString == "1:05", "formato m:ss")
check(TimeInterval(59.2).countdownString == "1:00", "cuenta regresiva redondea hacia arriba")

print(failures == 0 ? "\nTodas las pruebas pasaron." : "\n\(failures) prueba(s) fallaron.")
exit(failures == 0 ? 0 : 1)
