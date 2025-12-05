# Branding Implementation Guide

**Summary**  
A practical, modular blueprint for expressing a clear, native-feeling brand across iOS, iPadOS, macOS, tvOS, visionOS, and watchOS — without compromising accessibility or readability. This article explains the concepts, how the module is organized, concrete how‑to steps, platform notes, testing, and next actions.

## Overview

Our branding stack is token‑driven and split into submodules so teams can plug in just what they need. The system favors semantic roles over hardcoded values, aligns to Apple’s HIG, and interoperates with accessibility and Dynamic Type by default.

# Branding Implementation Guide

**Summary**  
A practical, modular blueprint for expressing a clear, native-feeling brand across iOS, iPadOS, macOS, tvOS, visionOS, and watchOS — without compromising accessibility or readability. This article explains the concepts, how the module is organized, concrete how-to steps, platform notes, testing, and next actions.

## Overview

Our branding stack is token-driven and split into submodules so teams can plug in just what they need. The system favors semantic roles over hardcoded values, aligns to Apple’s HIG, and interoperates with accessibility and Dynamic Type by default.

**Submodules (high level):**  
- **BrandColor** — brand and system color usage, contrast, color-space management, Liquid Glass guidance.  
- **BrandTypography** — font roles (display/title/headline/body/caption), Dynamic Type integration, legibility fallbacks.  
- **BrandAccessibility** — contrast rules, motion policy, announcements; when branding must yield to accessibility.  
- **BrandMaterials** — safe tinting on Liquid Glass, content-layer color strategy.  
- **BrandMotion & Haptics** — subtle motion curves, event haptics, Reduce Motion fallbacks.  
- **BrandDarkMode** — audits, alternates, and snapshot comparisons.  
- **BrandAssets** — marks/wordmarks/illustrations (minimal, purposeful use).  
- **BrandComponents** — buttons, banners, headers built strictly on tokens.  
- **BrandTesting** — contrast assertions, appearance & color-space sweeps, Dynamic Type snapshots.

**Core principles**  
- **Authentic & consistent**: One voice, one visual system, repeatable tokens.  
- **Content-first**: Branding supports content; never competes with it.  
- **Native**: Respect platform semantics, system accents (macOS), and standard behaviors.  
- **Accessible**: Dynamic Type, minimum contrast, motion alternatives.  
- **Composable**: Tokens + utilities → components → screens.

**Cross-links**  
- Index / API TOC: *BrandingIndex.md*  
- Code documentation facades: *Branding.swift*

---

## Module Map (files you’ll see)

- **BrandManager.swift** — central coordinator; exposes theme and effective accent.  
- **BrandTokens.swift** — semantic color/type tokens and sizing/radius/shadow primitives.  
- **BrandColorSystem.swift** — roles, contrast computation, appearance variants, Liquid Glass checks.  
- **BrandColorManagement.swift** — color-space (sRGB/P3) profiles, white-point guidance (tvOS/iOS).  
- **BrandTypographySupport.swift** — role→font mapping, Dynamic Type scaling.  
- **BrandAccessibilityBridge.swift** — contrast enforcement, brand announcements, motion policy.  
- **BrandMaterials.swift** — safe tint and guidance for Liquid Glass vs content layer.  
- **BrandMotionAndHaptics.swift** — motion curves & haptics with Reduce Motion.  
- **BrandDarkModeSupport.swift** — audit & suggestions; snapshot comparisons.  
- **BrandAssets.swift** — load minimal marks/wordmarks/illustrations.  
- **BrandComponents.swift** — BrandedHeader, BrandBanner, BrandButtonStyle built only on tokens.  
- **BrandTestingToolkit.swift** — contrast asserts, snapshots, Dynamic Type exercises.

---

## How-to (Quick Start)

