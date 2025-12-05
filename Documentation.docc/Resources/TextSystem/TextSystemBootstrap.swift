import Foundation
#if canImport(SwiftUI)
import SwiftUI
#endif

public enum TextSystemBootstrap {
    public static func loadFromBundleIfAvailable() {
        if let cfg = TextSystemConfigLoader.loadFromBundle() {
            Task { @MainActor in
                TextSystemManager.shared.apply(config: cfg)
            }
        }
    }

    public static func bootstrap() {
        loadFromBundleIfAvailable()
    }
}

#if canImport(SwiftUI)
public struct TextSystemRootModifier: ViewModifier {
    public init() {}
    public func body(content: Content) -> some View {
        content
            .textSystem(using: .shared)
            .applyTextSystemDefaults()
    }
}

public extension View {
    func withTextSystem() -> some View {
        modifier(TextSystemRootModifier())
    }
}
#endif
