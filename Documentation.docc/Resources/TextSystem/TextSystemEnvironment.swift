import SwiftUI

private struct TextSystemKey: EnvironmentKey {
    static let defaultValue: TextSystemManager = .shared
}

public extension EnvironmentValues {
    var textSystem: TextSystemManager {
        get { self[TextSystemKey.self] }
        set { self[TextSystemKey.self] = newValue }
    }
}

public extension View {
    func textSystem(using manager: TextSystemManager = .shared) -> some View {
        environment(\.textSystem, manager)
    }
}

public struct TextSystemModifier: ViewModifier {
    @Environment(\.textSystem) private var textSystem
    public init() {}
    public func body(content: Content) -> some View {
        let cfg = textSystem.config
        var view = AnyView(content)
        if let limit = cfg.defaultLineLimit {
            view = AnyView(view.lineLimit(limit))
        }
        if let scale = cfg.minimumScaleFactor {
            view = AnyView(view.minimumScaleFactor(scale))
        }
        return view
    }
}

public extension View {
    func applyTextSystemDefaults() -> some View {
        modifier(TextSystemModifier())
    }
}
