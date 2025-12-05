// SpatialLayoutBootstrap.swift
import Foundation

public struct SpatialLayoutConfiguration: Sendable, Equatable {
    public var depthPolicy: DepthPolicy
    public var scalingRule: ScalingRule
    public var hoverSpec: HoverSpec
    public var limits: PolicyLimits
    public init(depthPolicy: DepthPolicy = .init(),
                scalingRule: ScalingRule = .init(mode: .dynamicDistance),
                hoverSpec: HoverSpec = .init(),
                limits: PolicyLimits = .init()) {
        self.depthPolicy = depthPolicy
        self.scalingRule = scalingRule
        self.hoverSpec = hoverSpec
        self.limits = limits
    }
}

public enum SpatialLayoutBootstrap {
    private static(set) var isConfigured: Bool = false

    public static func configure(using config: SpatialLayoutConfiguration, container: SpatialLayoutContainer) {
        container.depth.defaultPolicy = config.depthPolicy
        container.scaling.currentRule = config.scalingRule
        container.gestures.hoverSpec = config.hoverSpec
        container.bestPractices.limits = config.limits
        isConfigured = true
    }

    public static func registerDefaultManagers(container: SpatialLayoutContainer) {
        // No-op: container already provides defaults via init/default()
        isConfigured = true
    }

    public static func teardown() {
        isConfigured = false
    }
}

#if DEBUG && canImport(SwiftUI)
import SwiftUI

struct SpatialLayoutBootstrapControls: View {
    @State private var occlusion = false
    @State private var zIndex: Double = 0
    @State private var minScale: Double = 0.5
    @State private var maxScale: Double = 2.0
    @State private var hoverSpacing: Double = 12
    @State private var maxWindows: Double = 4
    let container: SpatialLayoutContainer

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Spatial Layout Bootstrap").font(.headline)
            Toggle("Occlusion", isOn: $occlusion)
            Stepper("zIndex: \(Int(zIndex))", value: $zIndex, in: -5...5)
            HStack {
                Text("Min Scale \(minScale, specifier: "%.2f")")
                Slider(value: $minScale, in: 0.25...1.0)
            }
            HStack {
                Text("Max Scale \(maxScale, specifier: "%.2f")")
                Slider(value: $maxScale, in: 1.0...3.0)
            }
            HStack {
                Text("Hover Spacing \(Int(hoverSpacing))")
                Slider(value: $hoverSpacing, in: 8...48, step: 1)
            }
            Stepper("Max Windows: \(Int(maxWindows))", value: $maxWindows, in: 1...10)

            Button("Apply") {
                let cfg = SpatialLayoutConfiguration(
                    depthPolicy: .init(zIndex: Int(zIndex), occlusionEnabled: occlusion, shadowStyle: "default"),
                    scalingRule: .init(mode: .dynamicDistance, minScale: Float(minScale), maxScale: Float(maxScale), lifeSizeEnabled: false),
                    hoverSpec: .init(minSpacing: CGFloat(hoverSpacing), activationDelay: 0.5, highlightStyle: "default"),
                    limits: .init(maxWindows: Int(maxWindows), maxVolumes: 2, maxInteractiveDensity: 0.001, minHoverSpacing: CGFloat(hoverSpacing))
                )
                SpatialLayoutBootstrap.configure(using: cfg, container: container)
            }
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#if os(visionOS)
struct SpatialLayoutBootstrap_Previews: PreviewProvider {
    static var previews: some View {
        let container = SpatialLayoutContainer.default()
        return VStack(spacing: 12) {
            SpatialLayoutBootstrapControls(container: container)
            Text("Preview Host")
        }
        .padding()
    }
}
#endif
#endif
