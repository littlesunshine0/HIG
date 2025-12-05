# Icons Implementation Guide

**Summary**  
A pragmatic, platform-aware system for designing, selecting, and shipping **interface icons** (glyphs) that feel native across iOS, iPadOS, macOS, tvOS, visionOS, and watchOS. This article covers principles, module files, SF Symbols integration, optical centering, vector formats, accessibility/localization, macOS **document icons**, testing/CI, and references.

## Overview

Interface icons communicate a single idea fast. Unlike **app icons** (rich, layered, brand-forward), interface icons are simplified, high-clarity glyphs that pair with adjacent text and system semantics. Prefer **SF Symbols** where possible; mix with custom glyphs only when you have a clear need.

**What this gives you**
- **Icon roles & tokens** (navigation, toolbar, list, action, selection, status) with size/weight guidance
- **SF Symbols integration** (scale, weight, rendering mode, variable color)
- **Vector-first pipeline** (PDF/SVG), asset-catalog management, and optional per-state variants
- **Optical centering and padding** utilities to maintain visual alignment
- **A11y & i18n** (VoiceOver labels, localized text in icons, RTL flips where appropriate)
- **Platform-specific**: macOS document icons (folded-corner compositing & size matrix)

**Cross-links**  
- Index / API TOC: *IconsIndex.md*  
- Code documentation façade: *Icons.swift*

---

## Module Map (files you’ll see)

- **IconTokens.swift** — semantic roles, default sizes, stroke weights, and padding rules.  
- **IconRoles.swift** — role → symbol/custom-glyph mapping with platform fallbacks.  
- **SFIconsIntegration.swift** — SF Symbols helpers (scales/weights/variants/rendering modes).  
- **IconSetBuilder.swift** — builds cohesive sets (consistent stroke, size, padding, optical centering).  
- **IconAssets.swift** — loads vector assets (PDF/SVG), manages rendering modes and multi-state variants.  
- **IconAccessibility.swift** — alternative labels, localization of embedded characters, RTL flipping guidance.  
- **IconPlatformNotes.swift** — macOS document icons + general platform notes.  
- **IconTestingToolkit.swift** — snapshots, optical-centering checks, weight-to-text matching, and contrast checks.

> Keep UI code free of fixed pixel nudges; consume roles/tokens and let utilities handle scale/weight/centering.

---

## How‑to (Quick Start)

1) **Choose symbols first**: use SF Symbols for common actions; only design custom glyphs when needed.  
2) **Define roles** in `IconTokens.swift` (e.g., `.navigation`, `.toolbar`, `.list`, `.action`, `.status`).  
3) **Map roles → symbols** with `IconRoles` (include platform fallbacks).  
4) **Match text weight**: align icon weight with adjacent text to keep emphasis consistent.  
5) **Apply optical centering**: if a glyph looks off-center, add padding via `IconSetBuilder.opticalPadding(_:)`.  
6) **Ship vectors**: import PDF/SVG once; let the system scale; avoid raster PNG for interface icons.  
7) **A11y/i18n**: provide VoiceOver labels; localize characters in icons; provide RTL flips when suggesting reading direction.  
8) **macOS doc types**: if you own custom file types, create **document icons** per the matrix below; otherwise the system comps your app icon + extension.

**SwiftUI snippet**
```swift
Label("Share", systemImage: "square.and.arrow.up")
  .labelStyle(.titleAndIcon)
  .symbolRenderingMode(.monochrome)
  .font(.body) // icon weight matches adjacent text automatically
```

**UIKit snippet**
```swift
let image = UIImage(systemName: "line.3.horizontal.decrease") // Filter
let item = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(applyFilter))
item.accessibilityLabel = "Filter"
```

---

## Recipes / Implementation Notes

### Best practices (design)
- **Keep it simple & recognizable**; limit details.  
- **Consistency**: same stroke, perspective, and visual weight across the set; adjust physical size to achieve **optical** consistency.  
- **Match text weight** unless you’re intentionally emphasizing one side.  
- **Selected-state assets**: not needed for standard components (toolbars/tab bars/buttons) — the system derives selected appearance.  
- **Vector formats**: Use **PDF/SVG** for custom glyphs; only use PNG for rich imagery, not interface glyphs.  
- **Inclusive images**: prefer gender‑neutral figures; avoid culture‑specific metaphors.  
- **Text inside icons**: localize characters; flip icons that imply reading direction in RTL contexts.  
- **VoiceOver labels**: supply clear alternative text for custom glyphs.

### SF Symbols integration
- Choose symbol **scale** and **weight** to match adjacent text.  
- Use **monochrome** for standard glyphs; adopt multicolor/variable color only when it adds clarity and passes contrast checks.  
- If you need a custom symbol, follow SF Symbols grid and export as a custom symbol.

### Optical centering & padding
- Asymmetric icons may look low/high when centered geometrically; apply a few px of top/bottom padding to center **optically**.  
- Store padding inside the asset so geometric centering achieves optical alignment.

### macOS — Document icons
- If you define custom document types, create **document icons** (folded-corner base); supply:  
  **Background fill** sizes: 512, 256, 128, 32, 16 (@1x) and @2x variants.  
  **Center image** (optional): half the canvas size (e.g., 16 px image for a 32 px icon) with ~10% margin, content within ~80%.  
  **Text**: use a short, descriptive term instead of an unfamiliar extension when helpful.  
- Avoid placing key content in the top‑right corner (folded corner overlays it).  
- Reduce detail at smaller sizes (thicken lines, remove non‑essential elements) for clarity.

### Platform notes (non‑macOS)
- **iOS/iPadOS/tvOS/visionOS/watchOS**: no additional platform‑specific icon rules beyond the best practices above; ensure focus states remain legible on tvOS.

---

## Testing & CI

- **Weight & size sweep** to ensure icons read equally with adjacent text at all Dynamic Type sizes.  
- **Optical centering checks** across asymmetric glyphs.  
- **Contrast** checks when tinting icons in context.  
- **Localization/RTL** snapshots for icons that embed characters or imply direction.  
- For macOS **document icons**, verify clarity at each required size.

---

## References

- Human Interface Guidelines — **Icons** (interface icon best practices, optical centering, vector guidance, macOS document icons).  
- Related: **App icons** (not the same as interface icons), **SF Symbols**, **Inclusion**, **Right to left**, **VoiceOver**.  
- Apple Design Resources (macOS document icon templates).

*↑ Back to Icons Index*
