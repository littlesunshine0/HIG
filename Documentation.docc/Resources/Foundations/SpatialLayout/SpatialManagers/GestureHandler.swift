// GestureHandler.swift
import Foundation
#if canImport(SwiftUI)
import SwiftUI
#endif

public final class GestureHandler: GestureHandling {
    public var hoverSpec: HoverSpec = .init()
    public var policy: GesturePolicy = .init()

    public init() {}

    public func configureIndirectGestures() {
        // Hook for indirect gestures
    }

    public func configureDirectGesturesIfAllowed() {
        if policy.directAllowed {
            // Hook for direct gestures
        }
    }

    public func applyHoverSpacing(to views: [AnyView]) {
        _ = views
    }

    public func handleDwellSelection(for viewID: String, dwellTime: TimeInterval) {
        _ = (viewID, dwellTime)
    }
}

#if DEBUG && canImport(SwiftUI) && os(visionOS)
struct GestureControls: View {
    @State private var spacing: Double = 12
    @State private var dwell: Double = 0.5
    @State private var indirect = true
    @State private var direct = false
    let handler: GestureHandler

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Gesture Controls").font(.headline)
            Toggle("Indirect Priority", isOn: $indirect)
            Toggle("Direct Allowed", isOn: $direct)
            HStack { Text("Hover Spacing \(Int(spacing))"); Slider(value: $spacing, in: 8...48, step: 1) }
            HStack { Text("Dwell \(dwell, specifier: "%.2f")s"); Slider(value: $dwell, in: 0.2...2.0) }
            Button("Apply") {
                handler.policy.indirectPriority = indirect
                handler.policy.directAllowed = direct
                handler.hoverSpec.minSpacing = CGFloat(spacing)
                handler.hoverSpec.activationDelay = dwell
            }
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct GestureHandler_Previews: PreviewProvider {
    static var previews: some View {
        let h = GestureHandler()
        return GestureControls(handler: h)
            .padding()
    }
}
#endif
