# How To: Implement a Spatial Layout Architecture for visionOS

Overview
This guide shows how to implement a modular spatial layout architecture for visionOS that cleanly separates field of view, anchoring, depth, scaling, interactivity, 3D volumes, and layout utilities. It uses Swift files you can drop into your project, DocC-style notes in code comments, and a recommended app entry named SpatialExperienceApp.swift that configures your initial window or immersive space and bootstraps managers.

What this provides (facts)
- Clear separation of concerns: Managers for field of view, anchoring, depth, scaling, gestures, 3D volumes, and best-practice enforcement.
- Field-of-view awareness: Keep critical content centered and easily re-center with ergonomic controls.
- World anchoring: Place content relative to the room (not the head), supporting upright and angled viewing preferences.
- Depth management: Consistent depth cues for windows and RealityKit content with adjustable visual hierarchy.
- Adaptive scaling: Fixed and dynamic scaling, including life-size rendering and distance-aware legibility.
- Interaction handling: Indirect-first interaction tuned for comfort; hover spacing and activation thresholds.
- Volumes for 3D content: Creation, placement, and rendering of volumes with RealityKit integration.
- Layout utilities and safety checks: Spacing, alignment, safe hover zones, floor alignment helpers, and guardrails that track HIG-aligned limits.

Use cases (facts)
- Keep primary UI within the user’s comfortable field of view and smoothly re-center on demand.
- Anchor windows and volumes in the room to encourage stable, natural viewing and movement.
- Use depth cues and z-ordering to maintain clear visual hierarchy in mixed 2D/3D UIs.
- Scale content dynamically for readability as the viewer shifts distance along the z-axis.
- Offer consistent indirect gestures (pinch, tap, drag) and hover affordances that reduce fatigue.
- Introduce 3D objects in volumes with correct placement, occlusion, and lighting for presence.
- Enforce safe limits on window count, depth ranges, and interaction density.

Integration Steps
1) Add the files below to your project:
   - SpatialExperienceApp.swift (entry point, replaces MainApp.swift)
   - FieldOfViewManager.swift
   - SpatialAnchorManager.swift
   - DepthManager.swift
   - ScalingManager.swift
   - GestureHandler.swift
   - VolumeManager.swift
   - LayoutUtils.swift
   - BestPracticesEnforcer.swift

2) App entry setup (visionOS):
   - In SpatialExperienceApp.swift, configure your initial WindowGroup and any ImmersiveSpace scenes.
   - Initialize and inject your managers (e.g., via environment or a shared container).
   - Register any default spatial anchors or room placements.

3) Field of View:
   - Use FieldOfViewManager to ensure critical content stays centered/visible.
   - Wire up re-centering triggers (Digital Crown or custom command) to recentralize content.

4) Anchoring:
   - With SpatialAnchorManager, create and resolve spatial anchors for windows/volumes.
   - Choose upright or angled placements based on content type and comfort.

5) Depth and Scaling:
   - Use DepthManager to configure depth for SwiftUI windows and RealityKit entities.
   - Apply ScalingManager for dynamic or fixed scaling, including life-size rendering.

6) Interactions:
   - Configure GestureHandler for indirect-first gestures and hover spacing.
   - Ensure spacing and activation thresholds meet comfort guidelines.

7) Volumes:
   - Use VolumeManager to create, place, and update volumes for 3D content.
   - Integrate RealityKit entities and materials; set depth and occlusion policies.

8) Layout utilities and guardrails:
   - Use LayoutUtils for spacing, alignment, and safe hover zones.
   - Run BestPracticesEnforcer to monitor window counts, depth ranges, and interaction density.

Examples
- App entry (visionOS)
  - Configure WindowGroup and ImmersiveSpace in SpatialExperienceApp.swift.
  - Inject managers via environment modifiers or a shared container actor.
- Re-centering content
  - FieldOfViewManager.centerImportantContent()
  - Bind to Digital Crown or a menu action to call recenter().
- Anchoring a volume
  - SpatialAnchorManager.createAnchor(at: worldPosition) and attach volume/entity.
- Dynamic scaling
  - ScalingManager.scale(forZDistance:) to keep text/UI legible as distance changes.
- Depth layering
  - DepthManager.applyDepth(to: entity/window, policy: .foreground/.background/.adaptive)

DocC coverage and Notes
- Each file includes:
  - // <- DOCC: links to Apple documentation (visionOS, RealityKit, SwiftUI scene types)
  - // <- NOTE: usage guidance, ergonomics, and comfort considerations
  - // <- TODO: concrete tasks to validate in device/simulator
- These comments are compatible with DocC article conventions and serve as developer-facing documentation.

Preview and scene validation (facts)
- Validate window and volume placements with Xcode Previews where applicable (e.g., layout-only previews).
- Validate immersive scenes in the visionOS simulator; test anchoring, scaling, and depth transitions.
- Use logging to trace anchor resolution, depth policy changes, and gesture state transitions.

Full Source Files
Add each of the following files to your project. These are structured for clarity and DocC-style documentation. Provide implementations per your app’s needs.

- SpatialExperienceApp.swift
- FieldOfViewManager.swift
- SpatialAnchorManager.swift
- DepthManager.swift
- ScalingManager.swift
- GestureHandler.swift
- VolumeManager.swift
- LayoutUtils.swift
- BestPracticesEnforcer.swift
