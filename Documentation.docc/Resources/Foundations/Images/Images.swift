//
//  Images.swift
//  Doc-style index for the Interface Images module (icons/glyphs, assets, macOS document icons)
//
//  NOTE: This file intentionally contains only doc comments and MARK separators.
//  Replace placeholders with app-specific code when integrating.
//
// References (HIG & Docs)
// - Images (Icons): https://developer.apple.com/design/human-interface-guidelines/images
// - SF Symbols (HIG): https://developer.apple.com/design/human-interface-guidelines/sf-symbols
// - Icons (HIG): https://developer.apple.com/design/human-interface-guidelines/icons
// - App Icons (HIG): https://developer.apple.com/design/human-interface-guidelines/app-icons
// - Inclusion (HIG): https://developer.apple.com/design/human-interface-guidelines/inclusion
// - Right to left (HIG): https://developer.apple.com/design/human-interface-guidelines/right-to-left
// - VoiceOver (HIG): https://developer.apple.com/design/human-interface-guidelines/voiceover
// - Apple Design Resources (macOS templates): https://developer.apple.com/design/resources/
//
// Domain Map (keep in sync with ImagesArticle.md & ImagesIndex.md)
// - Assets & formats: ImageAssets.swift
// - Icon best practices: InterfaceIconGuidance.swift
// - SF Symbols helpers: SFSymbolsBridge.swift
// - Accessibility: ImageAccessibility.swift
// - Localization & RTL: ImageLocalization.swift
// - macOS document icons: macOSDocumentIcons.swift
// - Platform notes: ImagesPlatformNotes.swift
// - Testing & CI: ImageTestingToolkit.swift
//
// MARK: - 1. ImageAssets.swift
/// # ImageAssets
///
/// Loads vector/raster assets (PDF/SVG/PNG), manages rendering modes, color space
/// (sRGB/P3), and scale factors (@1x/@2x/@3x) per idiom.
///
/// Models
/// - Enums
///   - AssetFormat: pdf, svg, png
///   - ScaleFactor: @1x, @2x, @3x
///   - ColorSpace: sRGB, displayP3
/// - Structs
///   - ImageAssetSpec: name, format, colorSpace, idioms, providesLightDarkVariants, providesHighContrastVariant
///
/// Utilities
/// - Structs
///   - ImageAssets
///
/// Functions
/// - loadImage(name:) -> PlatformImage
/// - loadVector(name:format:) -> PlatformImage
/// - pickScale(for:) -> ScaleFactor
/// - renderingModeTemplate(for:) -> Bool
//
// MARK: - 2. InterfaceIconGuidance.swift
/// # InterfaceIconGuidance
///
/// Best practices for recognizable, simplified icons; consistency; weight matching;
/// optical centering; and selected-state handling.
///
/// Models
/// - Enums
///   - IconWeightMatchPolicy: matchText, custom
/// - Structs
///   - OpticalCenterOffset: dx, dy
///
/// Utilities
/// - Structs
///   - InterfaceIconGuidance
///
/// Functions
/// - matchedWeight(for:) -> Font.Weight
/// - opticalPadding(for:) -> EdgeInsets
/// - needsSelectedVariant(in:) -> Bool
//
// MARK: - 3. SFSymbolsBridge.swift
/// # SFSymbolsBridge
///
/// Helpers for scale/weight/variable rendering modes and matching point size to text.
///
/// Models
/// - Enums
///   - IconRendering: monochrome, multicolor, hierarchical, palette
/// - Structs
///   - SymbolConfig: name, weight, scale, rendering
///
/// Utilities
/// - Structs
///   - SFSymbolsBridge
///
/// Functions
/// - symbol(_:) -> Image
/// - renderingMode(_:) -> some View
/// - pointSizeMatchingText(_:) -> CGFloat
//
// MARK: - 4. ImageAccessibility.swift
/// # ImageAccessibility
///
/// Alternative text labels for custom glyphs, decorative flags, and traits by role.
///
/// Models
/// - Structs
///   - ImageA11y: label, isDecorative, containsText
///
/// Utilities
/// - Structs
///   - ImageAccessibility
///
/// Functions
/// - apply(label:to:) -> Void
/// - markDecorative(_:) -> Void
/// - traits(for:) -> AccessibilityTraits
//
// MARK: - 5. ImageLocalization.swift
/// # ImageLocalization
///
/// Localizes embedded characters and provides RTL-flipped variants when needed.
///
/// Utilities
/// - Structs
///   - ImageLocalization
///
/// Functions
/// - localizeCharactersIfPresent(in:locale:) -> String
/// - shouldFlipForRTL(_:) -> Bool
//
// MARK: - 6. macOSDocumentIcons.swift
/// # macOSDocumentIcons
///
/// Composites background fill, center image, and optional text into a folded-corner shape.
/// Provides the size matrix and safe areas.
///
/// Models
/// - Structs
///   - DocumentIconSpec: backgroundSizes, centerImageSizes, marginPercent
///
/// Utilities
/// - Structs
///   - macOSDocumentIcons
///
/// Functions
/// - spec() -> DocumentIconSpec
/// - avoidTopRightOverlay() -> Bool
//
// MARK: - 7. ImagesPlatformNotes.swift
/// # ImagesPlatformNotes
///
/// Platform notes: iOS/iPadOS/tvOS/visionOS/watchOS (no additional considerations);
/// macOS document icons support.
//
// MARK: - 8. ImageTestingToolkit.swift
/// # ImageTestingToolkit
///
/// Snapshots, optical-centering verification, weight-to-text matching, contrast checks,
/// and RTL sweeps.
///
/// Utilities
/// - Structs
///   - ImageTestingToolkit
///
/// Functions
/// - snapshotRoles(_:) -> Void
/// - verifyOpticalCentering(_:) -> Bool
/// - assertWeightMatchesText(_:textStyle:) -> Void
/// - runContrastChecks(in:) -> Void
/// - snapshotRTL(_:) -> Void
