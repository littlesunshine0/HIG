# Adopting Liquid Glass — Implementation Guide

Summary  
A pragmatic, Apple‑aligned blueprint to adopt Liquid Glass with minimal code by leaning on standard components, removing conflicting custom backgrounds, and validating accessibility and performance. This module turns Apple’s “Adopting Liquid Glass” guidance into concrete files, APIs, and test hooks so teams can ship a cohesive, focused interface that lets content shine.

Overview

Liquid Glass is a dynamic material for controls and navigation that adapts to context. To adopt it:
- Prefer standard components in SwiftUI, UIKit, and AppKit so your app picks up the look automatically.
- Remove custom backgrounds/overlays that conflict with system materials and scroll‑edge effects.
- Keep navigation in a distinct functional layer above content (tabs, sidebars, toolbars).
- Honor accessibility settings (Reduce Transparency, Reduce Motion) and provide good fallbacks.
- Test across platforms and profile performance; combine custom effects in a GlassEffectContainer.

Cross‑links  
- Index / API TOC: LiquidGlassIndex.md  
- Doc façade: LiquidGlass.swift  
- Apple docs: Adopting Liquid Glass (technology overview)

---

Core Principles

- System first: adopt standard components; avoid reinventing materials.
- Less is more: don’t overuse glass; apply to key controls/navigation only.
- Distinct layers: keep navigation floating above content; avoid overlaps.
- A11y‑aware: honor Reduce Transparency and Reduce Motion; provide fallbacks.
- Legibility: ensure scroll‑edge effects for content beneath bars; respect safe areas.
- Performance: prefer built‑in effects; combine custom ones for efficient morphing.

---

Module Map (files you’ll see)

- GlassMaterials.swift — material semantics, icon layers, and system adoption.
- LiquidGlassAdoptionChecklist.swift — audits to remove conflicts and adopt system defaults.
- GlassControls.swift — control geometry, sizes, scroll‑edge effects, button styles.
- GlassNavigationLayer.swift — tabs/sidebars/split views; background extension effects.
- GlassMenusAndToolbars.swift — menu icons, toolbar grouping, spacers, a11y labels.
- GlassWindowsAndModals.swift — rounded windows, continuous resizing, sheets/popovers.
- GlassOrganizationAndLayout.swift — lists/tables/forms spacing and capitalization.
- GlassSearchConventions.swift — search placement, keyboard behavior, semantic tab role.
- GlassPlatformConsiderations.swift — watchOS toolbars, tvOS focus, macOS windows.
- GlassEffectContainerBridge.swift — combine custom effects with GlassEffectContainer.
- LiquidGlassTestingToolkit.swift — performance and a11y sweeps; regressions.
- LiquidGlassPlatformNotes.swift — platform differences.

> Start by rebuilding with the latest SDKs and removing custom backgrounds that conflict.

---

How‑to (Quick Start)

1) Rebuild with latest SDKs and use standard components
- SwiftUI: NavigationSplitView, TabView, Toolbar, Form, List
- UIKit/AppKit: UINavigationBarAppearance.scrollEdgeAppearance, NSToolbar, NSVisualEffectView (system‑driven)

2) Remove custom backgrounds that conflict with Liquid Glass
- Eliminate ad‑hoc blur/visual effect overlays on bars, sheets, popovers.
- Let system materials and scroll‑edge effects manage legibility.

3) Opt into tab bar minimize behavior (iOS)
```swift
TabView {
    // …
}
.tabBarMinimizeBehavior(.onScrollDown)
