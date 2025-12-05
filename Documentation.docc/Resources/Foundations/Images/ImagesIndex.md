# Images Module Index (Table of Contents)

This index catalogs the **Images** module by files and types. Each entry lists **Models**, **Views**, **View Models**, **Utilities/Managers**, **Protocols**, then **Variables/Properties** and **Functions** grouped by the owning type so nothing is missed.

1. ImageAssets.swift
- Models
  - Enums
    - AssetFormat (pdf, svg, png)
    - ScaleFactor (@1x, @2x, @3x)
    - ColorSpace (sRGB, displayP3)
  - Structs
    - ImageAssetSpec (name, format, colorSpace, idioms: [Idiom], providesLightDarkVariants, providesHighContrastVariant)
- Utilities / Managers
  - Structs
    - ImageAssets
- Variables/Properties
  - ImageAssetSpec
    - name: String
    - format: AssetFormat
    - colorSpace: ColorSpace
    - idioms: [Idiom]
    - providesLightDarkVariants: Bool
    - providesHighContrastVariant: Bool
- Functions
  - ImageAssets
    - loadImage(name: String) -> PlatformImage
    - loadVector(name: String, format: AssetFormat = .pdf) -> PlatformImage
    - pickScale(for targetPoints: CGFloat) -> ScaleFactor
    - renderingModeTemplate(for role: ImageRole) -> Bool

2. InterfaceIconGuidance.swift
- Models
  - Enums
    - IconWeightMatchPolicy (matchText, custom)
  - Structs
    - OpticalCenterOffset (dx, dy)
- Utilities / Managers
  - Structs
    - InterfaceIconGuidance
- Variables/Properties
  - OpticalCenterOffset
    - dx: CGFloat
    - dy: CGFloat
- Functions
  - InterfaceIconGuidance
    - matchedWeight(for textStyle: Font.TextStyle) -> Font.Weight
    - opticalPadding(for image: PlatformImage) -> EdgeInsets
    - needsSelectedVariant(in component: IconHostingComponent) -> Bool

3. SFSymbolsBridge.swift
- Models
  - Enums
    - IconRendering (monochrome, multicolor, hierarchical, palette)
  - Structs
    - SymbolConfig (name, weight: Font.Weight?, scale: Image.Scale?, rendering: IconRendering)
- Utilities / Managers
  - Structs
    - SFSymbolsBridge
- Variables/Properties
  - SymbolConfig
    - name: String
    - weight: Font.Weight?
    - scale: Image.Scale?
    - rendering: IconRendering
- Functions
  - SFSymbolsBridge
    - symbol(_ config: SymbolConfig) -> Image
    - renderingMode(_ rendering: IconRendering) -> some View
    - pointSizeMatchingText(_ textStyle: Font.TextStyle) -> CGFloat

4. ImageAccessibility.swift
- Models
  - Structs
    - ImageA11y (label, isDecorative, containsText)
- Utilities / Managers
  - Structs
    - ImageAccessibility
- Variables/Properties
  - ImageA11y
    - label: String
    - isDecorative: Bool
    - containsText: Bool
- Functions
  - ImageAccessibility
    - apply(label: String, to view: PlatformView)
    - markDecorative(_ view: PlatformView)
    - traits(for role: ImageRole) -> AccessibilityTraits

5. ImageLocalization.swift
- Utilities / Managers
  - Structs
    - ImageLocalization
- Functions
  - ImageLocalization
    - localizeCharactersIfPresent(in name: String, locale: Locale) -> String
    - shouldFlipForRTL(_ imageName: String) -> Bool

6. macOSDocumentIcons.swift
- Models
  - Structs
    - DocumentIconSpec (backgroundSizes, centerImageSizes, marginPercent)
- Utilities / Managers
  - Structs
    - macOSDocumentIcons
- Variables/Properties
  - DocumentIconSpec
    - backgroundSizes: [CGSize] // required size matrix
    - centerImageSizes: [CGSize] // half the canvas
    - marginPercent: Double // ~10.0
- Functions
  - macOSDocumentIcons
    - spec() -> DocumentIconSpec
    - avoidTopRightOverlay() -> Bool

7. ImagesPlatformNotes.swift
- Models
  - Structs
    - PlatformImageNotes (platform, notes)
- Variables/Properties
  - Globals
    - iOSiPadOSNotes: PlatformImageNotes (no additional considerations)
    - tvOSNotes: PlatformImageNotes (ensure focus legibility; no special variants)
    - visionWatchNotes: PlatformImageNotes (no additional considerations)
    - macOSNotes: PlatformImageNotes (document icons support)
- Functions
  - None (data‑only surface)

8. ImageTestingToolkit.swift
- Utilities / Managers
  - Structs
    - ImageTestingToolkit
- Functions
  - ImageTestingToolkit
    - snapshotRoles(_ roles: [ImageRole]) -> Void
    - verifyOpticalCentering(_ image: PlatformImage) -> Bool
    - assertWeightMatchesText(_ image: PlatformImage, textStyle: Font.TextStyle) -> Void
    - runContrastChecks(in contexts: [ImageContext]) -> Void
    - snapshotRTL(_ roles: [ImageRole]) -> Void

---

**Notes**
- Prefer **SF Symbols**; use custom vectors (PDF/SVG) only when needed.
- Keep icon weight aligned with adjacent text; apply optical padding for asymmetric glyphs.
- Selected‑state variants are rarely needed in standard components; the system handles it.
- Provide VoiceOver labels for custom glyphs; localize characters; flip direction‑sensitive icons in RTL.
- **macOS document icons**: supply the size matrix and avoid the folded‑corner overlay area.

*↑ Back to Images Article*