1) **Add tokens** in `BrandTokens.swift`. Define `BrandTheme` colors and type roles (no hardcoded hex in views).  
2) **Initialize** a theme early:  
   ```swift
   @main
   struct AppEntry: App {
     @StateObject private var brand = BrandManager(theme: .default, respectSystemAccent: true)
     var body: some Scene {
       WindowGroup {
         RootView()
           .environment(\.brandTheme, brand.theme)
           .tint(brand.effectiveAccentColor)
       }
     }
   }

**Core principles**  
- **Authentic & consistent**: One voice, one visual system, repeatable tokens.  
- **Content‑first**: Branding supports content; never competes with it.  
- **Native**: Respect platform semantics, system accents (macOS), and standard behaviors.  
- **Accessible**: Dynamic Type, minimum contrast, motion alternatives.  
- **Composable**: Tokens + utilities → components → screens.

**Cross‑links**  
- Index / API TOC: *BrandingIndex.md*  
- Code documentation facades: *Branding.swift*

---

## Module Map (files you’ll see)

- **BrandManager.swift** — central coordinator; exposes theme and effective accent.  
- **BrandTokens.swift** — semantic color/type tokens and sizing/radius/shadow primitives.  
- **BrandColorSystem.swift** — roles, contrast computation, appearance variants, Liquid Glass checks.  
- **BrandColorManagement.swift** — color‑space (sRGB/P3) profiles, white‑point guidance (tvOS/iOS).  
- **BrandTypographySupport.swift** — role→font mapping, Dynamic Type scaling.  
- **BrandAccessibilityBridge.swift** — contrast enforcement, brand announcements, motion policy.  
- **BrandMaterials.swift** — safe tint and guidance for Liquid Glass vs content layer.  
- **BrandMotionAndHaptics.swift** — motion curves & haptics with Reduce Motion.  
- **BrandDarkModeSupport.swift** — audit & suggestions; snapshot comparisons.  
- **BrandAssets.swift** — load minimal marks/wordmarks/illustrations.  
- **BrandComponents.swift** — BrandedHeader, BrandBanner, BrandButtonStyle built only on tokens.  
- **BrandTestingToolkit.swift** — contrast asserts, snapshots, Dynamic Type exercises.

---

## How‑to (Quick Start)

1) **Add tokens** in `BrandTokens.swift`. Define `BrandTheme` colors and type roles (no hardcoded hex in views).  
2) **Initialize** a theme early:  
   ```swift
   @main
   struct AppEntry: App {
     @StateObject private var brand = BrandManager(theme: .default, respectSystemAccent: true)
     var body: some Scene {
       WindowGroup {
         RootView()
           .environment(\.brandTheme, brand.theme)
           .tint(brand.effectiveAccentColor)
       }
     }
   }
   ```
3) **Use roles, not values**:  
   ```swift
   Text("Continue")
     .font(BrandTypeTokens.font(for: .headline))
     .foregroundStyle(BrandColorTokens.color(for: .textPrimary))
   ```
4) **Respect accessibility**: call `BrandAccessibilityBridge.enforceContrast(_:)` for custom pairs; apply `BrandMotion.reducedIfNeeded(_:)`.  
5) **Adopt materials correctly**: use `BrandMaterials.isTintSafe(_:on:)` for Liquid Glass; prefer color in the **content layer** for brand expression.  
6) **Dark Mode**: run `BrandDarkModeSupport.auditAssets()` and adjust alternates if needed.  
7) **Test**: run `BrandTestingToolkit` to snapshot key screens across appearance & Dynamic Type; assert WCAG AA.

---

## Recipes / Implementation Notes

### 1) BrandColor
- **Roles**: `accent`, `background`, `surface`, `textPrimary`, `textSecondary`, `success`, `warning`, `destructive` defined in `BrandTokens`.  
- **Dynamic system colors**: Use semantic colors for labels/separators/links; never reassign their meaning.  
- **Contrast**: `BrandColorSystem.contrastRatio(foreground:background:)` and `passesAA` help guard failures.  
- **Liquid Glass**: Minimal tint; reserve colored backings for truly prominent actions. Prefer **content‑layer** brand color rather than painting all glass.  
- **Color‑space**: Use P3 assets for richer displays but supply sRGB fallbacks via catalog variants (`BrandColorManagement.provideAssetVariants`).  
- **White‑point**: For media/readers on iOS/tvOS, consider `UIWhitePointAdaptivityStyle` via `preferredWhitePointAdaptivityStyle`.

**UIKit dynamic example**  
```swift
extension UIColor {
  static let brandAccentDynamic = UIColor { traits in
    traits.userInterfaceStyle == .dark
      ? UIColor(red: 0.60, green: 0.80, blue: 1.0, alpha: 1)
      : UIColor(red: 0.00, green: 0.50, blue: 1.0, alpha: 1)
  }
}
```

### 2) BrandTypography
- **Roles → Fonts**: `BrandTypographySupport.font(for: .headline)` keeps UI consistent.  
- **Dynamic Type**: `scaled(_:for:)` adapts across categories; prefer system fonts for small body/caption.  
- **Legibility**: ensure weights track contrast changes; bias toward SF for dense text and CJK/RTL support.

```swift
Text(title)
  .font(BrandTypographySupport.font(for: .title, weight: .semibold))
  .dynamicTypeSize(...DynamicTypeSize.accessibility3)
