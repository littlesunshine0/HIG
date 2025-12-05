

# Icons Module Index (Table of Contents)

This index catalogs the **Icons** module by files and types. Each entry lists **Models**, **Views**, **View Models**, **Utilities/Managers**, **Protocols**, then **Variables/Properties** and **Functions** grouped by the owning type so nothing is missed.

1. IconTokens.swift
- Models
  - Enums
    - IconRole (navigation, toolbar, list, action, selection, status)
    - IconScale (small, medium, large)
    - IconWeightHint (thin, regular, semibold, bold)
  - Structs
    - IconToken (role, basePointSize, defaultWeightHint, defaultPadding, opticalCenter)
- Utilities / Managers
  - Structs
    - IconTokens (registries, defaults)
- Protocols
  - IconTokenProviding
- Variables/Properties
  - IconToken
    - role: IconRole
    - basePointSize: CGFloat
    - defaultWeightHint: IconWeightHint
    - defaultPadding: EdgeInsets
    - opticalCenter: CGPoint
  - IconTokens
    - defaultSet: [IconRole: IconToken]
- Functions
  - IconTokens
    - token(for role: IconRole) -> IconToken
    - register(_ token: IconToken)

2. IconRoles.swift
- Models
  - Typealiases
    - PlatformImage = SwiftUI.Image / UIImage / NSImage
  - Structs
    - IconMapping (role, primarySymbol, fallbackSymbol?, customAssetName?)
- Utilities / Managers
  - Structs
    - IconRoles (role→symbol/asset mapping)
- Variables/Properties
  - IconRoles
    - mappings: [IconRole: IconMapping]
- Functions
  - IconRoles
    - image(for role: IconRole) -> PlatformImage
    - symbolName(for role: IconRole) -> String?
    - fallbackSymbolName(for role: IconRole) -> String?
    - customAssetName(for role: IconRole) -> String?

3. SFIconsIntegration.swift
- Models
  - Enums
    - IconRendering (monochrome, multicolor, hierarchical, palette)
  - Structs
    - SymbolConfig (name, weight: Font.Weight?, scale: Image.Scale?, rendering: IconRendering)
- Utilities / Managers
  - Structs
    - SFIconsIntegration
- Variables/Properties
  - SymbolConfig
    - name: String
    - weight: Font.Weight?
    - scale: Image.Scale?
    - rendering: IconRendering
- Functions
  - SFIconsIntegration
    - symbol(_ config: SymbolConfig) -> Image
    - renderingMode(_ rendering: IconRendering) -> some View
    - pointSizeMatchingText(_ textStyle: Font.TextStyle) -> CGFloat
    - variableValue(for emphasis: Double) -> Double // 0…1 for variable symbols

4. IconSetBuilder.swift
- Models
  - Structs
    - OpticalPaddingRule (top, leading, bottom, trailing)
- Utilities / Managers
  - Structs
    - IconSetBuilder
- Variables/Properties
  - OpticalPaddingRule
    - top: CGFloat
    - leading: CGFloat
    - bottom: CGFloat
    - trailing: CGFloat
- Functions
  - IconSetBuilder
    - normalizeStrokeAndSize(for images: [Image]) -> [Image]
    - opticalPadding(_ image: Image, rule: OpticalPaddingRule) -> Image
    - alignToCapHeight(_ image: Image, adjacentTextStyle: Font.TextStyle) -> Image
    - snapToPixelGrid(_ image: Image) -> Image

5. IconAssets.swift
- Models
  - Enums
    - AssetFormat (pdf, svg)
  - Structs
    - IconVariant (name, isSelectedState, rtlMirrored)
- Utilities / Managers
  - Structs
    - IconAssets
- Variables/Properties
  - IconVariant
    - name: String
    - isSelectedState: Bool
    - rtlMirrored: Bool
- Functions
  - IconAssets
    - loadVector(name: String, format: AssetFormat = .pdf) -> Image
    - renderingMode(for role: IconRole) -> SymbolRenderingMode
    - selectedVariantNeeded(in component: IconHostingComponent) -> Bool
    - rtlMirroredNameIfNeeded(_ name: String) -> String

6. IconAccessibility.swift
- Models
  - Structs
    - IconA11y (label, isDecorative, rtlMirrored)
- Utilities / Managers
  - Structs
    - IconAccessibility
- Variables/Properties
  - IconA11y
    - label: String
    - isDecorative: Bool
    - rtlMirrored: Bool
- Functions
  - IconAccessibility
    - apply(label: String, to view: PlatformView)
    - markDecorative(_ view: PlatformView)
    - localizeCharactersIfPresent(in name: String) -> String
    - shouldFlipForRTL(_ role: IconRole) -> Bool
    - accessibilityTraits(for role: IconRole) -> AccessibilityTraits

7. IconPlatformNotes.swift
- Models
  - Structs
    - DocumentIconSpec (backgroundSizes, centerImageSizes, marginPercent)
- Utilities / Managers
  - Structs
    - IconPlatformNotes
- Variables/Properties
  - DocumentIconSpec
    - backgroundSizes: [CGSize] // 512, 256, 128, 32, 16 (+ @2x)
    - centerImageSizes: [CGSize] // ~50% of canvas with ~10% margins
    - marginPercent: Double // ~10.0
- Functions
  - IconPlatformNotes
    - macOSDocumentSpec() -> DocumentIconSpec
    - shouldAvoidTopRightOverlay() -> Bool // folded-corner area

8. IconTestingToolkit.swift
- Utilities / Managers
  - Structs
    - IconTestingToolkit
- Functions
  - IconTestingToolkit
    - snapshotRoles(_ roles: [IconRole]) -> Void
    - verifyOpticalCentering(_ image: Image) -> Bool
    - assertWeightMatchesText(_ image: Image, textStyle: Font.TextStyle) -> Void
    - runContrastChecks(in contexts: [IconContext]) -> Void
    - snapshotRTL(_ roles: [IconRole]) -> Void

---

**Notes**
- Prefer **SF Symbols**; use custom vectors (PDF/SVG) only when needed.
- Keep icon weight aligned with adjacent text; apply optical padding for asymmetric glyphs.
- Selected-state variants are rarely needed; system components derive selected visuals.
- Provide VoiceOver labels for custom glyphs; localize characters; flip direction-sensitive icons in RTL.
- **macOS document icons**: supply size matrix and avoid the folded-corner overlay area.

*↑ Back to Icons Article*
