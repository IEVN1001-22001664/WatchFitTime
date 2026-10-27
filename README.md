# WatchFitTime

App para Apple Watch (watchOS 10+, SwiftUI) para controlar tiempos de series y descansos en el gimnasio u otros deportes.

## Flujo

1. **Inicio** – elige el descanso (por defecto 1:00) con la Digital Crown o los botones −/+ (pasos de 15 s) y pulsa **Iniciar**.
2. **Serie** – corre el cronómetro de la serie. Pulsa **Terminar serie** al acabar.
3. **Descanso** – arranca solo el temporizador regresivo. Mientras descansas, registra las repeticiones de la serie con la Digital Crown o −/+ (se prellenan con las de la serie anterior). Puedes sumar **+15s** o **Saltar**.
   - En los últimos 3 s el reloj hace *clic*; al terminar vibra/suena y **arranca automáticamente el cronómetro de la siguiente serie**.
4. **Terminar ejercicio** – botón 🏁 arriba a la derecha (con confirmación). Detiene todos los relojes y muestra el resumen: series, repeticiones, tiempo total, tiempo en serie y en descanso, y el detalle de cada serie.

## Estructura

```
WatchFitTime/
  Model/WorkoutEngine.swift      Lógica pura de series/descansos (sin WatchKit)
  Model/WorkoutController.swift  Reloj interno, vibraciones, segundo plano
  Services/                      Haptics, sesión en segundo plano, notificación de respaldo
  Views/                         Setup, Work (cronómetro), Rest (descanso), Summary
Config/Info.plist                WKBackgroundModes = physical-therapy
```

La app sigue corriendo con la muñeca bajada gracias a una `WKExtendedRuntimeSession` (tipo *physical-therapy*). Si el sistema la suspende, una notificación local avisa del fin del descanso.

## Compilar

Requiere Xcode 16+ con la plataforma watchOS instalada (Xcode › Settings › Components).

```bash
open WatchFitTime.xcodeproj
```
