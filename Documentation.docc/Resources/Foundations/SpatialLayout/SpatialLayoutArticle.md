# Spatial Layout Implementation Guide (visionOS)

Summary
A practical, modular blueprint for building comfortable, room-aware spatial interfaces on visionOS. This guide outlines principles, implementation files, integration steps, testing guidance, and example snippets to help teams create field‑of‑view aware layouts, world‑anchored content, readable depth hierarchies, adaptive scaling, and ergonomic interactions across windows and 3D volumes.

## Overview

This document proposes a set of Swift files and SwiftUI/RealityKit utilities that can be dropped into a visionOS project. The module focuses on:
- Comfort-first presentation within a natural field of view
- Stable, world‑anchored placement of windows and volumes
- Clear depth hierarchy and occlusion control for mixed 2D/3D UIs
- Distance‑aware scaling for legibility and life‑size rendering
- Indirect‑first interaction patterns with safe hover spacing
- Guardrails that enforce Human Interface Guidelines and ergonomic limits

References:
- visionOS HIG: https://developer.apple.com/design/human-interface-guidelines/visionos
- RealityKit: https://developer.apple.com/documentation/realitykit
- SwiftUI Scenes (WindowGroup, ImmersiveSpace): https://developer.apple.com/documentation/swiftui

## Core Principles

- Comfort-first FOV: Keep primary content within a comfortable gaze cone; enable quick re‑centering.
- World anchoring: Anchor to the room (not the head) so content feels stable as people move naturally.
- Depth hierarchy: Use consistent z‑ordering, occlusion, and shadows to clarify relationships.
- Adaptive scaling: Maintain legibility across distance; support life‑size when appropriate.
- Indirect-first interaction: Prefer indirect gestures and hover affordances to reduce fatigue.
- Safe volumes: Place 3D content at natural heights/angles; avoid cluttering the central gaze area.
- Guardrails & consistency: Enforce limits (windows, volumes, density) and align with the HIG.

## File Structure (Spatial Layout)

1. SpatialExperienceApp.swift
- Entry point and composition root for spatial experiences (replaces MainApp.swift).
- Configures WindowGroup and optional ImmersiveSpace scenes.
- Initializes and injects managers (FOV, anchors, depth, scaling, gestures, volumes, best practices).

2. FieldOfViewManager.swift
- Tracks and evaluates content visibility within the user’s field of view.
- Provides centering and re‑centering utilities (e.g., Digital Crown or command).

3. SpatialAnchorManager.swift
- Anchors windows/volumes to the room with upright/angled placement styles.
- Persists and resolves anchors; exposes APIs for natural positioning.

4. DepthManager.swift
- Applies depth policies (z‑index, occlusion, shadows) to windows and RealityKit entities.
- Updates depth adaptively based on movement and scene state.

5. ScalingManager.swift
- Implements fixed, dynamic distance‑based, and life‑size scaling modes.
- Ensures text/UI legibility across z‑distance changes.

6. GestureHandler.swift
- Configures indirect‑first gestures; manages hover spacing and dwell selection.
- Provides ergonomic activation thresholds and hover highlighting hooks.

7. VolumeManager.swift
- Creates, places, and updates volumes for 3D content (RealityView integration).
- Coordinates entity attachment and depth/occlusion policy for volumes.

8. LayoutUtils.swift
- Utilities for spacing, alignment, safe hover zones, and floor alignment helpers.
- Presets for seated vs. standing ergonomics.

9. BestPracticesEnforcer.swift
- Guardrails for window/volume counts, interaction density, and depth policies.
- Produces developer‑readable reports to surface violations early.

## Integration Steps

1) Add files
- Add SpatialExperienceApp.swift, FieldOfViewManager.swift, SpatialAnchorManager.swift, DepthManager.swift, ScalingManager.swift, GestureHandler.swift, VolumeManager.swift, LayoutUtils.swift, BestPracticesEnforcer.swift.

2) Configure the app entry
- In SpatialExperienceApp.swift, define your WindowGroup and optional ImmersiveSpace.
- Bootstrap and inject managers via environment or a shared container.

3) Field of view alignment
- Use FieldOfViewManager to center critical content.
- Bind a re‑center action (Digital Crown/menu) to recentralize quickly.

4) Anchoring
- Create and resolve room anchors with SpatialAnchorManager.
- Choose upright vs angled placement styles per content type and context.

5) Depth and occlusion
- Apply DepthManager policies to windows and entities.
- Enable occlusion judiciously; maintain a readable hierarchy.

6) Scaling for legibility
- Set ScalingManager rules (fixed, dynamicDistance, lifeSize).
- Smooth scale transitions to avoid abrupt size changes.

7) Interaction ergonomics
- Favor indirect gestures; configure hover spacing and dwell selection only where beneficial.
- Ensure targets meet HIG guidance for size and spacing.

8) Volumes and 3D
- Use VolumeManager to create and place volumes at natural heights/angles.
- Attach RealityKit entities and align depth/occlusion with DepthManager.

9) Guardrails
- Run BestPracticesEnforcer checks during development and CI.
- Track limits on windows/volumes and flag high interaction density.

## Platform Notes (visionOS)

- Prefer WindowGroup for 2D UI; use ImmersiveSpace for spatial scenes requiring presence.
- Place content at comfortable focal distances; avoid excessive head movement.
- Maintain sufficient spacing between interactive elements to reduce accidental activation.
- Test both seated and standing ergonomics; provide re‑center affordances.

## Testing & Validation

- Simulator/device validation
  - Validate anchoring stability while moving around the room.
  - Verify depth transitions and occlusion behavior across entities/windows.
  - Confirm legibility across z‑distances; tune ScalingManager ranges.
- Previews
  - Use layout‑only previews for spacing/hover zones where feasible.
- Diagnostics
  - Log anchor resolution, depth policy changes, and gesture state transitions.
- Guardrails
  - Integrate BestPracticesEnforcer checks into automated UI tests.

## Example Snippets

App entry (visionOS)
```swift
// SpatialExperienceApp.swift (sketch)
import SwiftUI

@main
struct SpatialExperienceApp: App {
    init() {
        // Bootstrap managers or shared container here.
        // BestPracticesEnforcer.shared.configure(limits: ...)
    }

    var body: some Scene {
        WindowGroup("Main Window") {
            RootView()
                // Inject managers via environment if desired.
        }
        // Optional immersive content:
        // ImmersiveSpace(id: "MainImmersive") { ImmersiveRootView() }
    }
}
