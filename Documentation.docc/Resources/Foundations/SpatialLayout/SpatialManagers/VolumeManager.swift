// VolumeManager.swift
import Foundation
#if canImport(SwiftUI)
import SwiftUI
#endif
#if canImport(RealityKit)
import RealityKit
#endif

public final class VolumeManager: VolumeManaging {
    public private(set) var volumes: [String: VolumeSpec] = [:]
    public var defaultSize: CGSize = .init(width: 0.6, height: 0.4)

    public init() {}

    public func createVolume(_ spec: VolumeSpec) {
        volumes[spec.id] = spec
    }

    public func updateVolume(_ spec: VolumeSpec) {
        volumes[spec.id] = spec
    }

    public func removeVolume(id: String) {
        volumes.removeValue(forKey: id)
    }

    #if canImport(RealityKit)
    public func attach(entity: Entity, toVolume id: String) {
        _ = (entity, id)
    }
    #endif

    public func setDepthLayer(forVolume id: String, layer: DepthLayer) {
        _ = (id, layer)
    }
}

#if DEBUG && os(visionOS)
struct VolumeManager_Previews: PreviewProvider {
    static var previews: some View {
        let vm = VolumeManager()
        VStack(alignment: .leading, spacing: 8) {
            Text("Volumes").font(.headline)
            Button("Create Demo Volume") {
                vm.createVolume(.init(id: "demo", size: CGSize(width: 0.5, height: 0.3), contentKind: .realityView))
            }
            Text("Count: \(vm.volumes.count)")
        }
        .padding()
    }
}
#endif
