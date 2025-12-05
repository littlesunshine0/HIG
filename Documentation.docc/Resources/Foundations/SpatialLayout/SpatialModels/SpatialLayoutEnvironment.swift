// SpatialLayoutEnvironment.swift
import SwiftUI

private struct FieldOfViewKey: EnvironmentKey {
    static let defaultValue: FieldOfViewManaging? = nil
}
private struct SpatialAnchorKey: EnvironmentKey {
    static let defaultValue: SpatialAnchorManaging? = nil
}
private struct DepthKey: EnvironmentKey {
    static let defaultValue: DepthManaging? = nil
}
private struct ScalingKey: EnvironmentKey {
    static let defaultValue: ScalingManaging? = nil
}
private struct GestureKey: EnvironmentKey {
    static let defaultValue: GestureHandling? = nil
}
private struct VolumeKey: EnvironmentKey {
    static let defaultValue: VolumeManaging? = nil
}
private struct BestPracticesKey: EnvironmentKey {
    static let defaultValue: BestPracticesEnforcing? = nil
}

public extension EnvironmentValues {
    var fieldOfViewManager: FieldOfViewManaging? {
        get { self[FieldOfViewKey.self] }
        set { self[FieldOfViewKey.self] = newValue }
    }
    var spatialAnchorManager: SpatialAnchorManaging? {
        get { self[SpatialAnchorKey.self] }
        set { self[SpatialAnchorKey.self] = newValue }
    }
    var depthManager: DepthManaging? {
        get { self[DepthKey.self] }
        set { self[DepthKey.self] = newValue }
    }
    var scalingManager: ScalingManaging? {
        get { self[ScalingKey.self] }
        set { self[ScalingKey.self] = newValue }
    }
    var gestureHandler: GestureHandling? {
        get { self[GestureKey.self] }
        set { self[GestureKey.self] = newValue }
    }
    var volumeManager: VolumeManaging? {
        get { self[VolumeKey.self] }
        set { self[VolumeKey.self] = newValue }
    }
    var bestPracticesEnforcer: BestPracticesEnforcing? {
        get { self[BestPracticesKey.self] }
        set { self[BestPracticesKey.self] = newValue }
    }
}

public extension View {
    func spatialLayoutManagers(_ container: SpatialLayoutContainer) -> some View {
        self
            .environment(\.fieldOfViewManager, container.fieldOfView)
            .environment(\.spatialAnchorManager, container.anchors)
            .environment(\.depthManager, container.depth)
            .environment(\.scalingManager, container.scaling)
            .environment(\.gestureHandler, container.gestures)
            .environment(\.volumeManager, container.volumes)
            .environment(\.bestPracticesEnforcer, container.bestPractices)
    }
}

#if DEBUG && os(visionOS)
struct SpatialLayoutEnvironment_Previews: PreviewProvider {
    static var previews: some View {
        let container = SpatialLayoutContainer.default()
        return VStack(spacing: 8) {
            Text("Environment Injection Preview").font(.headline)
            Text("Managers injected via environment")
        }
        .padding()
        .spatialLayoutManagers(container)
    }
}
#endif
