# Branding Module Index (Table of Contents)

This index provides a quick, hierarchical overview of the **Branding** module and its **submodules**. It doubles as a breadcrumb so anyone can drill down and jump back up fast. Each file is broken down by **Models**, **Views**, **View Models**, **Utilities/Managers**, **Protocols/Modifiers**, and then explicitly lists all **Variables/Properties** and **Functions** grouped by their owning type.

> Quick nav: [Core Files](#core-files-already-in-repo) · [BrandColor](#brandcolor) · [BrandTypography](#brandtypography) · [BrandAccessibility](#brandaccessibility) · [BrandMaterials](#brandmaterials-liquid-glass) · [BrandMotion](#brandmotion--haptics) · [BrandDarkMode](#branddarkmode) · [BrandAssets](#brandassets) · [BrandComponents](#brandcomponents) · [BrandTesting](#brandtesting)

---

## Core Files (Already in repo)

1. **BrandManager.swift**
- Models
  - Enums
    - BrandAppearance (light, dark, highContrastLight, highContrastDark)
- Views
  - None
- View Models
  - Classes
    - BrandManager (ObservableObject)
- Utilities / Managers
  - Classes
    - BrandManager
- Environment
  - Keys
    - EnvironmentValues.brandTheme (BrandTheme)
- Variables/Properties
  - BrandManager
    - theme: BrandTheme
    - respectSystemAccent: Bool
    - effectiveAccentColor: Color
- Functions
  - BrandManager
    - apply(_ theme: BrandTheme)
    - toggleRespectSystemAccent()

2. **BrandTokens.swift**
- Models
  - Structs
    - BrandTheme (accent, background, surface, textPrimary, textSecondary, success, warning, destructive, display, title, headline, body, caption, cornerRadius, buttonPadding)
    - BrandShadows (subtle, raised, pop)
  - Enums
    - ColorRole (accent, background, surface, textPrimary, textSecondary, success, warning, destructive)
    - TypeRole (display, title, headline, body, caption)
- Utilities
  - Structs
    - BrandColorTokens (lookup by ColorRole)
    - BrandTypeTokens (lookup by TypeRole)
- Variables/Properties
  - BrandTheme
    - accent: Color
    - background: Color
    - surface: Color
    - textPrimary: Color
    - textSecondary: Color
    - success: Color
    - warning: Color
    - destructive: Color
    - display: Font
    - title: Font
    - headline: Font
    - body: Font
    - caption: Font
    - cornerRadius: CGFloat
    - buttonPadding: CGFloat
  - BrandShadows
    - subtle: (radius, x, y, opacity)
    - raised: (radius, x, y, opacity)
    - pop: (radius, x, y, opacity)
- Functions
  - BrandColorTokens
    - color(for role: ColorRole) -> Color
  - BrandTypeTokens
    - font(for role: TypeRole) -> Font

3. **BrandColorSystem.swift**
- Models
  - Structs
    - ColorPair (foreground, background)
    - ContrastResult (ratio: Double, passesAA: Bool)
    - ColorAppearanceVariant (light, dark, highContrastLight, highContrastDark)
  - Enums
    - SystemColorFamily (backgrounds, groupedBackgrounds, labels, separators, links, grays)
    - MaterialContext (glassSmall, glassLarge, contentLayer)
    - ColorSpaceKind (sRGB, displayP3)
- Views (Optional)
  - ContrastBadgeView (shows pass/fail for AA)
- View Models (Optional)
  - ContrastInspectorViewModel
- Utilities
  - Structs
    - BrandColorSystem
- Variables/Properties
  - ColorPair
    - foreground: Color
    - background: Color
  - ContrastResult
    - ratio: Double
    - passesAA: Bool
  - BrandColorSystem
    - currentAppearance: ColorAppearanceVariant
    - preferredColorSpace: ColorSpaceKind
- Functions
  - ContrastInspectorViewModel
    - evaluate()
  - BrandColorSystem
    - systemColor(family: SystemColorFamily, role: String) -> Color
    - brandColor(for role: ColorRole, appearance: ColorAppearanceVariant) -> Color
    - contrastRatio(foreground: Color, background: Color) -> Double
    - passesAA(foreground: Color, background: Color) -> Bool
    - isSafeInLiquidGlass(context: MaterialContext, color: Color) -> Bool
    - colorSpaceAdjusted(_ color: Color, to: ColorSpaceKind) -> Color
    - provideAssetVariants(sRGB: Color, p3: Color) -> [ColorSpaceKind: Color]

4. **BrandColorManagement.swift**
- Models
  - Structs
    - ColorAssetProfile (name, colorSpace, hasHighContrastVariant)
- Utilities
  - Structs
    - BrandColorManagement
- Variables/Properties
  - ColorAssetProfile
    - name: String
    - colorSpace: ColorSpaceKind
    - hasHighContrastVariant: Bool
- Functions
  - BrandColorManagement
    - register(asset: ColorAssetProfile)
    - preferredWhitePointAdaptivityStyle(for content: String) -> UIWhitePointAdaptivityStyle? (iOS/tvOS)
    - suggestGradientStops(for colorSpace: ColorSpaceKind) -> [Color]
    - shouldProvideSeparateP3Asset(for gradient: Bool) -> Bool

5. **BrandTypographySupport.swift**
- Models
  - Structs
    - BrandFontSpec (family, name, supportsDynamicType)
  - Enums
    - TypeRole (display, title, headline, body, caption)
- Utilities
  - Structs
    - BrandTypographySupport
- Variables/Properties
  - BrandFontSpec
    - family: String
    - name: String
    - supportsDynamicType: Bool
- Functions
  - BrandTypographySupport
    - font(for role: TypeRole, weight: Font.Weight?) -> Font
    - scaled(_ font: Font, for category: DynamicTypeSize) -> Font

6. **BrandAccessibilityBridge.swift**
- Models
  - Structs
    - A11yBrandPolicy (minContrast, allowColorOnlyMeaning)
- Utilities
  - Structs
    - BrandAccessibilityBridge
- Variables/Properties
  - A11yBrandPolicy
    - minContrast: Double
    - allowColorOnlyMeaning: Bool
- Functions
  - BrandAccessibilityBridge
    - enforceContrast(_ pair: ColorPair) -> Bool
    - announceBrandEvent(_ message: String)
    - motionPolicy() -> MotionPolicy

7. **BrandMaterials.swift**
- Models
  - Enums
    - MaterialSurface (small, large, contentLayer)
- Views
  - None
- Utilities
  - Structs
    - BrandMaterials
- Variables/Properties
  - BrandMaterials
    - preferredTintFor(surface: MaterialSurface) -> Color
- Functions
  - BrandMaterials
    - isTintSafe(_ color: Color, on surface: MaterialSurface) -> Bool
    - guidance(for surface: MaterialSurface) -> String

8. **BrandMotionAndHaptics.swift**
- Models
  - Structs
    - MotionSpec (curve, duration, emphasis)
    - HapticSpec (intensity, sharpness, duration)
- Views
  - None
- Utilities
  - Structs
    - BrandMotion
- Functions
  - BrandMotion
    - subtle() -> Animation
    - emphasized() -> Animation
    - reducedIfNeeded(_ animation: Animation) -> Animation

9. **BrandDarkModeSupport.swift**
- Models
  - Structs
    - DarkModeAudit (issuesFound, suggestions)
- Views
  - None
- Utilities
  - Structs
    - BrandDarkModeSupport
- Functions
  - BrandDarkModeSupport
    - auditAssets() -> DarkModeAudit
    - suggestAlternates(for color: Color) -> [Color]
    - snapshotComparisons() -> [Image]

10. **BrandAssets.swift**
- Models
  - Structs
    - BrandAsset (name, kind)
  - Enums
    - AssetKind (logoMark, wordmark, illustration)
- Views
  - None
- Utilities
  - Structs
    - BrandAssets
- Variables/Properties
  - BrandAsset
    - name: String
    - kind: AssetKind
- Functions
  - BrandAssets
    - loadMark(named:) -> Image?
    - loadWordmark(named:) -> Image?
    - image(named:) -> Image?

11. **BrandComponents.swift**
- Models
  - None
- Views (SwiftUI)
  - BrandBanner (title, subtitle, icon)
  - BrandedHeader (title, subtitle, accessory)
- Styles / Modifiers
  - BrandButtonStyle (theme)
- Variables/Properties
  - BrandButtonStyle
    - theme: BrandTheme
- Functions
  - BrandedHeader
    - body -> some View
  - BrandButtonStyle
    - makeBody(content:) -> some View

12. **BrandTestingToolkit.swift**
- Models
  - None
- Views (Optional)
  - BrandSnapshotGrid (light/dark/high-contrast; sRGB/P3)
- Utilities
  - Structs
    - BrandTestingToolkit
- Functions
  - BrandTestingToolkit
    - assertContrast(_ pair: ColorPair) -> Bool
    - snapshotKeyScreens() -> [Image]
    - exerciseDynamicTypeScales()

---

## Submodules & Breadcrumbs

Each submodule gets its own **Article** (concepts/how‑to), **Index** (API TOC), and related **Swift** files. These document files are planned additions and referenced here for clarity.

### BrandColor
**Breadcrumb:** Branding → BrandColor → (files below) · **Back:** [Core Files](#core-files-already-in-repo)

- Docs
  - BrandColorArticle.md *(concepts, best practices, color spaces, Liquid Glass usage)*
  - BrandColorIndex.md *(TOC mirroring below API entries)*
- Swift
  - BrandColorSystem.swift (see Core Files §3)
  - BrandColorManagement.swift (see Core Files §4)
  - BrandTokens.swift (color roles; see Core Files §2)
- Variables/Properties (key types)
  - ColorPair.foreground: Color
  - ColorPair.background: Color
  - BrandColorSystem.currentAppearance: ColorAppearanceVariant
  - BrandColorSystem.preferredColorSpace: ColorSpaceKind
- Functions (key)
  - BrandColorSystem.brandColor(for:appearance:) -> Color
  - BrandColorSystem.contrastRatio(foreground:background:) -> Double
  - BrandColorSystem.passesAA(foreground:background:) -> Bool
  - BrandColorManagement.preferredWhitePointAdaptivityStyle(for:) -> UIWhitePointAdaptivityStyle?

### BrandTypography
**Breadcrumb:** Branding → BrandTypography → … · **Back:** [Core Files](#core-files-already-in-repo)

- Docs
  - BrandTypographyArticle.md
  - BrandTypographyIndex.md
- Swift
  - BrandTypographySupport.swift (see Core Files §5)
  - BrandTokens.swift (type roles; see Core Files §2)
- Variables/Properties
  - BrandFontSpec.family/name/supportsDynamicType
  - Typography roles: display/title/headline/body/caption (Font)
- Functions
  - BrandTypographySupport.font(for:weight:) -> Font
  - BrandTypographySupport.scaled(_:for:) -> Font

### BrandAccessibility
**Breadcrumb:** Branding → BrandAccessibility → … · **Back:** [Core Files](#core-files-already-in-repo)

- Docs
  - BrandAccessibilityArticle.md
  - BrandAccessibilityIndex.md
- Swift
  - BrandAccessibilityBridge.swift (see Core Files §6)
- Variables/Properties
  - A11yBrandPolicy.minContrast / allowColorOnlyMeaning
- Functions
  - BrandAccessibilityBridge.enforceContrast(_:) -> Bool
  - BrandAccessibilityBridge.motionPolicy() -> MotionPolicy

### BrandMaterials (Liquid Glass)
**Breadcrumb:** Branding → BrandMaterials → … · **Back:** [Core Files](#core-files-already-in-repo)

- Docs
  - BrandMaterialsArticle.md
  - BrandMaterialsIndex.md
- Swift
  - BrandMaterials.swift (see Core Files §7)
- Variables/Properties
  - MaterialSurface (small, large, contentLayer)
- Functions
  - BrandMaterials.isTintSafe(_:on:) -> Bool
  - BrandMaterials.guidance(for:) -> String

### BrandMotion & Haptics
**Breadcrumb:** Branding → BrandMotion → … · **Back:** [Core Files](#core-files-already-in-repo)

- Docs
  - BrandMotionArticle.md
  - BrandMotionIndex.md
- Swift
  - BrandMotionAndHaptics.swift (see Core Files §8)
- Variables/Properties
  - MotionSpec (curve, duration, emphasis)
  - HapticSpec (intensity, sharpness, duration)
- Functions
  - BrandMotion.subtle() / emphasized() -> Animation
  - BrandMotion.reducedIfNeeded(_:) -> Animation

### BrandDarkMode
**Breadcrumb:** Branding → BrandDarkMode → … · **Back:** [Core Files](#core-files-already-in-repo)

- Docs
  - BrandDarkModeArticle.md
  - BrandDarkModeIndex.md
- Swift
  - BrandDarkModeSupport.swift (see Core Files §9)
- Variables/Properties
  - DarkModeAudit.issuesFound / suggestions
- Functions
  - BrandDarkModeSupport.auditAssets() -> DarkModeAudit
  - BrandDarkModeSupport.suggestAlternates(for:) -> [Color]

### BrandAssets
**Breadcrumb:** Branding → BrandAssets → … · **Back:** [Core Files](#core-files-already-in-repo)

- Docs
  - BrandAssetsArticle.md
  - BrandAssetsIndex.md
- Swift
  - BrandAssets.swift (see Core Files §10)
- Variables/Properties
  - BrandAsset.name / kind
- Functions
  - BrandAssets.image(named:) -> Image?

### BrandComponents
**Breadcrumb:** Branding → BrandComponents → … · **Back:** [Core Files](#core-files-already-in-repo)

- Docs
  - BrandComponentsArticle.md
  - BrandComponentsIndex.md
- Swift
  - BrandComponents.swift (see Core Files §11)
- Views
  - BrandBanner, BrandedHeader
- Modifiers / Styles
  - BrandButtonStyle
- Functions
  - BrandButtonStyle.makeBody(content:) -> some View

### BrandTesting
**Breadcrumb:** Branding → BrandTesting → … · **Back:** [Core Files](#core-files-already-in-repo)

- Docs
  - BrandTestingArticle.md
  - BrandTestingIndex.md
- Swift
  - BrandTestingToolkit.swift (see Core Files §12)
- Functions
  - BrandTestingToolkit.assertContrast(_:) -> Bool
  - BrandTestingToolkit.snapshotKeyScreens() -> [Image]

---

## TODO / Gaps to Fill

- Create per‑submodule **Article.md** and **Index.md** files referenced above (content can be split from *BrandingArticle.md*).
- Add “Back to Top” links at the end of each new doc: `↑ Back to Branding Index`.
- Wire CI to run **BrandTestingToolkit** checks (contrast, snapshots, Dynamic Type sweeps).
- Decide policy for **macOS Accent** override (`BrandManager.respectSystemAccent`).

*↑ Back to top*
