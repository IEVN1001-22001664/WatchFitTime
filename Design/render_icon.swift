// Genera el isotipo de FitTime.
// Uso: swift Design/render_icon.swift <carpeta-de-salida>
// Produce AppIcon-1024.png (opaco, para watchOS/iOS) y Glyph@2x/@3x.png (blanco
// sobre transparente, para complicaciones: 50 pt, WidgetKit rechaza imágenes grandes).
import AppKit

let green = NSColor(srgbRed: 0.196, green: 0.839, blue: 0.267, alpha: 1)
let blue = NSColor(srgbRed: 0.04, green: 0.52, blue: 1.0, alpha: 1)

func render(size: CGFloat, opaque: Bool, to url: URL) {
    let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(size), pixelsHigh: Int(size),
                               bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
                               colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    let ctx = NSGraphicsContext.current!.cgContext
    // Trabajamos en un lienzo de 1024 con origen arriba a la izquierda.
    let s = size / 1024
    ctx.scaleBy(x: s, y: s)
    ctx.translateBy(x: 0, y: 1024)
    ctx.scaleBy(x: 1, y: -1)

    if opaque {
        let space = CGColorSpaceCreateDeviceRGB()
        let gradient = CGGradient(colorsSpace: space, colors: [
            NSColor(srgbRed: 0.13, green: 0.16, blue: 0.21, alpha: 1).cgColor,
            NSColor(srgbRed: 0.03, green: 0.04, blue: 0.06, alpha: 1).cgColor,
        ] as CFArray, locations: [0, 1])!
        ctx.drawRadialGradient(gradient, startCenter: CGPoint(x: 512, y: 420), startRadius: 0,
                               endCenter: CGPoint(x: 512, y: 512), endRadius: 720, options: .drawsAfterEndLocation)
    }

    let workColor = opaque ? green.cgColor : NSColor.white.cgColor
    let restColor = opaque ? blue.cgColor : NSColor.white.withAlphaComponent(0.55).cgColor
    let ink = NSColor.white.cgColor

    // Anillo de cronómetro: arco verde (serie) + arco azul (descanso).
    let center = CGPoint(x: 512, y: 548)
    let radius: CGFloat = 318
    ctx.setLineWidth(78)
    ctx.setLineCap(.round)
    func arc(from a: CGFloat, to b: CGFloat, color: CGColor) {
        // Ángulos en grados, 0 = arriba, sentido horario.
        let rad = { (d: CGFloat) in (d - 90) * .pi / 180 }
        ctx.setStrokeColor(color)
        ctx.addArc(center: center, radius: radius, startAngle: rad(a), endAngle: rad(b), clockwise: false)
        ctx.strokePath()
    }
    arc(from: 14, to: 246, color: workColor)
    arc(from: 268, to: 338, color: restColor)

    // Botón superior del cronómetro.
    ctx.setFillColor(ink)
    ctx.addPath(CGPath(roundedRect: CGRect(x: 452, y: 112, width: 120, height: 56),
                       cornerWidth: 22, cornerHeight: 22, transform: nil))
    ctx.fillPath()
    ctx.fill(CGRect(x: 494, y: 160, width: 36, height: 40))

    // Mancuerna al centro.
    func pill(_ r: CGRect) {
        ctx.addPath(CGPath(roundedRect: r, cornerWidth: min(r.width, r.height) / 2,
                           cornerHeight: min(r.width, r.height) / 2, transform: nil))
        ctx.fillPath()
    }
    let cy: CGFloat = 548
    ctx.fill(CGRect(x: 380, y: cy - 20, width: 264, height: 40))   // barra
    pill(CGRect(x: 336, y: cy - 96, width: 58, height: 192))         // discos internos
    pill(CGRect(x: 630, y: cy - 96, width: 58, height: 192))
    pill(CGRect(x: 288, y: cy - 66, width: 42, height: 132))         // discos externos
    pill(CGRect(x: 694, y: cy - 66, width: 42, height: 132))

    NSGraphicsContext.restoreGraphicsState()
    var image = rep.cgImage!
    if opaque {
        // Apple no acepta íconos con canal alfa: lo eliminamos.
        let flat = CGContext(data: nil, width: image.width, height: image.height, bitsPerComponent: 8,
                             bytesPerRow: 0, space: CGColorSpaceCreateDeviceRGB(),
                             bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)!
        flat.draw(image, in: CGRect(x: 0, y: 0, width: image.width, height: image.height))
        image = flat.makeImage()!
    }
    let dest = CGImageDestinationCreateWithURL(url as CFURL, "public.png" as CFString, 1, nil)!
    CGImageDestinationAddImage(dest, image, nil)
    CGImageDestinationFinalize(dest)
}

let out = URL(fileURLWithPath: CommandLine.arguments[1])
render(size: 1024, opaque: true, to: out.appendingPathComponent("AppIcon-1024.png"))
render(size: 100, opaque: false, to: out.appendingPathComponent("Glyph@2x.png"))
render(size: 150, opaque: false, to: out.appendingPathComponent("Glyph@3x.png"))
