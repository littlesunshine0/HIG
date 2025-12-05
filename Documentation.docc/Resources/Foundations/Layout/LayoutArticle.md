# Layout Implementation Guide

**Summary**  
A pragmatic blueprint for **adaptive, readable, and inclusive layout** across iOS, iPadOS, macOS, tvOS, visionOS, and watchOS. This guide turns HIG layout guidance into concrete files, APIs, and test hooks so teams can ship consistent UI that scales from phone to desktop to spatial windows/volumes.

## Overview

Great layout communicates structure and intent. It creates hierarchy, preserves legibility, and adapts to device, window size, content size, language/RTL, Dynamic Type, and accessibility settings. This module gives you:
- A **module map** of focused Swift files (tokens → grid/spacing → safe areas → sizing → stacks/grids → navigation bars → focus/tap targets → RTL → platform notes → testing)
- Ready‑to‑use types for spacing scales, grids, breakpoints, readable widths, safe areas, and hit targets
- SwiftUI and UIKit recipes for stacks, grids, and compositional layouts
- Platform diffs (tvOS focus safe zones, watchOS compact layouts, visionOS windows/volumes)
- CI hooks to block regressions (safe areas, Dynamic Type, RTL, breakpoints)

**Cross‑links**  
- Index / API TOC: *LayoutIndex.md*  
- Doc façade: *Layout.swift*

**Primary reference**: Apple HIG — **Layout**. See also Accessibility, Typography, and Right‑to‑Left.  

---

## Core Principles

- **Clarity & hierarchy**: one clear visual path; group related content; use whitespace as a first‑class element.
- **Consistency**: shared spacing tokens, grid, and alignment rules.
- **Adaptivity**: respond to size classes, window size, content size, platform idiom, and Dynamic Type.
- **Reachability & comfort**: preserve safe areas; keep key actions reachable; respect platform bars/chrome.
- **Legibility**: align with typography; enforce readable widths for long text.
- **Inclusivity**: mirror layout in RTL; keep hit targets minimums; avoid layout that relies on color only.
- **Performance**: prefer simple stacks/grids; reuse cells; avoid overdraw.

---

## Module Map (files you’ll see)

- **LayoutTokens.swift** — canonical spacing/radius/shadow scales for all screens.
- **SpacingAndGrid.swift** — grid specs by idiom; gutters/margins; column helpers.
- **SafeAreasAndMargins.swift** — device safe areas, bars/toolbars/tab bars; content insets.
- **AdaptiveSizing.swift** — size classes, breakpoints, readable widths, Dynamic Type aware sizing.
- **AlignmentAndHierarchy.swift** — alignment guides, grouping levels, section spacing, dividers.
- **ContainersAndStacks.swift** — SwiftUI stacks/spacers/grids patterns; container max widths.
- **GridsAndLists.swift** — SwiftUI Grid/Lazy*Grid recipes + UICollectionViewCompositionalLayout helpers.
- **NavigationAndBarsLayout.swift** — large titles, toolbars/tab bars/sidebars; chrome spacing rules.
- **FocusAndTouchTargets.swift** — tap target and tvOS focus minimums; hit slop; focus safe insets.
- **RTLAndLocalizationLayout.swift** — semantic leading/trailing, icon mirroring, bidi checks.
- **PlatformLayoutNotes.swift** — platform diffs.
- **LayoutTestingToolkit.swift** — snapshots at breakpoints, Dynamic Type sweeps, RTL flips, safe‑area checks.

> Keep product views free of one‑off paddings; import tokens/utilities and compose.

---

## How‑to (Quick Start)

1) **Adopt tokens**
```swift
// LayoutTokens
enum SpacingScale: CaseIterable { case xxs, xs, s, m, l, xl, xxl }
let padding = LayoutTokens.spacing(.m)
```
2) **Wrap content in safe areas**
```swift
// SwiftUI
ScrollView { content }
  .safeAreaInset(edge: .bottom) { PrimaryActionBar() }
```
3) **Choose grid by idiom**
```swift
let spec = SpacingAndGrid.grid(for: proxy.size, idiom: .phone)
let colW = SpacingAndGrid.columnWidth(in: proxy.size.width, spec: spec)
```
4) **Respect readable width** for text‑heavy screens
```swift
// UIKit
contentView.readableContentGuide.leadingAnchor.constraint(equalTo: body.leadingAnchor).isActive = true
```
5) **Hit targets**
```swift
FocusAndTouchTargets.ensureMinSize(button)
```
6) **RTL flip** where needed
```swift
RTLAndLocalizationLayout.applySemantic(to: view) // uses .semanticContentAttribute
```
7) **Ship** after `LayoutTestingToolkit.runAll()` passes.

---

## Recipes

### Spacing scale and grid
- Define a **single spacing scale** (e.g., 4–8–12–16–20–24–32). Use multiples—never ad‑hoc values.
- On compact widths (iPhone portrait), use **fewer columns/larger gutters**; increase columns on iPad/Mac.

### Safe areas & bars
- Respect top/bottom safe areas; place persistent actions in toolbars/tab bars; avoid overlapping dynamic island or Home indicator.
- Use `.safeAreaInset` (SwiftUI) or layout guides (UIKit) to add bars without covering content.

### Readable width & long‑form text
- Constrain line length to ~**60–80 characters**; center text blocks in wide windows; provide generous leading/trailing padding.

### Dynamic Type & accessibility
- Increase spacing with text size; prefer stacks/grids that reflow; ensure buttons maintain target size.

### Stacks, grids, and lists
- Prefer **VStack/HStack/ZStack + Spacer** for most screens; reach for **Grid/Lazy*Grid** for tabular content.
- On UIKit, use **UICollectionViewCompositionalLayout** for complex grids; keep sections self‑contained.

### Navigation bars, toolbars, sidebars
- Large titles need breathing room above content; pin primary CTAs to a bottom toolbar on iOS.
- On macOS/iPadOS, prefer **sidebar** for hierarchy; keep widths stable.

### Focus & touch targets
- Targets ≥ **44×44 pt** (watchOS ≥ 44×44, tvOS focus min ≈ 60×60 logical px); add **hit slop** for icons.
- On tvOS, keep focusable items within **focus‑safe** regions and provide clear focus states.

### RTL and localization
- Use **leading/trailing** APIs; avoid fixed left/right paddings; mirror directional glyphs.

---

## Platform Differences

- **iOS/iPadOS**: safe areas (notch/dynamic island), readableContentGuide (UIKit), compact/regular size classes.
- **macOS**: resizable windows; sidebars & split views; maintain predictable min/max widths.
- **tvOS**: focus engine; large targets; generous gutters; avoid dense grids; keep content in title‑safe areas.
- **visionOS**: windows/volumes; keep content at comfortable **distance**; avoid edges that cause head motion.
- **watchOS**: glanceable vertical stacks; large targets; minimal chrome.

---

## Testing & CI

- **Breakpoints**: snapshot at common sizes (iPhone SE/15 Pro Max, iPad split/full, Mac 1024–1920 widths).
- **Dynamic Type sweeps**: verify reflow and target sizes.
- **Safe‑area audits**: bars in/out; rotation.
- **RTL**: flip and verify alignment/mirroring.
- **Readable width**: enforce max line length and margins.

---

## References (HIG & Docs)
- HIG — **Layout** (foundational).  
- HIG — Accessibility, Typography, Right‑to‑left, Designing for platforms.  
- Developer: SwiftUI **Layout**, UIKit **Auto Layout**, UICollectionViewCompositionalLayout.

*↑ Back to Layout Index*
