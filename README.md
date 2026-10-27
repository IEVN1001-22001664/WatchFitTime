# FitTime

*(repositorio: WatchFitTime)*

App para Apple Watch (watchOS 10+, SwiftUI) para controlar tiempos de series y descansos en el gimnasio u otros deportes.

## Flujo

1. **Inicio** – elige el descanso (por defecto 1:00) con la Digital Crown o los botones −/+ (pasos de 15 s) y pulsa **Iniciar**.
   - Arranca una **cuenta regresiva de 5 s** para acomodarte en la máquina (un clic por segundo). Toca la pantalla para empezar ya, o ✕ para cancelar.
2. **Serie** – corre el cronómetro de la serie. Pulsa **Terminar serie** al acabar.
3. **Descanso** – arranca solo el temporizador regresivo. Mientras descansas, registra las repeticiones de la serie con la Digital Crown o −/+ (se prellenan con las de la serie anterior). Puedes sumar **+15s** o **Saltar**.
   - En los últimos 3 s el reloj hace *clic*; al terminar vibra/suena y **arranca automáticamente el cronómetro de la siguiente serie**.
4. **Terminar ejercicio** – botón 🏁 arriba a la derecha (con confirmación). Detiene todos los relojes y muestra el resumen: series, repeticiones, tiempo total, tiempo en serie y en descanso, y el detalle de cada serie.

## Vibraciones

Botón de onda (arriba a la izquierda en el inicio) › elige un patrón para cada fase: cuenta inicial, inicio y fin de serie, últimos 3 s de descanso y fin del descanso. Al tocar un patrón se reproduce. watchOS no permite subir la intensidad desde una app; para más fuerza en todo el reloj: Ajustes › Sonidos y vibración › Vibración destacada.

## Estructura

```
WatchFitTime/
  Model/WorkoutEngine.swift      Lógica pura de series/descansos (sin WatchKit)
  Model/WorkoutController.swift  Reloj interno, vibraciones, segundo plano
  Services/                      Haptics, sesión en segundo plano, notificación de respaldo
  Views/                         Setup, Work (cronómetro), Rest (descanso), Summary
WatchFitTimeWidget/              Complicación de carátula (atajo que abre la app)
Config/                          Info.plist de la app y del widget
Design/                          Isotipo: generador, PNG y prompt para Claude Design
```

La app sigue corriendo con la muñeca bajada gracias a una `WKExtendedRuntimeSession` (tipo *physical-therapy*). Si el sistema la suspende, una notificación local avisa del fin del descanso.

## Complicación

Mantén presionada la carátula › Editar › Complicaciones › **FitTime**. Disponible en círculo, esquina, rectangular y en línea.

## Pruebas

```bash
Tests/run_engine_tests.sh
```

## Compilar

Requiere Xcode 16+ con la plataforma watchOS instalada (Xcode › Settings › Components).

```bash
open WatchFitTime.xcodeproj
```
