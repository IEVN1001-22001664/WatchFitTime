import SwiftUI
import WidgetKit

/// Complicación de carátula: atajo estático que abre FitTime.
@main
struct FitTimeWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "FitTimeShortcut", provider: ShortcutProvider()) { _ in
            FitTimeComplicationView()
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("FitTime")
        .description("Abre FitTime para empezar tu ejercicio.")
        .supportedFamilies([.accessoryCircular, .accessoryCorner, .accessoryRectangular, .accessoryInline])
    }
}

struct ShortcutEntry: TimelineEntry {
    let date: Date
}

/// El atajo no muestra datos, así que basta una sola entrada que nunca caduca.
struct ShortcutProvider: TimelineProvider {
    func placeholder(in context: Context) -> ShortcutEntry { ShortcutEntry(date: .now) }

    func getSnapshot(in context: Context, completion: @escaping (ShortcutEntry) -> Void) {
        completion(ShortcutEntry(date: .now))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ShortcutEntry>) -> Void) {
        completion(Timeline(entries: [ShortcutEntry(date: .now)], policy: .never))
    }
}

struct FitTimeComplicationView: View {
    @Environment(\.widgetFamily) private var family

    var body: some View {
        switch family {
        case .accessoryCorner:
            glyph
                .padding(4)
                .widgetLabel("FitTime")
        case .accessoryRectangular:
            HStack(spacing: 8) {
                glyph.frame(width: 40, height: 40)
                VStack(alignment: .leading, spacing: 0) {
                    Text("FitTime")
                        .font(.headline)
                        .widgetAccentable()
                    Text("Iniciar ejercicio")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer(minLength: 0)
            }
        case .accessoryInline:
            // La línea de texto solo admite SF Symbols.
            Label("FitTime", systemImage: "stopwatch")
        default:
            ZStack {
                AccessoryWidgetBackground()
                glyph.padding(7)
            }
        }
    }

    private var glyph: some View {
        Image("Glyph")
            .resizable()
            .scaledToFit()
            .widgetAccentable()
    }
}
