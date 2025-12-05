// ScalingManager.swift
import Foundation

public final class ScalingManager: ScalingManaging {
    public var currentRule: ScalingRule = .init(mode: .dynamicDistance, minScale: 0.7, maxScale: 1.6, lifeSizeEnabled: false)
    public var legibilityDistanceRange: ClosedRange<Float> = 0.5...2.5

    public init() {}

    public func scale(forZDistance meters: Float) -> Float {
        switch currentRule.mode {
        case .fixed:
            return 1.0
        case .lifeSize:
            return currentRule.lifeSizeEnabled ? 1.0 : 1.0
        case .dynamicDistance:
            let t = max(legibilityDistanceRange.lowerBound, min(meters, legibilityDistanceRange.upperBound))
            // Map distance to scale inversely
            let normalized = 1 - (t - legibilityDistanceRange.lowerBound) / (legibilityDistanceRange.upperBound - legibilityDistanceRange.lowerBound)
            let s = currentRule.minScale + normalized * (currentRule.maxScale - currentRule.minScale)
            return max(currentRule.minScale, min(s, currentRule.maxScale))
        }
    }

    public func applyScale(toWindow id: String, zDistance: Float) {
        _ = (id, scale(forZDistance: zDistance))
    }

    #if canImport(RealityKit)
    public func applyScale(toEntity entity: Entity, zDistance: Float) {
        let s = scale(forZDistance: zDistance)
        entity.scale = SIMD3<Float>(repeating: s)
    }
    #endif
}

#if DEBUG && canImport(SwiftUI) && os(visionOS)
import SwiftUI

struct ScalingControls: View {
    @State private var z: Double = 1.4
    @State private var minScale: Double = 0.7
    @State private var maxScale: Double = 1.6
    let manager: ScalingManager
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Scaling Controls").font(.headline)
            HStack { Text("Z \(z, specifier: "%.2f")m"); Slider(value: $z, in: 0.3...3.0) }
            HStack { Text("Min \(minScale, specifier: "%.2f")"); Slider(value: $minScale, in: 0.25...1.0) }
            HStack { Text("Max \(maxScale, specifier: "%.2f")"); Slider(value: $maxScale, in: 1.0...3.0) }
            let scale = manager.scale(forZDistance: Float(z))
            Text("Computed Scale: \(scale, specifier: "%.2f")")
                .font(.system(size: CGFloat(16 * Double(scale))))
                .onChange(of: z) { _ in manager.currentRule.minScale = Float(minScale); manager.currentRule.maxScale = Float(maxScale) }
                .onChange(of: minScale) { _ in manager.currentRule.minScale = Float(minScale) }
                .onChange(of: maxScale) { _ in manager.currentRule.maxScale = Float(maxScale) }
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct ScalingManager_Previews: PreviewProvider {
    static var previews: some View {
        let m = ScalingManager()
        return ScalingControls(manager: m)
            .padding()
    }
}
#endif
