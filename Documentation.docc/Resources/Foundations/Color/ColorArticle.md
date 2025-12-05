# Color Implementation Guide

**Summary**  
A pragmatic, token‑driven system for using color consistently across iOS, iPadOS, macOS, tvOS, visionOS, and watchOS. This article covers principles, module files, platform behaviors, Liquid Glass guidance, color‑space management (sRGB/P3), accessibility, and testing.

## Overview

Color communicates hierarchy, feedback, status, and brand — but must remain legible and accessible across appearances and devices. This module favors **semantic roles** (not raw values), **dynamic** colors that adapt to appearance/contrast, and **asset‑catalog variants** for color spaces.

**What this gives you**
- **Semantic roles** (`accent`, `background`, `surface`, `textPrimary`, `textSecondary`, `success`, `warning`, `destructive`, `separator`, `link`)
- **Dynamic color plumbing** (light/dark, Increased Contrast aware)
- **Liquid Glass guidance** (use color sparingly on materials; prefer content‑layer color for branding)
- **Color‑space management** (sRGB defaults with Display P3 variants where helpful)
- **Inclusive patterns** (don’t rely on color alone; meet contrast targets)
- **Platform notes** (macOS accent, tvOS focus, visionOS glass, watchOS long‑lived screens)

**Cross‑links**  
- Index / API TOC: *ColorIndex.md*  
- Code documentation facades: *Color.swift*

---

## Module Map (files you’ll see)

- **ColorTokens.swift** — defines `ColorRole`, `ColorToken`, and `ColorTheme` (brand/system roles).  
- **ColorRoles.swift** — resolves role → platform color (SwiftUI `Color` / UIKit `UIColor` / AppKit `NSColor`).  
- **ColorContrastHelper.swift** — computes contrast ratios; `passesAA/AAA`; recommends adjustments.  
- **ColorManagement.swift** — asset‑catalog variants (sRGB/P3) and white‑point guidance (tvOS/iOS).  
- **LiquidGlassGuidance.swift** — checks for safe tinting on materials; promotes content‑layer color.  
- **SystemColorsBridge.swift** — semantic bridges for labels, separators, backgrounds, links.  
- **ColorPickerSupport.swift** — SwiftUI color picker wrappers; persistence hooks.  
- **PlatformColorSpecs.swift** — optional constants/tables for QA and documentation.  
- **ColorTestingToolkit.swift** — snapshot and contrast assertions across appearances and Dynamic Type.

> Keep business UI free of hardcoded hex; consume **roles** from `ColorTokens` and let the resolvers adapt.

---

## How‑to (Quick Start)

1) **Define tokens** in `ColorTokens.swift`: supply brand `accent` and role defaults.  
2) **Wire environment** early:
   ```swift
   @main
   struct AppEntry: App {
     var body: some Scene {
       WindowGroup {
         RootView()
           .environment(\.colorTheme, .brandDefault)
       }
     }
   }
   ```
3) **Use roles in views** (not raw values):
   ```swift
   VStack {
     Text("Title")
       .foregroundStyle(ColorRoles.color(for: .textPrimary))
     Button("Continue") {}
       .buttonStyle(.borderedProminent)
       .tint(ColorRoles.color(for: .accent))
   }
   ```
4) **Check contrast** when composing custom pairs:
   ```swift
   let result = ColorContrastHelper.evaluate(foreground: fg, background: bg)
   precondition(result.passesAA, "Color pair fails AA")
   ```
5) **Adopt materials correctly**: reserve tint on Liquid Glass for truly prominent actions; express broader brand color in the **content layer**.  
6) **Provide color‑space variants** for images/gradients that benefit from P3; keep sRGB as a baseline.  
7) **Test** with `ColorTestingToolkit` in CI across light/dark/increased‑contrast and Dynamic Type sizes.

---

## Recipes / Implementation Notes

### Semantic roles (what to use, where)
- `background` / `surface`: view backgrounds and containers; prefer system dynamic backgrounds where possible.  
- `textPrimary` / `textSecondary`: foreground text; map to system label colors under the hood.  
- `accent`: buttons, toggles, interactive accents; on macOS respect user System Accent (unless product explicitly opts out).  
- `success` / `warning` / `destructive`: feedback/status; pair with non‑color cues (icons, text).  
- `separator`, `link`: mirror system semantics.

### Appearances & Increased Contrast
- Colors must adapt to light/dark and Increased Contrast. Use dynamic providers or system semantic colors as the base; apply brand tint on top only when safe.

### Liquid Glass (materials)
- Use color **sparingly** on materials (toolbars/tab bars) to avoid visual noise. Prefer content‑layer color (e.g., a colored header in scroll content) for brand emphasis.

### Color‑space & white‑point
- Default to **sRGB**; add **Display P3** image/color variants for richer displays. Validate gradients for clipping on sRGB.  
- On iOS/tvOS media/readers, set `preferredWhitePointAdaptivityStyle` thoughtfully.

### Inclusive color
- Never use color as the **only** differentiator. Provide labels, glyph shapes, or patterns; meet or exceed WCAG AA contrast.

---

## Platform Notes

- **iOS / iPadOS**: Prefer semantic `systemBackground`/`groupedBackground` and label/link/separator colors; layer brand accent via `.tint` or foreground on components.  
- **macOS**: System Accent may override app accent except for meaningful fixed‑color sidebar icons.  
- **tvOS**: Don’t use color alone to indicate focus; rely on scale and motion. Keep palettes limited and content‑first.  
- **visionOS**: Use color sparingly on glass; prefer bold color in large text/content areas; balance brightness in immersive scenes.  
- **watchOS**: Use background color to support data; avoid saturated full‑screen backgrounds for long‑lived views; complications may use tinted mode.

---

## Testing & CI

- Automated contrast assertions for primary text/background pairs.  
- Snapshot across **light/dark/increased‑contrast**, all **Dynamic Type** sizes, and **sRGB/P3** variants.  
- Validate tvOS focus states without relying on color; verify macOS Accent substitution.

---

## References

- Color (HIG) — best practices, inclusive color, dynamic system colors, Liquid Glass, platform guidance.  
- SwiftUI `Color`, UIKit `UIColor` (+ dynamic provider), AppKit `NSColor`.  
- Asset Catalogs — color management & color‑space variants (sRGB / Display P3).  
- SwiftUI `ColorPicker` (built‑in color controls).  
- `UIWhitePointAdaptivityStyle` (white‑point behavior on supported devices).

*↑ Back to Color Index*
