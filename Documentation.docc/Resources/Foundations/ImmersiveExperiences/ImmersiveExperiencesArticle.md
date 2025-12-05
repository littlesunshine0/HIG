# Immersive Experiences Implementation Guide

**Summary**  
A pragmatic, visionOS‑first blueprint for building **comfortable, inclusive, and high‑performance immersive experiences** that scale from windowed 3D to volumes and Full Space. This article covers principles, module files, input (gaze, hands, voice), spatial layout, materials & lighting, audio, anchors & persistence, comfort & safety, testing/CI, and platform differences.

## Overview

Immersive experiences blend your app’s content with the user’s physical surroundings. In visionOS this spans **windows**, **volumes**, and **Full Space**. Success requires rock‑solid comfort (no nausea), clear affordances, and respectful use of the environment. This module provides Swift & SwiftUI scaffolding to ship quickly while aligning with HIG guidance.

**What this gives you**
- A **module map** of focused Swift files (session, layout, input, materials, audio, anchors, comfort, testing)
- **Input** utilities for gaze, hand gestures, dwell selection, and optional controller/keyboard
- **Spatial layout** helpers (sizes, distances, occlusion, depth ordering, passthrough usage)
- **Materials & lighting** presets that respect glass, contrast, and environment light
- **Anchors & persistence** patterns for placing content stably in the world
- **Comfort & safety** policies (movement budgets, blink/fade transitions, safe volumes)
- **Testing/CI** checklists for frame rate, reprojection, legibility and accessibility

**Cross‑links**  
- Index / API TOC: *ImmersiveExperiencesIndex.md*  
- Code documentation façade: *ImmersiveExperiences.swift*

---

## Core Principles

- **Comfort first**: avoid camera swims; prefer fades and short translations over large moves. Respect Reduce Motion.  
- **Legibility & scale**: keep text within readable angular sizes; avoid fine detail at distance; ensure contrast.  
- **Stability**: anchor content to real‑world surfaces or stable world/room anchors; avoid jitter.  
- **Respect the space**: don’t overwhelm; keep content near eye‑level and within comfortable reach distances.  
- **Discoverable input**: support gaze + hand pinch and dwell; provide visible targets and states.  
- **Inclusive by default**: keyboard, voice, switch control where appropriate; provide a11y labels and dwell alternatives.  
- **Performance**: hit device frame‑rate; manage draw calls; use efficient materials and lighting.

---

## Module Map (files you’ll see)

- **SpatialSession.swift** — starts/stops immersion; handles permissions & failures; manages `openImmersiveSpace`/`dismissImmersiveSpace` and lifecycle notifications.  
- **SpatialLayout.swift** — distance & size rules, depth ordering, occlusion, passthrough usage, window↔volume transitions.  
- **GazeAndGestureInput.swift** — gaze rays, hand poses (pinch/drag/rotate), dwell selection, focus affordances.  
- **ImmersiveMaterials.swift** — material presets (glass, matte, emissive), environment light estimation, HDR textures.  
- **SpatialAudio.swift** — spatial mixing presets, distance rolloff, occlusion/obstruction hints.  
- **AnchorsAndPersistence.swift** — plane anchors, world/room anchors, saved placements & restoration.  
- **ComfortAndSafety.swift** — motion budgets, blink/fade transitions, collision & safe‑zone helpers.  
- **LightingAndShadows.swift** — key/fill/rim presets, shadow softness, performance guardrails.  
- **OcclusionAndDepth.swift** — depth layers, person/scene occlusion toggles, ordering utilities.  
- **ImmersiveTestingToolkit.swift** — FPS & hitch detection, legibility sweeps, motion audits, a11y checks.  
- **ImmersivePlatformNotes.swift** — platform diffs and fallbacks.

> Keep UI code free of ad‑hoc world math; consume these utilities and policies instead.

---

## Quick Start (How‑to)

1) **Start a session** using `SpatialSession.start(mode:)` and open your immersive space.
```swift
@Environment(\.openImmersiveSpace) private var openImmersiveSpace

Task { await openImmersiveSpace(id: "MainImmersive") }
```
2) **Place content** with `AnchorsAndPersistence.place(on: .plane(.horizontal))` and persist user‑placed anchors.  
3) **Handle input** via `GazeAndGestureInput` focus + dwell or pinch/drag/rotate gestures.  
4) **Apply materials** from `ImmersiveMaterials` and prefer matte/neutral finishes for legibility; use glass sparingly.  
5) **Honor comfort** by routing large moves through `ComfortAndSafety.animateOrFade(...)`.  
6) **Tune audio** using `SpatialAudio.attach(to:)` with preset distance curves.  
7) **Ship** after running `ImmersiveTestingToolkit.runAll()`.

---

## Recipes / Implementation Notes

### Windows → Volumes → Full Space
- Start windowed; add a **Volume** for 3D objects that benefit from parallax; escalate to **Full Space** only when the value is clear and comfort is preserved.  
- Keep targets within comfortable reach (~0.5–1.5 m) and eye‑level; avoid extreme angles or behind‑the‑user positioning.

### Input & Focus
- Provide visible focus affordances; use **dwell** as a fallback where pinch is hard.  
- Keep hit targets ≥ 44×44 pt (angular size matters with distance).  
- Expose alternative inputs where reasonable (keyboard, switch, voice).

### Movement & Transitions
- Avoid long camera moves; prefer **blink/fade** for teleports or large repositioning.  
- Respect **Reduce Motion**; disable parallax and large transitions when enabled.

### Anchors & Persistence
- Favor **plane** anchors for tables/walls; restore placements on relaunch.  
- Provide a reset UI to clear anchors.

### Materials, Lighting, Occlusion
- Glass looks great but can reduce legibility; reserve color for emphasis and ensure contrast.  
- Use soft shadows and conservative emission; avoid flicker and strobing patterns.  
- Enable occlusion where it aids realism; disable if it harms clarity or costs too much performance.

---

## Platform Differences

- **visionOS**: full support for windows, volumes, Full Space, hand/eye input, spatial audio, anchors, and occlusion.  
- **iOS/iPadOS**: ARKit/RealityKit for handheld AR; no Full Space; rely on camera passthrough, plane anchors, and touch/gestures.  
- **macOS**: no head‑worn AR; preview 3D with RealityKit/SceneKit in windows; optional external device controls.  
- **tvOS**: viewer‑style 3D only; focus engine for remote input; avoid heavy parallax.  
- **watchOS**: N/A for immersive space.

---

## Testing & CI

- **Frame‑rate & hitching**: ensure steady device refresh; track worst‑frame and long frames.  
- **Legibility**: angular size sweeps for text/icons at typical distances.  
- **Comfort audits**: motion budgets, blink/fade coverage, Reduce Motion checks.  
- **A11y**: focus indicators, dwell timings, labels for interactive entities.  
- **Persistence**: anchor save/restore across sessions & lighting changes.

---

## References (HIG & Docs)
- HIG: Immersive Experiences, Spatial Input, Materials, Motion, Accessibility, Typography.  
- RealityKit / ARKit developer docs (anchors, occlusion, lighting, gestures).  
- Accessibility: focus & dwell, Reduce Motion.

*↑ Back to Immersive Experiences Index*
