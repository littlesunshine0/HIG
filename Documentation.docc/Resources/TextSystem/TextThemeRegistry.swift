import Foundation
import CoreGraphics

public struct TextTheme: Codable, Hashable, Sendable {
    public var name: String
    public var features: TextFeatures
    public var defaultFontName: String?
    public var defaultFontSize: CGFloat
    public var defaultAlignment: GlobalTextAlignment
    public var defaultLineLimit: Int?
    public var defaultLineSpacing: CGFloat?
    public var minimumScaleFactor: CGFloat?
    public var platform: TextPlatformOverrides

    public init(name: String,
                features: TextFeatures,
                defaultFontName: String? = nil,
                defaultFontSize: CGFloat = 17,
                defaultAlignment: GlobalTextAlignment = .natural,
                defaultLineLimit: Int? = nil,
                defaultLineSpacing: CGFloat? = nil,
                minimumScaleFactor: CGFloat? = nil,
                platform: TextPlatformOverrides = .init()) {
        self.name = name
        self.features = features
        self.defaultFontName = defaultFontName
        self.defaultFontSize = defaultFontSize
        self.defaultAlignment = defaultAlignment
        self.defaultLineLimit = defaultLineLimit
        self.defaultLineSpacing = defaultLineSpacing
        self.minimumScaleFactor = minimumScaleFactor
        self.platform = platform
    }
}

public enum TextThemeRegistry {
    private static var themes: [String: TextTheme] = {
        var dict: [String: TextTheme] = [:]
        dict["Default"] = TextTheme(name: "Default", features: [.dynamicType, .preferSystemFonts])
        dict["HighContrast"] = TextTheme(name: "HighContrast",
                                         features: [.dynamicType, .preferSystemFonts, .highContrast],
                                         defaultFontSize: 18,
                                         defaultAlignment: .natural,
                                         minimumScaleFactor: 0.9)
        dict["tvOSDistance"] = TextTheme(name: "tvOSDistance",
                                         features: [.dynamicType, .preferSystemFonts, .tvOSDistanceLegible],
                                         defaultFontSize: 36,
                                         defaultAlignment: .center)
        dict["watchGlance"] = TextTheme(name: "watchGlance",
                                        features: [.dynamicType, .preferSystemFonts, .watchOSGlanceable],
                                        defaultFontSize: 17,
                                        defaultAlignment: .center)
        return dict
    }()

    public static func register(_ theme: TextTheme) {
        themes[theme.name] = theme
    }

    public static func theme(named name: String) -> TextTheme? {
        themes[name]
    }

    public static func defaultConfig() -> TextSystemConfig {
        if let theme = themes["Default"] {
            return TextSystemConfig(features: theme.features,
                                    defaultFontName: theme.defaultFontName,
                                    defaultFontSize: theme.defaultFontSize,
                                    defaultAlignment: theme.defaultAlignment,
                                    defaultLineLimit: theme.defaultLineLimit,
                                    defaultLineSpacing: theme.defaultLineSpacing,
                                    minimumScaleFactor: theme.minimumScaleFactor,
                                    platform: theme.platform,
                                    themeName: theme.name)
        }
        return TextSystemConfig()
    }
}
