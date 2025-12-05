import Foundation

public extension Notification.Name {
    static let TextSystemDidUpdate = Notification.Name("TextSystemDidUpdate")
}

@MainActor
public final class TextSystemManager: ObservableObject {
    public static let shared = TextSystemManager()
    @Published public private(set) var config: TextSystemConfig

    private init(config: TextSystemConfig = TextThemeRegistry.defaultConfig()) {
        self.config = config
    }

    public func apply(config: TextSystemConfig) {
        self.config = config
        NotificationCenter.default.post(name: .TextSystemDidUpdate, object: self)
    }

    public func applyTheme(named name: String) {
        guard let theme = TextThemeRegistry.theme(named: name) else { return }
        var new = self.config
        new.themeName = name
        new.features = theme.features
        new.defaultFontName = theme.defaultFontName ?? new.defaultFontName
        new.defaultFontSize = theme.defaultFontSize
        new.defaultAlignment = theme.defaultAlignment
        new.defaultLineLimit = theme.defaultLineLimit ?? new.defaultLineLimit
        new.defaultLineSpacing = theme.defaultLineSpacing ?? new.defaultLineSpacing
        new.minimumScaleFactor = theme.minimumScaleFactor ?? new.minimumScaleFactor
        new.platform = theme.platform
        apply(config: new)
    }
}
