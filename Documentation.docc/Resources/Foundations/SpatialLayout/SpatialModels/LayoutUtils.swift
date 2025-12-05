// LayoutUtils.swift
import Foundation
#if canImport(SwiftUI)
import SwiftUI
#endif
#if canImport(RealityKit)
import RealityKit
#endif

public enum LayoutUtils {
    public static func spacing(for sizeClass: UserInterfaceSizeClass?) -> CGFloat {
        switch sizeClass {
        case .compact: return 8
        case .regular: return 16
        default: return 12
        }
    }

    public static func safeHoverZone(for viewBounds: CGRect) -> SafeHoverZone {
        let radius = min(viewBounds.width, viewBounds.height) * 0.1
        return .init(radius: max(16, radius), margin: 8)
    }

    #if canImport(RealityKit)
    public static func alignToFloorIfNeeded(entity: Entity, tolerance: Float) {
        _ = (entity, tolerance)
    }
    #endif
}

#if DEBUG && canImport(SwiftUI) && os(visionOS)
struct LayoutUtils_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 12) {
            Text("Layout Utils").font(.headline)
            GeometryReader { proxy in
                let zone = LayoutUtils.safeHoverZone(for: proxy.frame(in: .local))
                ZStack {
                    RoundedRectangle(cornerRadius: 12).stroke(.secondary)
                    Circle().stroke(.blue).frame(width: zone.radius*2, height: zone.radius*2)
                }
            }
            .frame(height: 140)
        }
        .padding()
    }
}
#endif
