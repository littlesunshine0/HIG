# Motion Implementation Guide

**Summary**  
A pragmatic, HIG‑aligned blueprint for purposeful, comfortable motion across iOS, iPadOS, macOS, tvOS, visionOS, and watchOS. This module turns Apple’s Motion guidance into concrete files, APIs, and test hooks so teams can ship motion that communicates state, guides attention, and respects accessibility.

## Overview

Great motion is **useful, brief, and optional**. It reinforces cause‑and‑effect, provides feedback, and clarifies spatial relationships — without getting in the way. This module provides:
- A **module map** of focused Swift files (tokens → policies → engine → feedback → transitions → gesture‑linked motion → a11y → platform notes → testing)
- Ready‑to‑use tokens for durations/curves/springs, and policies for **Reduce Motion** and cancelability
- SwiftUI & UIKit/AppKit patterns for transitions and feedback animations
- Platform diffs (visionOS peripheral motion limits, tvOS focus, watchOS glanceability)
- CI hooks to block regressions (cancelability, oscillation frequency, periphery motion, frame‑rate)

**Cross‑links**  
- Index / API TOC: *MotionIndex.md*  
- Doc façade: *Motion.swift*

---

## Core Principles

- **Purposeful**: add motion only when it clarifies state, hierarchy, or feedback.
- **Brief & precise**: prefer short, targeted animations over long theatrics.
- **Optional**: always honor **Reduce Motion** and provide non‑motion alternatives (haptics/audio/state changes).
- **Cancelable**: never trap people in a long animation; allow interruption or skip.
- **Realistic feedback**: motion should match gestures and expectations; don’t animate along axes that conflict with the gesture.
- **Comfort**: avoid sustained oscillation (~0.2 Hz), avoid peripheral motion in immersive contexts, and keep large moving objects translucent or lower contrast.
- **Performance**: favor 60 fps for UI, 30–60 fps for games; prefer lightweight transforms, opacity, and blur; avoid layout thrash.

---

## Module Map (files you’ll see)

- **MotionTokens.swift** — common durations, curves, spring specs, distances.
- **MotionPolicies.swift** — Reduce Motion, cross‑fade preference, interruptibility, oscillation guard.
- **MotionEngine.swift** — unified animation helpers (SwiftUI/UIKit/AppKit) with cancellation.
- **FeedbackAnimations.swift** — success/warning/error/selection pulses + haptics/audio bridges.
- **TransitionLibrary.swift** — semantic transitions (fade, cross‑fade, slide, scale, depth, matched‑geometry) with reduced‑motion fallbacks.
- **GestureLinkedMotion.swift** — attach interactive transitions to gestures; velocity‑aware completion; cancel/complete.
- **MotionAccessibilityBridge.swift** — checks for reduce motion, flash guards, and high‑contrast rules.
- **VisionOSMotionGuidelines.swift** — comfort rules for depth/periphery, fades for relocation, stationary frames.
- **tvOSFocusMotion.swift** — focus parallax/tilt/bounce and focus‑safe regions.
- **WatchOSMotionGuidelines.swift** — glanceable, low‑amplitude animations; respect energy constraints.
- **MotionTestingToolkit.swift** — fps metering, cancelability tests, reduce‑motion sweeps, oscillation/periphery audits.
- **MotionPlatformNotes.swift** — platform differences.

> Keep product views free of ad‑hoc timing. Import tokens/policies/engine and compose.

---

## How‑to (Quick Start)

1) **Adopt tokens**
```swift
// MotionTokens
let t = MotionTokens.duration(.short)
let spring = MotionTokens.spring(.gentle)
```
2) **Honor Reduce Motion**
```swift
if MotionPolicies.reduceMotionEnabled { TransitionLibrary.crossFade() } else { TransitionLibrary.depth() }
```
3) **Animate with cancellation**
```swift
let handle = MotionEngine.animate(duration: t, curve: .easeOut) { view.alpha = 1 } 
// later
handle.cancel()
```
4) **Pair feedback with haptics/audio**
```swift
FeedbackAnimations.play(.success)
```
5) **Tie to gestures**
```swift
GestureLinkedMotion.attachPanDismiss(to: cardView)
```
6) **Ship** after `MotionTestingToolkit.runAll()` passes.

---

## Recipes

### Feedback micro‑animations
- Use concise **scale/opacity** pulses for success/selection; keep ≤ 250 ms.
- Provide **haptic/audio** mirrors so motion isn’t the only signal.

### Transitions
- Prefer **cross‑fade** as the reduced‑motion fallback.
- Use **slide/scale/depth** when motion adds spatial clarity; avoid excessive travel distances.

### Gesture‑linked motion
- Velocity‑aware completion (fast flicks complete, slow drags snap back).
- Allow **cancel** anytime; don’t block taps during transitions.

### Avoid discomfort
- Keep large moving objects **translucent** or lower contrast.
- **No sustained oscillation** near ~0.2 Hz; if oscillation is essential, keep amplitude low and duration short.
- Avoid motion at **periphery** of field of view in immersive contexts; use fades for relocation.

### Performance budgets
- Target **60 fps** for UI (or 30–60 fps for games by platform); profile long chains of animations.

### Animated symbols
- Use SF Symbols animations for subtle, meaningful motion in icons; keep brief and consistent with context.

---

## Platform Differences

**iOS, iPadOS, macOS, tvOS**  
- System components already animate common interactions; avoid redundant custom motion.  
- tvOS: emphasize **focus** motion (parallax/tilt/bounce) and keep items in focus‑safe regions.

**visionOS**  
- Avoid peripheral motion; prefer fades for relocation; maintain a **stationary frame of reference** when possible.  
- For large moving objects/windows, increase **translucency** or reduce **contrast** to maintain comfort.

**watchOS**  
- Prioritize glanceable, low‑amplitude changes; keep durations short; avoid busy continuous motion.

---

## Testing & CI

- **FPS**: measure under load; flag < 55 fps for UI.
- **Cancelability**: assert that animations can be interrupted at any time.
- **Reduce Motion sweep**: verify cross‑fade fallbacks and disable nonessential motion.
- **Oscillation detector**: warn when content oscillates near ~0.2 Hz.
- **Periphery audit (visionOS)**: detect moving content near window edges; suggest fades.

---

## References (HIG & Docs)
- HIG — **Motion** (purposeful motion, brevity, reduce motion, cancellation, platform notes).  
- Related: **Materials / Liquid Glass**, **Feedback (Haptics/Audio)**, **Spatial Layout**, **Immersive Experiences**, **SF Symbols Animations**.  
- Developer: **Animating views and transitions — SwiftUI**, **WKInterfaceImage** (watchOS).

*↑ Back to Motion Index*
