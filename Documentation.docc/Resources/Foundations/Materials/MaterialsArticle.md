# Materials Implementation Guide

**Summary**  
A pragmatic, HIG‑aligned blueprint for using **materials** to create depth, hierarchy, and legibility across iOS, iPadOS, macOS, tvOS, visionOS, and watchOS. This guide converts Apple’s Materials guidance into concrete Swift/SwiftUI patterns, platform notes, and test hooks.

## Overview

Materials visually separate **foreground** (text, controls, navigation) from **background** (content, imagery, color) and help people retain a sense of place by letting color and luminance peek through. Apple platforms feature two families:
- **Liquid Glass** (dynamic, for controls/navigation that float above content)
- **Standard materials** (blur, vibrancy, blending modes used within the content layer)

> Use Liquid Glass for functional chrome (toolbars, sidebars, tab bars, popovers) and **standard materials** for structure inside your content layer. Avoid Liquid Glass in content except for transient interactive states (e.g., sliders/toggles while active).

**Cross‑links**  
- Index / API TOC: *MaterialsIndex.md*  
- Doc façade: *Materials.swift*

---

## Core Principles

- **Legibility first**: text/symbols must remain readable atop any material.
- **Semantic choice**: select materials by **purpose**, not their apparent color (which can change with settings and surroundings).
- **Use sparingly**: overusing Liquid Glass distracts from content; reserve it for high‑value controls.
- **Depth & hierarchy**: materials establish layering—chrome above content; thicker materials increase separation.
- **Platform fit**: follow idiom‑specific expectations (focus on tvOS, glass on visionOS, vibrancy behavior per OS).

---

## Module Map (files you’ll see)

- **MaterialTokens.swift** — enums for **LiquidGlassVariant** (regular, clear), **StandardMaterial** (ultraThin, thin, regular, thick), and **VibrancyLevel** (label, secondaryLabel, tertiaryLabel, quaternaryLabel; fill, secondaryFill, tertiaryFill; separator).
- **LiquidGlassSupport.swift** — helpers to apply regular/clear glass, decide dimming, and scope glass to chrome.
- **StandardMaterialsSupport.swift** — choose standard materials by context (backgrounds, overlays, sidebars) and thickness.
- **VibrancyAndBlurs.swift** — map label/fill/sep vibrancy to platforms; pick blur/vibrancy styles; AppKit blending modes.
- **MaterialApplicators.swift** — SwiftUI, UIKit, AppKit convenience APIs to apply materials consistently.
- **MaterialAccessibilityBridge.swift** — contrast checks, vibrant color enforcement, motion/opacity governance.
- **MaterialTestingToolkit.swift** — snapshots over busy/bright/dark backgrounds; contrast/a11y audits; failure gates for CI.
- **MaterialPlatformNotes.swift** — per‑platform differences and do’s/don’ts.

> Keep product views free of ad‑hoc blurs. Import these helpers so material selection is consistent and testable.

---

## How‑to (Quick Start)

1) **Pick the layer**  
   - Chrome → **Liquid Glass** (regular by default; clear over rich media).  
   - Content layer → **standard materials** (.ultraThin/.thin/.regular/.thick) to separate sections.

2) **Apply in SwiftUI**
```swift
// Liquid Glass — regular (default)
Toolbar()
  .glassEffect(.regular)

// Liquid Glass — clear over rich media with optional dimming
ZStack {
  VideoPlayerView()
  Controls()
    .glassEffect(.clear) // prefer a dark 35% dimming behind if the content is bright
}

// Standard materials for content structure
Card()
  .background(.regularMaterial) // or .thinMaterial / .ultraThinMaterial / .thickMaterial
```

3) **Apply in UIKit/AppKit**
```swift
// UIKit — blur + vibrancy for labels/fills
let blur = UIBlurEffect(style: .systemMaterial)
let blurView = UIVisualEffectView(effect: blur)
let vibrancy = UIVibrancyEffect(blurEffect: blur, style: .label) // .secondaryLabel, .tertiaryLabel, .quaternaryLabel
let vibrancyView = UIVisualEffectView(effect: vibrancy)
blurView.contentView.addSubview(vibrancyView)

// AppKit — NSVisualEffectView materials + blending
let v = NSVisualEffectView()
v.material = .sidebar // choose semantically (windowBackground, sidebar, headerView, etc.)
v.blendingMode = .behindWindow // or .withinWindow when appropriate
```

