// SpatialAnchorManager.swift
import Foundation
import simd

public final class SpatialAnchorManager: SpatialAnchorManaging {
    public private(set) var activeAnchors: [UUID: AnchorSpec] = [:]
    public var defaultPlacement: AnchorPlacementStyle = .upright

    public init() {}

    @discardableResult
    public func createAnchor(spec: AnchorSpec) -> UUID {
        activeAnchors[spec.id] = spec
        return spec.id
    }

    @discardableResult
    public func createAnchor(at position: simd_float3, orientation: simd_quatf, uprightPreferred: Bool) -> UUID {
        let spec = AnchorSpec(position: position, orientation: orientation, uprightPreferred: uprightPreferred)
        return createAnchor(spec: spec)
    }

    public func resolveAnchor(id: UUID) -> AnchorSpec? {
        activeAnchors[id]
    }

    public func removeAnchor(id: UUID) {
        activeAnchors.removeValue(forKey: id)
    }

    public func placeWindow(at anchorID: UUID) {
        // Hook for window placement
        _ = anchorID
    }

    public func placeVolume(at anchorID: UUID) {
        // Hook for volume placement
        _ = anchorID
    }
}

#if DEBUG && canImport(SwiftUI) && os(visionOS)
import SwiftUI

struct AnchorManagerControls: View {
    @ObservedObject var vm: AnchorVM
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Anchors").font(.headline)
            Button("Create Upright Anchor") { vm.create(upright: true) }
            Button("Create Angled Anchor") { vm.create(upright: false) }
            List {
                ForEach(vm.items, id: \.id) { a in
                    HStack {
                        Text(a.id.uuidString.prefix(8) + "…")
                        Spacer()
                        Button("Remove") { vm.remove(a.id) }
                    }
                }
            }.frame(height: 140)
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

final class AnchorVM: ObservableObject {
    @Published var items: [AnchorSpec] = []
    let manager: SpatialAnchorManager
    init(manager: SpatialAnchorManager) {
        self.manager = manager
    }
    func create(upright: Bool) {
        let id = manager.createAnchor(at: simd_float3(0, 1.4, -1.0), orientation: simd_quatf(angle: 0, axis: simd_float3(0,1,0)), uprightPreferred: upright)
        if let a = manager.resolveAnchor(id: id) { items.append(a) }
    }
    func remove(_ id: UUID) {
        manager.removeAnchor(id: id)
        items.removeAll { $0.id == id }
    }
}

struct SpatialAnchorManager_Previews: PreviewProvider {
    static var previews: some View {
        let m = SpatialAnchorManager()
        let vm = AnchorVM(manager: m)
        return AnchorManagerControls(vm: vm)
            .padding()
    }
}
#endif
