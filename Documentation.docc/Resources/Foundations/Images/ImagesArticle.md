# Images Implementation Guide

**Summary**  
A pragmatic, platform‑aware system for designing, selecting, and shipping **interface images** — with a focus on **icons/glyphs** — that feel native across iOS, iPadOS, macOS, tvOS, visionOS, and watchOS. This article covers principles, module files, SF Symbols usage, vector formats, **optical centering**, selected states, inclusivity/localization, **macOS document icons**, testing/CI, and references.

## Overview

Interface images communicate fast. Unlike **app icons** (brand‑forward, layered), interface icons/glyphs are simplified, high‑clarity shapes that pair with text and system semantics. Prefer **SF Symbols** first; add custom vectors when there’s a clear need. Keep sets visually consistent and accessible.

**What this gives you**
- **Image roles & tokens** (navigation, toolbar, list, action, status)
- **Vector‑first pipeline** (PDF/SVG), asset‑catalog mgmt, and rendering modes
- **SF Symbols integration** (scale, weight, rendering mode, variable color)
- **Optical centering & padding** utilities
- **A11y & i18n** (VoiceOver labels, localized characters, RTL flips)
- **Platform‑specific**: **macOS document icons** (folded‑corner compositing, size matrix)

**Cross‑links**  
- Index / API TOC: *ImagesIndex.md*  
- Code documentation façade: *Images.swift*

---

## Module Map (files you’ll see)

- **ImageAssets.swift** — loads vector/raster assets (PDF/SVG/PNG), manages rendering modes, color space (sRGB/P3), idiom/scale sets.  
- **InterfaceIconGuidance.swift** — best practices for recognizable, simplified icons; weight matching; optical centering; selected‑state rules.  
- **SFSymbolsBridge.swift** — helpers for symbol scale/weight/variable modes and matching point size to adjacent text.  
- **ImageAccessibility.swift** — alternative text labels, decorative flags, and traits.  
- **ImageLocalization.swift** — localizes embedded characters and provides RTL‑flipped variants when needed.  
- **macOSDocumentIcons.swift** — background/center image/text compositing rules and size matrix for custom document types.  
- **ImagesPlatformNotes.swift** — platform diffs (none for iOS/iPadOS/tvOS/visionOS/watchOS; macOS document icons).  
- **ImageTestingToolkit.swift** — snapshots, optical‑centering checks, weight‑to‑text matching, contrast when tinted, and RTL sweeps.

> Keep UI code free of pixel nudges; consume roles/tokens and let utilities handle scale/weight/centering.

---

## How‑to (Quick Start)

1) **Prefer SF Symbols** for common actions; only design custom glyphs when necessary.  
2) **Define roles** (e.g., `.navigation`, `.toolbar`, `.list`, `.action`, `.status`) and map to symbols/assets.  
3) **Ship vectors** for interface glyphs (PDF/SVG). Reserve PNG for rich imagery (photos/illustrations).  
4) **Match text weight** so icons and adjacent text carry the same visual emphasis.  
5) **Apply optical centering** by adding small top/bottom padding inside the asset to center the glyph optically.  
6) **Selected state**: don’t provide special selected/unselected variants for standard components (toolbars, tab bars, buttons); the system derives these.  
7) **A11y/i18n**: provide VoiceOver labels for custom glyphs; localize embedded characters; provide RTL flips when icons imply reading direction.  
8) **macOS doc types**: if your app defines custom document types, supply document icons (see size matrix below). Otherwise, macOS composites your app icon + file extension.

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

### Design best practices
- **Recognizable & simplified**; limit details.  
- **Consistency** across the set: size, stroke weight, level of detail, and perspective. Adjust physical size to achieve **optical** consistency.  
- **Match text weight** unless intentional emphasis is required.  
- **Vector‑first** for glyphs; avoid PNG duplicates for scaling.  
- **Inclusive** imagery: gender‑neutral figures; avoid culture‑specific metaphors.  
- **Text inside icons**: localize characters; flip icons that imply reading direction in RTL.

### Optical centering & padding
Asymmetric icons can feel low/high when centered geometrically. Include a few px of padding inside the asset so geometric centering yields optical centering.

### Selected state
For standard components (toolbars/tab bars/buttons), the system updates visuals automatically (e.g., toolbar selection gets the app’s tint color). Provide selected variants only for bespoke components.

### macOS — Document icons
If you define custom doc types, create **document icons** (folded‑corner base). The system can composite **background fill**, **center image**, and **text** into the shape.
- **Background fill** sizes (provide all):  
  512×512 @1x, 1024×1024 @2x; 256×256 @1x, 512×512 @2x; 128×128 @1x, 256×256 @2x; 32×32 @1x, 64×64 @2x; 16×16 @1x, 32×32 @2x.  
- **Center image**: half the canvas size (e.g., 16 px for a 32 px icon). Provide: 256×256 @1x/512×512 @2x; 128×128 @1x/256×256 @2x; 32×32 @1x/64×64 @2x; 16×16 @1x/32×32 @2x.  
- **Margin** ≈ **10%**; keep most content within ~80% of the canvas; small variants may simplify/omit details.  
- **Avoid** placing key content in the **top‑right** (folded‑corner overlay).  
- **Optional text**: provide a succinct term when the extension is unfamiliar; system auto‑caps and scales.

### Platform notes (non‑macOS)
- **iOS / iPadOS / tvOS / visionOS / watchOS**: no additional icon‑specific rules beyond the best practices above; ensure focus states remain legible on tvOS.

---

## Testing & CI

- **Weight & size sweeps** to verify icons read equally with adjacent text at all Dynamic Type sizes.  
- **Optical centering** checks on asymmetric glyphs.  
- **Contrast** checks when tinting icons in context.  
- **Localization/RTL** snapshots for icons that embed characters or imply direction.  
- **macOS document icons**: verify clarity at each required size and ensure top‑right overlay doesn’t cover important content.

---

## References

- Human Interface Guidelines — **Images (Icons)**: best practices, weight matching, optical centering, selected‑state, inclusive images, **macOS document icons**.  
- Related: **App icons**, **SF Symbols**, **Inclusion**, **Right to left**, **VoiceOver**, **Apple Design Resources** templates.

*↑ Back to Images Index*