4) **Choose vibrancy**
- **Labels**: default → highest contrast; secondary/tertiary for supporting text; **avoid quaternary** over thin/ultraThin.  
- **Fills**: default, secondary, tertiary.  
- **Separators**: single default vibrancy works on all materials.

5) **Decide dimming for clear glass**
- If underlying content is **bright**, add a **dark ~35%** dimming layer behind clear glass.  
- If content is sufficiently **dark** (or AVKit provides its own dimming), omit dimming.

6) **Ship when tests pass** with `MaterialTestingToolkit.runAll()`.

---

## Recipes

### Liquid Glass (regular vs. clear)
- **Regular**: blurs & adjusts luminosity → best for text‑heavy components (alerts, sidebars, popovers) and scroll‑edge effects that increase legibility.
- **Clear**: highly translucent → best when content should remain visually prominent (floating over photos/video). Use a dimming layer if the background is bright.

### Standard materials & thickness
- **UltraThin/Thin**: more translucency; retain more background context; avoid low‑contrast text (don’t pair with quaternary label).
- **Regular**: balanced separation; good default for cards/grouped tables/sidebars.
- **Thick**: highest separation; use sparingly for strong layering (e.g., dark element on top of regular background).

### Vibrancy & color
- Use **system vibrant colors** on top of materials to maintain legibility in dynamic contexts. Always prefer semantic **label/fill/separator** variants.

### AppKit blending
- Choose **.behindWindow** to blend with background content behind the window; **.withinWindow** to blend within the window’s own content only. Test in both light/dark wallpapers and with vibrancy enabled/disabled.

### Performance & restraint
- Prefer system components—they adopt Liquid Glass automatically. When styling **custom controls** with glass, do it **sparingly**.

---

## Platform Differences

**iOS, iPadOS**  
- Liquid Glass + four standard materials: **ultraThin**, **thin**, **regular (default)**, **thick**.  
- Vibrancy levels for **labels** (default, secondary, tertiary, quaternary) and **fills** (default, secondary, tertiary); separators have one default vibrancy.

**macOS**  
- Multiple standard materials with semantic purposes; vibrant versions of all system colors.  
- Choose background **blending mode**: **behindWindow** vs **withinWindow**.

**tvOS**  
- Liquid Glass appears throughout navigation (Top Shelf, Control Center). Focused items (e.g., image views, buttons) adopt Liquid Glass while focused.  
- Standard materials remain for overlays; pick thickness per need:  
  • *ultraThin* → full‑screen light schemes  
  • *thin* → partial overlays with light schemes  
  • *regular* → partial overlays (general)  
  • *thick* → partial overlays needing a **dark** scheme

**visionOS**  
- Windows use system **glass** (adaptive; no separate Dark Mode). Glass limits background color range to preserve contrast while responding to environment.  
- Avoid opaque areas in windows. For custom components, use **thin** for interactive emphasis, **regular** for section separation, **thick** for distinct dark elements.  
- Vibrancy values: **label**, **secondaryLabel**, **tertiaryLabel**; tertiary only when high legibility isn’t required.

**watchOS**  
- Use materials in full‑screen modals to provide context and legibility; avoid removing default material backgrounds for sheets.

---

## Testing & CI

- **Contrast sweeps** on busy/bright/dark imagery for each component using materials.
- **Vibrancy audits**: ensure label/fill choices meet legibility expectations; avoid quaternary over thin/ultraThin.  
- **Dimming checks** for clear glass over bright content.  
- **Platform snapshots**: iPhone/iPad/macOS/tvOS/visionOS/watchOS idioms (focus states on tvOS; depth/legibility on visionOS).  
- **Performance**: profile custom glass effects; prefer system components.

---

## References (HIG & Docs)
- HIG — **Materials** (Liquid Glass, standard materials, vibrancy, blending, platform notes).  
- Related: **Color** (Liquid Glass color), **Accessibility** (contrast & motion), **Dark Mode**, **Typography** (legibility).  
- Developer: **Adopting Liquid Glass**, `View.glassEffect(_:in:)` (SwiftUI), **Material** (SwiftUI), **UIVisualEffectView** (UIKit), **NSVisualEffectView** (AppKit).

*↑ Back to Materials Index*
