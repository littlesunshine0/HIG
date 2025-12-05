# App Icons — Design & Implementation Guide (v1.0)

**Summary** — A unique, memorable icon expresses your app’s purpose and personality and helps people recognize it at a glance. Your app icon appears on the Home Screen and throughout the system (search, notifications, Settings, share sheets). Design it to be simple, consistent, and resilient across **iOS, iPadOS, macOS, tvOS, visionOS,** and **watchOS**.

---

## Overview

**Layer design.** Use layered icons for depth and vitality.  
- **iOS, iPadOS, macOS, watchOS:** background layer + one or more foreground layers. These adopt Liquid Glass traits (specular highlights, frostiness, translucency).  
- **tvOS:** 2–5 layers; focused icons elevate and sway, creating parallax.  
- **visionOS:** background + 1–2 upper layers; system adds depth shadows and uses alpha to create embossed appearance.

**Tooling.**  
- Use your design tool to craft foreground layers.  
- For **iOS/iPadOS/macOS/watchOS**, import into **Icon Composer** (included with Xcode). Define the background, arrange layers, set transparency, and export for Xcode (default/dark/clear/tinted variants).  
- For **tvOS** and **visionOS**, add layers as an **image stack** in Xcode’s asset catalog.

**Shape.**  
- **iOS/iPadOS/macOS:** square layout → rounded‑rectangle mask.  
- **tvOS:** rectangular layout → rounded‑rectangle mask.  
- **visionOS/watchOS:** square layout → circular mask.

> Provide **unmasked, full‑bleed** layers (square or rectangular as appropriate). The system applies the final mask and corners. Pre‑masking harms highlights and edges.

**Design guidance.**  
- Embrace **simplicity**; keep primary content centered.  
- Prefer **clearly defined edges** in foreground shapes.  
- Use **varying opacity** in foreground layers for liveliness and depth.  
- Design a **background** that emphasizes foreground content (subtle vertical gradients work well).  
- Prefer **vector** assets (SVG/PDF). Convert text to outlines. Use **PNG** for mesh gradients or raster art.  
- Include **text** only if essential; avoid redundant names, verbs (“Play”), or context badges.  
- Prefer illustrations to photos. Don’t mimic UI or replicate Apple hardware.

**Visual effects.** Let the system provide highlights, blur, shadows, and depth. If you add custom effects, test them thoroughly to avoid clashing with system dynamics.

**Appearances.** People can choose **default, dark, clear,** or **tinted** Home Screen icon appearances (iOS/iPadOS/macOS). Keep the icon’s core structure consistent across variants. You can also offer **alternate icons** (iOS/iPadOS/tvOS and compatible visionOS apps) selectable in your app’s settings.

**Platform considerations.**  
- **tvOS:** keep a **safe zone** so parallax scaling never crops important content.  
- **visionOS:** avoid “fake holes” in backgrounds; system highlight may invert the depth illusion.  
- **watchOS:** avoid pure black backgrounds.

---

## Layering & Assets

### Background
- Solid or gradient; full‑bleed and **opaque**.  
- Often subtle top‑to‑bottom, light‑to‑dark gradient.

### Foreground
- Multiple shapes with **crisply defined edges**.  
- Use **opacity** and overlap to create depth.

### Variants
- Provide **default, dark, clear (light/dark),** and **tinted (light/dark)** where relevant. Icon Composer can generate missing variants, but custom designs look best.

---

## Shapes by Platform

| Platform             | Layout shape | Masked shape     | Typical layout size | Style        |
|----------------------|--------------|------------------|---------------------|-------------|
| iOS, iPadOS, macOS   | Square       | Rounded rectangle| 1024×1024 px        | Layered     |
| tvOS                 | Rectangle    | Rounded rectangle| 800×480 px          | Layered (Parallax) |
| visionOS             | Square       | Circle           | 1024×1024 px        | Layered (3D) |
| watchOS              | Square       | Circle           | 1088×1088 px        | Layered     |

The system auto‑scales assets to smaller contexts (Settings, notifications, etc.).

**Supported color spaces:** sRGB, Gray Gamma 2.2, Display P3 (where available).

---

## Best Practices Checklist

- [ ] Crisp, centered foreground geometry; no feathered edges.  
- [ ] Unmasked, full‑bleed background and foreground layers.  
- [ ] Depth via overlap/opacity, not heavy drop shadows.  
- [ ] Appearance variants consistent with default icon.  
- [ ] Simplicity at small sizes; no UI screenshots or hardware replicas.  
- [ ] Tested in Icon Composer, Simulator, and on device.  
- [ ] For tvOS: respected safe zone; for visionOS: no faux concavity; for watchOS: avoid black backgrounds.

---

## Developer Notes

- **Icon Composer** (iOS/iPadOS/macOS/watchOS): import vectors, define background, tweak opacity & placement, add appearance variants, export for Xcode.  
- **Image stacks** (tvOS/visionOS): compose layers directly in the asset catalog.  
- **Alternate icons**: expose an in‑app picker and call platform APIs (see `AppIcons.swift`). Each alternate must include required variants and meet App Review Guidelines.
