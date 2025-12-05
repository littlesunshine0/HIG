# Materials Module Index (Table of Contents)

This index catalogs the **Materials** module by files and types. Each entry lists **Models**, **Views**, **View Models**, **Utilities/Managers**, **Protocols**, then **Variables/Properties** and **Functions** grouped by their owning type so nothing is missed.

1. MaterialTokens.swift
- Models
  - Enums
    - LiquidGlassVariant (regular, clear)
    - StandardMaterial (ultraThin, thin, regular, thick)
    - VibrancyLevelLabel (label, secondaryLabel, tertiaryLabel, quaternaryLabel)
    - VibrancyLevelFill (fill, secondaryFill, tertiaryFill)
    - SeparatorVibrancy (default)
- Utilities / Managers
  - Structs
    - MaterialTokens
- Variables/Properties
  - MaterialTokens
    - defaultGlass: LiquidGlassVariant = .regular
    - defaultMaterial: StandardMaterial = .regular
- Functions
  - MaterialTokens
    - preferredGlass(over backgroundLuminance: CGFloat) -> LiquidGlassVariant
    - preferredStandardMaterial(for context: MaterialContext) -> StandardMaterial

2. LiquidGlassSupport.swift
- Models
  - Structs
    - GlassConfig (variant, addDimmingIfBright: Bool)
- Utilities / Managers
  - Structs
    - LiquidGlassSupport
- Functions
  - LiquidGlassSupport
    - applyRegularGlass<S: View>(_ view: S) -> some View
    - applyClearGlass<S: View>(_ view: S, dimIfBright: Bool) -> some View
    - shouldDim(for backgroundLuminance: CGFloat) -> Bool // ~35% when bright

3. StandardMaterialsSupport.swift
- Models
  - Enums
    - ContentRole (background, card, sidebar, overlay)
- Utilities / Managers
  - Structs
    - StandardMaterialsSupport
- Functions
  - StandardMaterialsSupport
    - material(for role: ContentRole) -> Material // .ultraThinMaterial/.thinMaterial/.regularMaterial/.thickMaterial
    - applyMaterial<S: View>(_ view: S, role: ContentRole) -> some View

4. VibrancyAndBlurs.swift
- Models
  - Enums
    - LabelVibrancy (label, secondaryLabel, tertiaryLabel, quaternaryLabel)
    - FillVibrancy (fill, secondaryFill, tertiaryFill)
- Utilities / Managers
  - Structs
    - VibrancyAndBlurs
- Functions
  - VibrancyAndBlurs
    - uikitVibrancy(for label: LabelVibrancy) -> UIVibrancyEffectStyle
    - uikitVibrancy(for fill: FillVibrancy) -> UIVibrancyEffectStyle
    - appKitBlendingMode(for behindWindow: Bool) -> NSVisualEffectView.BlendingMode

5. MaterialApplicators.swift
- Utilities / Managers
  - Structs
    - MaterialApplicators
- Functions
  - MaterialApplicators
    - swiftUIBackground<S: View>(_ view: S, material: Material) -> some View
    - uiKitBlur(container: UIView, style: UIBlurEffect.Style)
    - uiKitVibrancy(container: UIVisualEffectView, style: UIVibrancyEffectStyle)
    - appKitEffect(view: NSVisualEffectView, material: NSVisualEffectView.Material, blending: NSVisualEffectView.BlendingMode)

6. MaterialAccessibilityBridge.swift
- Utilities / Managers
  - Structs
    - MaterialA11y
- Functions
  - MaterialA11y
    - enforceVibrantForegrounds() // prefer system vibrant colors for labels/fills
    - verifyContrast(on images: [UIImage]) -> [Double]
    - avoidOveruseOfGlass(in views: [AnyView]) -> [String]

7. MaterialTestingToolkit.swift
- Utilities / Managers
  - Structs
    - MaterialTestingToolkit
- Functions
  - MaterialTestingToolkit
    - runAll()
    - snapshotOverBackgrounds(_ samples: [UIImage]) -> [SnapshotResult]
    - auditVibrancyChoices() -> [String]
    - checkDimmingRules() -> [String]

8. MaterialPlatformNotes.swift
- Models
  - Structs
    - PlatformMaterialNotes (platform, notes)
- Variables/Properties
  - Globals
    - iOSiPadOSNotes: PlatformMaterialNotes
    - macOSNotes: PlatformMaterialNotes
    - tvOSNotes: PlatformMaterialNotes
    - visionOSNotes: PlatformMaterialNotes
    - watchOSNotes: PlatformMaterialNotes
- Functions
  - None (data only)

---

**Notes**
- Use Liquid Glass only for chrome; prefer standard materials in content.
- Pair materials with **vibrant** foregrounds; avoid quaternary label over thin/ultraThin.
- Add ~35% dark dimming behind **clear** glass over bright media.

*↑ Back to Materials Article*
