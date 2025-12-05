# Dark Mode Implementation Guide

**Summary**  
A practical, platform-aware blueprint for delivering a great Dark Mode experience across iOS, iPadOS, macOS, and tvOS — with explicit notes for platforms that don’t support Dark Mode (visionOS, watchOS). This article covers principles, implementation files, platform differences, icons & images, text, testing/CI, and references.

## Overview

Dark Mode is a systemwide appearance that uses a dark palette and often increases perceptual contrast to keep foreground content legible against darker backgrounds. People can set **Light**, **Dark**, or **Auto** (switches during the day), and they expect apps to follow the system setting in real time.

**Key principles**
- **Follow system**: Don’t ship an app-specific appearance toggle unless there’s a compelling, domain‑specific reason.
- **Design for both**: Your UI must look great in both Light and Dark, including when appearance flips at runtime.
- **Use semantic colors**: Prefer system label/background/link/separator colors; create asset-catalog variants for custom colors.
- **Aim for contrast**: Meet ≥ **4.5:1** (AA), and target **7:1** for small text; verify with Increased Contrast + Reduce Transparency.
- **Prefer SF Symbols**: They adapt automatically; only branch icons when needed.

**Cross-links**  
- Index / API TOC: *DarkModeIndex.md*  
- Code documentation façade: *DarkMode.swift*

---

## Module Map (files you’ll see)

- **DarkModeSupport.swift** — central helpers for reading environment and syncing UI; elevation helpers (base/elevated).  
- **DarkModeColors.swift** — semantic bridges + dynamic custom colors (light/dark/hc variants).  
- **DarkModeIconsAndImages.swift** — SF Symbols usage, alternate assets per appearance, white‑background softening.  
- **DarkModeText.swift** — label color usage, text views that respect vibrancy/contrast.  
- **DarkModePlatformNotes.swift** — platform‑specific rules (iOS/iPadOS elevation, macOS desktop tinting, tvOS, visionOS/watchOS).  
- **DarkModeTestingToolkit.swift** — snapshot + contrast checks across appearances and accessibility settings.

> Keep views free of hardcoded hex values; consume semantic/system colors or asset‑catalog variants.

---

## How‑to (Quick Start)

1) **Rely on semantics**: use system backgrounds/labels and `.tint` for accent; create dynamic custom colors via asset catalog.  
2) **React to runtime changes**: appearance can switch while your app runs; avoid caching resolved colors.  
3) **Test contrast**: evaluate custom foreground/background pairs at ≥4.5:1; prefer 7:1 for small text.  
4) **Images & icons**: prefer SF Symbols; only branch assets when needed; soften pure‑white backgrounds in Dark Mode.  
5) **Adopt elevation (iOS/iPadOS)**: use system base/elevated backgrounds instead of custom colors.  
6) **macOS desktop tinting**: add a bit of transparency to neutral‑state custom surfaces so they harmonize with the desktop; don’t add transparency to colored states.  
7) **tvOS**: no special Dark Mode guidance beyond general best practices; focus states should remain readable.  
8) **visionOS & watchOS**: Dark Mode isn’t supported.

**SwiftUI snippet**
```swift
struct ContentView: View {
  var body: some View {
    List {
      Text("Primary")
        .foregroundStyle(.primary) // system label colors adapt
      Text("Link").foregroundStyle(.tint)
    }
    // No manual colorScheme binding; follow the system
  }
}
```

**UIKit dynamic example**
```swift
extension UIColor {
  static let brandAccentDynamic = UIColor { traits in
    traits.userInterfaceStyle == .dark
      ? UIColor(red: 0.60, green: 0.80, blue: 1.0, alpha: 1)
      : UIColor(red: 0.04, green: 0.37, blue: 0.98, alpha: 1)
  }
}
```

---

## Recipes / Implementation Notes

### Colors
- Use semantic system colors whenever possible (labels, separators, backgrounds, links).  
- For custom colors, define **light** and **dark** variants in the asset catalog (include high‑contrast variants when appropriate).  
- Meet ≥4.5:1 contrast; 7:1 for small text.

### Icons & Images
- Prefer **SF Symbols**; they adapt to appearance and vibrancy.  
- If full‑color icons look poor in one appearance, supply alternates.  
- **Soften white backgrounds** in images used within Dark UI to avoid glow.

### Text
- Use **system label colors** (primary/secondary/tertiary/quaternary).  
- Prefer system text views that automatically handle vibrancy and contrast.

### Platform differences
- **iOS / iPadOS**: Dark Mode provides **base** (dimmer) and **elevated** (brighter) background colors that change based on z‑position (e.g., modals/popovers). Prefer system backgrounds so the system can manage elevation.
- **macOS**: When users choose **graphite** accent, **desktop tinting** subtly tints window backgrounds. Include a bit of transparency for **neutral** custom components so they harmonize; avoid transparency for **colored** states.
- **tvOS**: No additional considerations beyond general Dark Mode guidance. Ensure focus states are readable; don’t rely solely on color.
- **visionOS / watchOS**: Dark Mode **not supported**.

---

## Testing & CI

- Snapshot Light/Dark and **Auto** (ensure clean transitions).  
- Run with **Increase Contrast** and **Reduce Transparency** independently and together.  
- AA threshold checks for key text/background pairs; target 7:1 for small text.  
- Verify images/icons across appearances; ensure alternates are selected when needed.

---

## References

- Human Interface Guidelines — Dark Mode  
- Related: Color · Materials · Typography  
- SF Symbols (adapts to appearance)  
- System semantics: label/link/separator/background colors  

*↑ Back to Dark Mode Index*
