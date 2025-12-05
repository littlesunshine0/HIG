# Dark Mode Module Index (Table of Contents)

This index catalogs the Dark Mode module by files and types. Each file lists Models, Views, View Models, Utilities/Managers, Protocols, and then Variables/Properties and Functions grouped by owning type.

1. DarkModeSupport.swift
- Models
  - Enums
    - AppearanceMode (light, dark, auto)
    - ElevationLevel (base, elevated)
  - Structs
    - DarkModePolicy (followSystem: Bool, softenWhiteAssets: Bool, minimumContrast: Double)
- Utilities / Managers
  - Structs
    - DarkModeSupport
- Variables/Properties
  - DarkModePolicy
    - followSystem: Bool
    - softenWhiteAssets: Bool
    - minimumContrast: Double
- Functions
  - DarkModeSupport
    - currentAppearance() -> AppearanceMode
    - isHighContrastEnabled() -> Bool
    - isReduceTransparencyEnabled() -> Bool
    - elevatedBackground(for container: Any) -> PlatformColor

2. DarkModeColors.swift
- Utilities
  - Structs
    - DarkModeColors
- Functions
  - DarkModeColors
    - primaryLabel() / secondaryLabel() / tertiaryLabel() / quaternaryLabel() -> PlatformColor
    - link() -> PlatformColor
    - separator() / opaqueSeparator() -> PlatformColor
    - systemBackground() / secondarySystemBackground() / tertiarySystemBackground() -> PlatformColor
    - elevatedBackground() -> PlatformColor (iOS/iPadOS)
    - dynamicCustom(light: PlatformColor, dark: PlatformColor) -> PlatformColor

3. DarkModeIconsAndImages.swift
- Models
  - Structs
    - ImageVariantPolicy (hasLight: Bool, hasDark: Bool, softenWhiteInDark: Bool)
- Utilities
  - Structs
    - DarkModeIconsAndImages
- Functions
  - DarkModeIconsAndImages
    - symbol(name: String) -> Image
    - image(named: String, policy: ImageVariantPolicy) -> Image
    - softenedWhiteBackground(_ image: Image) -> Image

4. DarkModeText.swift
- Utilities
  - Structs
    - DarkModeText
- Functions
  - DarkModeText
    - textColorPrimary() -> PlatformColor
    - configureTextViewForVibrancy(_ view: PlatformTextView)

5. DarkModePlatformNotes.swift
- Models
  - Structs
    - PlatformDarkModeNotes (platform, notes)
- Variables/Properties
  - Globals
    - iOSiPadOSNotes: PlatformDarkModeNotes (base vs elevated backgrounds)
    - macOSNotes: PlatformDarkModeNotes (desktop tinting + transparency guidance)
    - tvOSNotes: PlatformDarkModeNotes (no additional considerations)
    - visionWatchNotes: PlatformDarkModeNotes (not supported)

6. DarkModeTestingToolkit.swift
- Utilities
  - Structs
    - DarkModeTestingToolkit
- Functions
  - DarkModeTestingToolkit
    - snapshotAppearances(for view: some View) // Light/Dark/Auto
    - runContrastChecks(pairs: [(fg: PlatformColor, bg: PlatformColor)])
    - verifyAccessibilityCombos() // Increase Contrast + Reduce Transparency

---

**Notes**  
- Prefer system backgrounds and label colors.  
- Include asset-catalog light/dark variants for custom colors and images.  
- Target ≥4.5:1 contrast (AA); 7:1 for small text.  
- iOS/iPadOS elevation (base/elevated) and macOS desktop tinting are platform‑specific behaviors worth testing.

*↑ Back to Dark Mode Article*
