//  Color.swift
//  Doc-style index for the Color module (types, roles, and platform behaviors).
//
//  NOTE: This file intentionally contains only doc comments and MARK separators.
//  Replace placeholders with app-specific code when integrating.
//
// References (HIG & Docs)
// - Color (HIG): https://developer.apple.com/design/human-interface-guidelines/color
// - SwiftUI Color: https://developer.apple.com/documentation/swiftui/color
// - UIKit UIColor (dynamic, semantic): https://developer.apple.com/documentation/uikit/uicolor
// - UIColor.colorWithDynamicProvider(_:): https://developer.apple.com/documentation/uikit/uicolor/3238040-colorwithdynamicprovider
// - Asset Catalogs (color mgmt): https://developer.apple.com/documentation/xcode/asset-catalogs
// - ColorPicker (SwiftUI): https://developer.apple.com/documentation/swiftui/colorpicker
// - UIWhitePointAdaptivityStyle (iOS/tvOS): https://developer.apple.com/documentation/uikit/uiwhitepointadaptivitystyle
// - Materials / Liquid Glass: https://developer.apple.com/design/human-interface-guidelines/materials
// - Dark Mode: https://developer.apple.com/design/human-interface-guidelines/dark-mode
//
// Domain Map (keep in sync with ColorArticle.md & ColorIndex.md)
// - Roles & Tokens: ColorTokens.swift
// - Resolvers: ColorRoles.swift
// - Contrast: ColorContrastHelper.swift
// - Color Mgmt (sRGB/P3/White point): ColorManagement.swift
// - Liquid Glass guidance: LiquidGlassGuidance.swift
// - System bridges: SystemColorsBridge.swift
// - Picker: ColorPickerSupport.swift
// - Platform specs (optional): PlatformColorSpecs.swift
// - Testing: ColorTestingToolkit.swift
//
// MARK: - 1. ColorTokens.swift
/// # ColorTokens
///
/// Defines the semantic color roles and theme tokens for brand/system mapping.
///
/// Models
/// - Enums
///   - ColorRole: accent, background, surface, textPrimary, textSecondary, success, warning, destructive, separator, link
/// - Structs
///   - ColorToken: role, light, dark, hcLight, hcDark, p3Light?, p3Dark?
///   - ColorTheme: name, tokens: [ColorRole: ColorToken]
///
/// Utilities
/// - Structs
///   - ColorTokens (static registries, default theme)
///
/// Variables/Properties
/// - ColorTokens.brandDefault: ColorTheme
///
/// Functions
/// - ColorTokens.token(for:in:) -> ColorToken?
///
/// MARK: - 2. ColorRoles.swift
/// # ColorRoles
///
/// Resolves a `ColorRole` into a platform color (SwiftUI `Color`, `UIColor`, or `NSColor`),
/// honoring light/dark and Increased Contrast.
///
/// Utilities
/// - Structs
///   - ColorRoles
///
/// Variables/Properties
/// - ColorRoles.currentTheme: ColorTheme
///
/// Functions
/// - color(for role: ColorRole) -> PlatformColor
/// - uiColor(for role: ColorRole) -> UIColor
/// - nsColor(for role: ColorRole) -> NSColor
/// - dynamicProvider(light:dark:hcLight:hcDark:) -> PlatformColor
///
/// MARK: - 3. ColorContrastHelper.swift
/// # ColorContrastHelper
///
/// Computes contrast ratios and pass/fail for AA/AAA, with helpers for adjustment.
///
/// Models
/// - Structs
///   - ColorPair (foreground, background)
///   - ContrastResult (ratio, passesAA, passesAAA)
///
/// Utilities
/// - Structs
///   - ColorContrastHelper
///
/// Functions
/// - contrastRatio(foreground:background:) -> Double
/// - evaluate(foreground:background:) -> ContrastResult
/// - adjust(_:toMeetAAAgainst:) -> PlatformColor
///
/// MARK: - 4. ColorManagement.swift
/// # ColorManagement
///
/// Asset-catalog variants (sRGB/P3) and white-point adaptivity guidance for iOS/tvOS.
///
/// Models
/// - Enums
///   - ColorSpace: sRGB, displayP3
/// - Structs
///   - ColorAssetVariant (space, color)
///
/// Utilities
/// - Structs
///   - ColorManagement
///
/// Functions
/// - provideAssetVariants(for:) -> [ColorAssetVariant]
/// - displaySupportsWideColor() -> Bool
/// - preferredWhitePointAdaptivityStyle() -> UIWhitePointAdaptivityStyle
///
/// MARK: - 5. LiquidGlassGuidance.swift
/// # LiquidGlassGuidance
///
/// Guidance for limiting color on materials. Prefer brand color in the content layer.
///
/// Utilities
/// - Structs
///   - LiquidGlassGuidance
///
/// Functions
/// - isTintSafe(_:surfaceCategory:) -> Bool
/// - guidanceNotes(for:) -> [String]
///
/// MARK: - 6. SystemColorsBridge.swift
/// # SystemColorsBridge
///
/// Bridges to platform semantic colors (labels, separators, backgrounds, links).
///
/// Utilities
/// - Structs
///   - SystemColorsBridge
///
/// Functions
/// - label()/secondaryLabel()/tertiaryLabel()/quaternaryLabel() -> PlatformColor
/// - link() -> PlatformColor
/// - separator()/opaqueSeparator() -> PlatformColor
/// - systemBackground()/secondarySystemBackground()/tertiarySystemBackground() -> PlatformColor
/// - systemGroupedBackground()/secondarySystemGroupedBackground()/tertiarySystemGroupedBackground() -> PlatformColor
///
/// MARK: - 7. ColorPickerSupport.swift
/// # ColorPickerSupport
///
/// SwiftUI color picker wrappers and persistence hooks.
///
/// Views
/// - SwiftUI
///   - ThemedColorPicker (binding, role, persistenceKey)
///
/// Utilities
/// - Structs
///   - ColorPickerSupport
///
/// MARK: - 8. PlatformColorSpecs.swift
/// # PlatformColorSpecs
///
/// Optional documentation/QA tables for foreground/background specs by platform.
///
/// MARK: - 9. ColorTestingToolkit.swift
/// # ColorTestingToolkit
///
/// Snapshot/testing helpers for appearances, color spaces, and Dynamic Type.
///
/// Utilities
/// - Structs
///   - ColorTestingToolkit
///
/// Functions
/// - assertAA(for:) / snapshotAppearances(for:) / sweepDynamicType(for:)