```

### 3) BrandAccessibility
- **Policy**: set `A11yBrandPolicy(minContrast: 4.5, allowColorOnlyMeaning: false)`. If branding conflicts, accessibility wins.  
- **Announcements**: surface key brand events via `announceBrandEvent(_:)`.  
- **Motion**: use `motionPolicy()` to decide animation style when Reduce Motion is on.

### 4) BrandMaterials (Liquid Glass)
- **Tinting**: `isTintSafe` helps restrict tint to small surfaces; use content‑layer color for broader brand expression.  
- **Guidance**: `guidance(for:)` returns platform‑tuned tips.

### 5) BrandMotion & Haptics
- **Curves**: use `subtle()` for default transitions, `emphasized()` for primary actions.  
- **Reduce Motion**: wrap with `reducedIfNeeded(_:)`. Pair with gentle haptics where appropriate.

### 6) BrandDarkMode
- **Audit**: run `auditAssets()` to find risky colors or insufficient contrast.  
- **Alternates**: use `suggestAlternates(for:)` to pick safer dark hues; snapshot before/after.

### 7) BrandAssets
- **Restraint**: don’t spam logos; defer to content. Ensure alternate app icons remain recognizable and pass review.

### 8) BrandComponents
- **Always token‑based**: No raw colors or fonts in component code; consume tokens & support a11y.  
- **Example**:
```swift
Button("Continue") {}
  .buttonStyle(BrandButtonStyle(theme: .default))
```

### 9) BrandTesting
- **Automate**: snapshot light/dark/high‑contrast, sRGB/P3, and all Dynamic Type sizes. Fail CI on AA violations.

---

## Platform Notes

- **iOS / iPadOS**: Prefer grouped/system backgrounds semantically; Dynamic Type end‑to‑end.  
- **macOS**: Respect user Accent unless explicitly opted out; handle window materials conservatively.  
- **tvOS**: Communicate focus via scale & motion first; don’t rely on color. Use safe zones for app icons & imagery.  
- **visionOS**: Use color sparingly on glass; prefer bold color in large text or content areas; balance brightness in immersive scenes.  
- **watchOS**: Use color to support data (e.g., Activity); avoid full‑screen saturated color for long‑lived views.

---

## Testing & CI

- Contrast asserts for all primary text/background pairs.  
- Automated snapshots for appearances (light/dark/high‑contrast) and color‑spaces (sRGB/P3).  
- Dynamic Type sweep: from `.xSmall` to `.accessibilityXXXL`.  
- Record failures in CI artifacts.

---

## Next Steps

- Finalize `BrandTheme.default` & alternates in `BrandTokens`.  
- Hook `BrandTestingToolkit` into CI.  
- Author per‑submodule docs: **BrandColorArticle/Index**, **BrandTypographyArticle/Index**, **BrandAccessibilityArticle/Index**, **BrandMaterialsArticle/Index**, **BrandMotionArticle/Index**, **BrandDarkModeArticle/Index**, **BrandAssetsArticle/Index**, **BrandComponentsArticle/Index**, **BrandTestingArticle/Index**.  
- Add “↑ Back to Branding Index” to each article footer.

---

## References

- HIG — Branding, Color, Typography, Dark Mode, Materials  
- App Store Marketing Guidelines; Apple Trademark List  
- SwiftUI `Color`, UIKit `UIColor` (dynamic provider)

*↑ Back to Branding Index*
