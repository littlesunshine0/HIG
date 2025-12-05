// BestPracticesEnforcer.swift
import Foundation
#if canImport(SwiftUI)
import SwiftUI
#endif

public final class BestPracticesEnforcer: BestPracticesEnforcing, ObservableObject {
    public var limits: PolicyLimits = .init()
    @Published public private(set) var violations: [String] = []

    public init() {}

    public func evaluateWindowCount(_ count: Int) {
        if count > limits.maxWindows {
            violations.append("Window count \(count) exceeds \(limits.maxWindows)")
        }
    }

    public func evaluateVolumeCount(_ count: Int) {
        if count > limits.maxVolumes {
            violations.append("Volume count \(count) exceeds \(limits.maxVolumes)")
        }
    }

    public func evaluateDepthPolicies(_ policies: [DepthPolicy]) {
        // Placeholder: ensure zIndex within range
        for p in policies where abs(p.zIndex) > 10 {
            violations.append("Depth zIndex \(p.zIndex) is outside recommended range")
        }
    }

    public func evaluateInteractionDensity(views: Int, area: CGRect) {
        let density = CGFloat(views) / max(1, area.width * area.height)
        if density > limits.maxInteractiveDensity {
            violations.append("Interaction density \(density) exceeds \(limits.maxInteractiveDensity)")
        }
        if limits.minHoverSpacing < 12 {
            violations.append("Min hover spacing \(limits.minHoverSpacing) is too small")
        }
    }

    public func generateReport() -> String {
        violations.joined(separator: "\n")
    }
}

#if DEBUG && canImport(SwiftUI) && os(visionOS)
struct BestPracticesControls: View {
    @ObservedObject var enforcer: BestPracticesEnforcer
    @State private var windows = 3
    @State private var volumes = 1
    @State private var width: CGFloat = 800
    @State private var height: CGFloat = 600
    @State private var views = 300
    @State private var minHover: CGFloat = 12

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Best Practices").font(.headline)
            Stepper("Windows: \(windows)", value: $windows, in: 0...12)
            Stepper("Volumes: \(volumes)", value: $volumes, in: 0...10)
            HStack { Text("Area W \(Int(width))"); Slider(value: $width, in: 200...1600) }
            HStack { Text("Area H \(Int(height))"); Slider(value: $height, in: 200...1200) }
            Stepper("Views: \(views)", value: $views, in: 0...5000)
            HStack { Text("Min Hover \(Int(minHover))"); Slider(value: $minHover, in: 4...48) }
            Button("Run Checks") {
                enforcer.violations.removeAll()
                enforcer.limits.minHoverSpacing = minHover
                enforcer.evaluateWindowCount(windows)
                enforcer.evaluateVolumeCount(volumes)
                enforcer.evaluateInteractionDensity(views: views, area: CGRect(x: 0, y: 0, width: width, height: height))
            }
            if !enforcer.violations.isEmpty {
                Text(enforcer.generateReport())
                    .font(.footnote)
                    .foregroundStyle(.red)
            } else {
                Text("No violations").font(.footnote).foregroundStyle(.green)
            }
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct BestPracticesEnforcer_Previews: PreviewProvider {
    static var previews: some View {
        let e = BestPracticesEnforcer()
        return BestPracticesControls(enforcer: e)
            .padding()
    }
}
#endif
