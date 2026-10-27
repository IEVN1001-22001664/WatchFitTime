# Prompt para Claude Design – isotipo de FitTime

Copia el bloque y adjunta `Design/AppIcon-1024.png` como referencia de la propuesta actual.

```
Diseña el isotipo (ícono de app, sin texto) de "FitTime", una app de Apple Watch
(y después iPhone) para controlar tiempos en el gimnasio: un cronómetro mide cada
serie de ejercicio y al terminarla arranca un temporizador de descanso; al acabar
el descanso el reloj vibra y empieza la siguiente serie.

Concepto: fusionar un cronómetro con un elemento de fuerza (mancuerna o pesa).
El anillo del cronómetro se divide en dos tramos que representan el ciclo
serie → descanso: verde #32D644 (serie) y azul #0A84FF (descanso).
Fondo oscuro (#0A0D12 a #212835, degradado radial sutil). Estilo plano,
geométrico, trazos gruesos y redondeados, sin sombras realistas ni texto.
Debe reconocerse al instante en tamaño muy pequeño (40 px en el reloj).
Adjunto mi propuesta actual como punto de partida: mejórala o propón 3
alternativas con el mismo concepto.

Entregables:
1. Ícono principal 1024×1024 px, PNG, sRGB, cuadrado, SIN transparencia y SIN
   esquinas redondeadas (el sistema aplica la máscara).
   - watchOS lo recorta en CÍRCULO: todo lo importante dentro del círculo
     central (~80 % del diámetro, unos 820 px).
   - iOS lo recorta en squircle: deja ~10 % de margen en los bordes.
2. Variantes para iPhone (iOS 18+), 1024×1024:
   - Oscuro: solo el símbolo sobre fondo transparente (el sistema pone el fondo).
   - Tintado: versión en escala de grises sobre fondo transparente.
3. Capas separadas para Icon Composer (iOS/watchOS 26, Liquid Glass):
   fondo, anillo y mancuerna como SVG independientes.
4. Glifo monocromo para complicaciones de la carátula: solo blanco sobre
   transparente, SVG (o PNG de 100×100 y 150×150), legible a 40 px.
```

## Medidas de referencia

| Uso | Tamaño | Formato | Notas |
|---|---|---|---|
| App watchOS | 1024×1024 | PNG sin alfa | Máscara circular; Xcode genera los demás tamaños |
| App iOS (claro) | 1024×1024 | PNG sin alfa | Sin esquinas redondeadas |
| App iOS (oscuro / tintado) | 1024×1024 | PNG con transparencia | iOS 18+ |
| Icon Composer | capas | SVG | iOS/watchOS 26 |
| Complicación | 100×100 y 150×150 (50 pt) o vector | PNG/SVG blanco, transparente | Se tiñe según la carátula |
| App Store | 1024×1024 | PNG sin alfa | El mismo ícono principal |

Para reemplazar el ícono basta con sustituir
`WatchFitTime/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png` y
`WatchFitTimeWidget/Assets.xcassets/Glyph.imageset/Glyph@2x.png` y `@3x` (100 y 150 px: WidgetKit rechaza glifos de más de ~110 pt).
