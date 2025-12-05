//
//  DarkMode.swift
//  Doc-style index for the Dark Mode module (platform differences + APIs)
//
//  NOTE: This file intentionally contains only doc comments and MARK separators.
//  Replace placeholders with app-specific code when integrating.
//
// References (HIG & Docs)
// - Dark Mode (HIG): https://developer.apple.com/design/human-interface-guidelines/dark-mode
// - Related HIG: Color, Materials, Typography
// - SF Symbols: https://developer.apple.com/design/human-interface-guidelines/sf-symbols
// - UIKit UIColor (dynamic, semantic): https://developer.apple.com/documentation/uikit/uicolor
// - AppKit NSColor (labelColor/controlColor): https://developer.apple.com/documentation/appkit/nscolor
// - Asset Catalogs (variants): https://developer.apple.com/documentation/xcode/asset-catalogs
//
// Domain Map (keep in sync with DarkModeArticle.md & DarkModeIndex.md)
// - Core helpers: DarkModeSupport.swift
// - Colors: DarkModeColors.swift
// - Icons & Images: DarkModeIconsAndImages.swift
// - Text: DarkModeText.swift
// - Platform notes: DarkModePlatformNotes.swift
// - Testing: DarkModeTestingToolkit.swift
//
// MARK: - 1. DarkModeSupport.swift
/// # DarkModeSupport
///
/// Central helpers for querying the current appearance (light/dark/auto),
/// checking Increased Contrast and Reduce Transparency, and resolving
/// **elevation** (base vs elevated backgrounds on iOS/iPadOS).
///
/// Models
/// - Enums
///   - AppearanceMode: light, dark, auto
///   - ElevationLevel: base, elevated
/// - Structs
///   - DarkModePolicy: followSystem, softenWhiteAssets, minimumContrast
///
/// Utilities
/// - Structs
///   - DarkModeSupport
///
/// Functions
/// - currentAppearance() -> AppearanceMode
/// - isHighContrastEnabled() -> Bool
/// - isReduceTransparencyEnabled() -> Bool
/// - elevatedBackground(for:) -> PlatformColor
//
// MARK: - 2. DarkModeColors.swift
/// # DarkModeColors
///
/// Bridges to platform semantic colors (labels, links, backgrounds, separators)
/// and provides dynamic custom color creation with light/dark (+ high-contrast) variants.
///
/// Utilities
/// - Structs
///   - DarkModeColors
///
/// Functions
/// - primaryLabel()/secondaryLabel()/tertiaryLabel()/quaternaryLabel() -> PlatformColor
/// - link() -> PlatformColor
/// - separator()/opaqueSeparator() -> PlatformColor
/// - systemBackground()/secondarySystemBackground()/tertiarySystemBackground() -> PlatformColor
/// - elevatedBackground() -> PlatformColor (iOS/iPadOS)
/// - dynamicCustom(light:dark:) -> PlatformColor
//
// MARK: - 3. DarkModeIconsAndImages.swift
/// # DarkModeIconsAndImages
///
/// SF Symbols-first approach; fall back to per-appearance image assets when needed.
/// Includes softening pure-white backgrounds for images in Dark Mode.
///
/// Models
/// - Structs
///   - ImageVariantPolicy: hasLight, hasDark, softenWhiteInDark
///
/// Utilities
/// - Structs
///   - DarkModeIconsAndImages
///
/// Functions
/// - symbol(name:) -> Image
/// - image(named:policy:) -> Image
/// - softenedWhiteBackground(_:) -> Image
//
// MARK: - 4. DarkModeText.swift
/// # DarkModeText
///
/// Uses system label colors and text views that adapt to vibrancy and contrast.
///
/// Utilities
/// - Structs
///   - DarkModeText
///
/// Functions
/// - textColorPrimary() -> PlatformColor
/// - configureTextViewForVibrancy(_:) -> Void
//
// MARK: - 5. DarkModePlatformNotes.swift
/// # DarkModePlatformNotes
///
/// Platform-specific guidance:
/// - iOS/iPadOS: base vs **elevated** backgrounds (system-managed depth cues).
/// - macOS: **desktop tinting** when accent is graphite; add transparency to **neutral** components only.
/// - tvOS: no additional Dark Mode considerations beyond general guidance.
/// - visionOS/watchOS: Dark Mode **not supported**.
//
// MARK: - 6. DarkModeTestingToolkit.swift
/// # DarkModeTestingToolkit
///
/// Snapshot Light/Dark/Auto, verify contrast targets, and test Increased Contrast
/// + Reduce Transparency combinations.
///
/// Utilities
/// - Structs
///   - DarkModeTestingToolkit
///
/// Functions
/// - snapshotAppearances(for:) // Light/Dark/Auto
/// - runContrastChecks(pairs:)
/// - verifyAccessibilityCombos()
