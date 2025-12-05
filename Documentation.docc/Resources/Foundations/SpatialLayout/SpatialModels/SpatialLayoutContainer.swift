// SpatialLayoutContainer.swift
import Foundation

public final class SpatialLayoutContainer {
    public let fieldOfView: FieldOfViewManaging
    public let anchors: SpatialAnchorManaging
    public let depth: DepthManaging
    public let scaling: ScalingManaging
    public let gestures: GestureHandling
    public let volumes: VolumeManaging
    public let bestPractices: BestPracticesEnforcing

    public init(fieldOfView: FieldOfViewManaging,
                anchors: SpatialAnchorManaging,
                depth: DepthManaging,
                scaling: ScalingManaging,
                gestures: GestureHandling,
                volumes: VolumeManaging,
                bestPractices: BestPracticesEnforcing) {
        self.fieldOfView = fieldOfView
        self.anchors = anchors
        self.depth = depth
        self.scaling = scaling
        self.gestures = gestures
        self.volumes = volumes
        self.bestPractices = bestPractices
    }

    public static func `default`() -> SpatialLayoutContainer {
        SpatialLayoutContainer(fieldOfView: FieldOfViewManager(),
                               anchors: SpatialAnchorManager(),
                               depth: DepthManager(),
                               scaling: ScalingManager(),
                               gestures: GestureHandler(),
                               volumes: VolumeManager(),
                               bestPractices: BestPracticesEnforcer())
    }
}

#if DEBUG && canImport(SwiftUI)
import SwiftUI
#if os(visionOS)
struct SpatialLayoutContainer_Previews: PreviewProvider {
    static var previews: some View {
        let c = SpatialLayoutContainer.default()
        return VStack(alignment: .leading, spacing: 8) {
            Text("Container Preview").font(.headline)
            Text("FOV: \(c.fieldOfView.currentRegion.horizontalDegrees, specifier: "%.0f")° x \(c.fieldOfView.currentRegion.verticalDegrees, specifier: "%.0f")°")
            Text("Anchors: \(c.anchors.activeAnchors.count)")
            Text("Depth adaptive: \(c.depth.adaptiveDepthEnabled.description)")
            Text("Scaling: \(String(describing: c.scaling.currentRule.mode))")
            Text("Hover spacing: \(Int(c.gestures.hoverSpec.minSpacing))")
            Text("Volumes: \(c.volumes.volumes.count)")
            Text("Max windows: \(c.bestPractices.limits.maxWindows)")
        }
        .padding()
    }
}
#endif
#endif
