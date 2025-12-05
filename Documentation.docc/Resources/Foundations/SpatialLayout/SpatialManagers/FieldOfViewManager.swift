// FieldOfViewManager.swift
import Foundation
import simd

public final class FieldOfViewManager: FieldOfViewManaging {
    public var currentRegion: FOVRegion = .init(horizontalDegrees: 60, verticalDegrees: 40, priority: 0)
    public var contentCenteringEnabled: Bool = true
    public var recenterThresholdDegrees: Double = 10

    public init() {}

    public func isCriticalContentVisible() -> Bool {
        // Placeholder heuristic
        true
    }

    public func centerImportantContent(animated: Bool) {
        // Implement centering logic if needed
    }

    public func recenter(using source: RecenterSource) {
        // Implement recenter logic based on source
        _ = source
    }

    public func recenter() {
        recenter(using: .programmatic)
    }

    public func updateFOV(from headPose: simd_float4x4) {
        // Update FOV region from head pose if needed
        _ = headPose
    }
}

#if DEBUG && canImport(SwiftUI) && os(visionOS)
import SwiftUI

struct FOVPreviewControls: View {
    @ObservedObject var vm: FOVVM
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("FOV Controls").font(.headline)
            Stepper("Horizontal: \(Int(vm.h))°", value: $vm.h, in: 20...120, step: 5)
            Stepper("Vertical: \(Int(vm.v))°", value: $vm.v, in: 15...90, step: 5)
            Toggle("Centering Enabled", isOn: $vm.centering)
            Button("Recenter (Digital Crown)") { vm.recenter(.digitalCrown) }
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

final class FOVVM: ObservableObject {
    @Published var h: Double
    @Published var v: Double
    @Published var centering: Bool
    let manager: FieldOfViewManager
    init(manager: FieldOfViewManager) {
        self.manager = manager
        self.h = manager.currentRegion.horizontalDegrees
        self.v = manager.currentRegion.verticalDegrees
        self.centering = manager.contentCenteringEnabled
    }
    func sync() {
        manager.currentRegion.horizontalDegrees = h
        manager.currentRegion.verticalDegrees = v
        manager.contentCenteringEnabled = centering
    }
    func recenter(_ source: RecenterSource) {
        manager.recenter(using: source)
    }
}

struct FieldOfViewManager_Previews: PreviewProvider {
    static var previews: some View {
        let m = FieldOfViewManager()
        let vm = FOVVM(manager: m)
        return VStack(spacing: 12) {
            FOVPreviewControls(vm: vm)
            Text("Content within \(Int(vm.h))° x \(Int(vm.v))°")
                .onChange(of: vm.h) { _ in vm.sync() }
                .onChange(of: vm.v) { _ in vm.sync() }
                .onChange(of: vm.centering) { _ in vm.sync() }
        }
        .padding()
    }
}
#endif
