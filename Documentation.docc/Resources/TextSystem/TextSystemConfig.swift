import Foundation
import CoreGraphics

public struct TextSystemConfig: Codable, Hashable, Sendable {
    public var features: TextFeatures
    public var defaultFontName: String?
    public var defaultFontSize: CGFloat
    public var defaultAlignment: GlobalTextAlignment
    public var defaultLineLimit: Int?
    public var defaultLineSpacing: CGFloat?
    public var minimumScaleFactor: CGFloat?
    public var platform: TextPlatformOverrides
    public var themeName: String?

    public init(features: TextFeatures = [.dynamicType, .preferSystemFonts],
                defaultFontName: String? = nil,
                defaultFontSize: CGFloat = 17,
                defaultAlignment: GlobalTextAlignment = .natural,
                defaultLineLimit: Int? = nil,
                defaultLineSpacing: CGFloat? = nil,
                minimumScaleFactor: CGFloat? = nil,
                platform: TextPlatformOverrides = .init(),
                themeName: String? = nil) {
        self.features = features
        self.defaultFontName = defaultFontName
        self.defaultFontSize = defaultFontSize
        self.defaultAlignment = defaultAlignment
        self.defaultLineLimit = defaultLineLimit
        self.defaultLineSpacing = defaultLineSpacing
        self.minimumScaleFactor = minimumScaleFactor
        self.platform = platform
        self.themeName = themeName
    }
}

public enum TextSystemConfigLoader {
    public static func load(from url: URL) throws -> TextSystemConfig {
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(TextSystemConfig.self, from: data)
    }
    public static func save(_ config: TextSystemConfig, to url: URL) throws {
        let data = try JSONEncoder().encode(config)
        try data.write(to: url, options: .atomic)
    }
    public static func loadFromBundle(named name: String = "TextSystemConfig", withExtension ext: String = "json", in bundle: Bundle = .main) -> TextSystemConfig? {
        guard let url = bundle.url(forResource: name, withExtension: ext) else { return nil }
        return try? load(from: url)
    }
}
