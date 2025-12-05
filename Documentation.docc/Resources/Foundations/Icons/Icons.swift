//
//  Icons.swift
//  Doc-style index for the Interface Icons module (glyphs, SF Symbols, macOS document icons)
//
//  NOTE: This file intentionally contains only doc comments and MARK separators.
//  Replace placeholders with app-specific code when integrating.
//
// References (HIG & Docs)
// - Icons (HIG): https://developer.apple.com/design/human-interface-guidelines/icons
// - SF Symbols (HIG): https://developer.apple.com/design/human-interface-guidelines/sf-symbols
// - App Icons (HIG): https://developer.apple.com/design/human-interface-guidelines/app-icons
// - Inclusion (HIG): https://developer.apple.com/design/human-interface-guidelines/inclusion
// - Right to left (HIG): https://developer.apple.com/design/human-interface-guidelines/right-to-left
// - VoiceOver (HIG): https://developer.apple.com/design/human-interface-guidelines/voiceover
// - Apple Design Resources (macOS templates): https://developer.apple.com/design/resources/
//
// Domain Map (keep in sync with IconsArticle.md & IconsIndex.md)
// - Icon tokens & roles: IconTokens.swift
// - Role→symbol mapping: IconRoles.swift
// - SF Symbols helpers: SFIconsIntegration.swift
// - Set building & optical padding: IconSetBuilder.swift
// - Vector asset loading & variants: IconAssets.swift
// - Accessibility & localization: IconAccessibility.swift
// - Platform notes (macOS document icons): IconPlatformNotes.swift
// - Testing & CI helpers: IconTestingToolkit.swift
//
// MARK: - 1. IconTokens.swift
/// # IconTokens
///
/// Semantic roles, default sizes, stroke weights, and padding rules for icons.
///
/// Models
/// - Enums
///   - IconRole: navigation, toolbar, list, action, selection, status
///   - IconScale: small, medium, large
///   - IconWeightHint: thin, regular, semibold, bold
/// - Structs
///   - IconToken: role, basePointSize, defaultWeightHint, defaultPadding
///
/// Utilities
/// - Structs
///   - IconTokens (registries, defaults)
///
/// Functions
/// - token(for:) -> IconToken
//
// MARK: - 2. IconRoles.swift
/// # IconRoles
///
/// Maps icon roles to SF Symbols or custom vector assets with platform fallbacks.
///
/// Models
/// - Structs
///   - IconMapping (role, primarySymbol, fallbackSymbol, customAssetName?)
///
/// Utilities
/// - Structs
///   - IconRoles
///
/// Functions
/// - image(for:) -> Image (SwiftUI)
/// - uiImage(for:) -> UIImage (UIKit)
/// - nsImage(for:) -> NSImage (AppKit)
//
// MARK: - 3. SFIconsIntegration.swift
/// # SFIconsIntegration
///
/// Helpers for choosing symbol scale/weight, rendering modes, and matching point sizes to text.
///
/// Utilities
/// - Structs
///   - SFIconsIntegration
///
/// Functions
/// - symbol(name:weight:scale:) -> Image
/// - renderingMode(_:) -> some View
/// - pointSizeMatchingText(_:) -> CGFloat
//
// MARK: - 4. IconSetBuilder.swift
/// # IconSetBuilder
///
/// Normalizes stroke/size across a set and applies optical padding for asymmetric glyphs.
///
/// Models
/// - Structs
///   - OpticalPaddingRule (top, leading, bottom, trailing)
///
/// Utilities
/// - Structs
///   - IconSetBuilder
///
/// Functions
/// - normalizeStrokeAndSize(for:) -> [Image]
/// - opticalPadding(_:rule:) -> Image
/// - matchWeight(to:image:) -> Image
//
// MARK: - 5. IconAssets.swift
/// # IconAssets
///
/// Vector asset loading (PDF/SVG), rendering modes, and optional state variants.
///
/// Utilities
/// - Structs
///   - IconAssets
///
/// Functions
/// - loadVector(name:) -> Image
/// - renderingMode(for:) -> SymbolRenderingMode
/// - selectedVariantNeeded(in:) -> Bool
//
// MARK: - 6. IconAccessibility.swift
/// # IconAccessibility
///
/// Accessibility labels, localization of embedded characters, and RTL flipping guidance.
///
/// Models
/// - Structs
///   - IconA11y (label, isDecorative, rtlMirrored)
///
/// Utilities
/// - Structs
///   - IconAccessibility
///
/// Functions
/// - apply(label:to:) -> Void
/// - localizeCharactersIfPresent(in:) -> String
/// - shouldFlipForRTL(_:) -> Bool
//
// MARK: - 7. IconPlatformNotes.swift
/// # IconPlatformNotes
///
/// macOS document icons (folded-corner compositing), plus general notes for other platforms.
///
/// Models
/// - Structs
///   - DocumentIconSpec (backgroundSizes, centerImageSizes, marginPercent)
///
/// Utilities
/// - Structs
///   - IconPlatformNotes
///
/// Functions
/// - macOSDocumentSpec() -> DocumentIconSpec
/// - shouldAvoidTopRightOverlay() -> Bool
//
// MARK: - 8. IconTestingToolkit.swift
/// # IconTestingToolkit
///
/// Snapshot tests, optical-centering verification, weight-to-text matching, and contrast checks.
///
/// Utilities
/// - Structs
///   - IconTestingToolkit
///
/// Functions
/// - snapshotRoles(_:) -> Void
/// - verifyOpticalCentering(_:) -> Bool
/// - assertWeightMatchesText(_:textStyle:) -> Void
/// - runContrastChecks(in:) -> Void
