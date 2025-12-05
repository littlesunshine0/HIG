# Spatial Layout Module Index (Table of Contents)

Overview
This index describes a reusable spatial layout module for visionOS. It’s designed to be integrated into any application without defining an app entry point. The module exposes managers, protocols, and utilities for field of view, anchoring, depth, scaling, interaction, volumes, and best-practice enforcement. Integration is done via a lightweight bootstrap helper and SwiftUI environment keys (optional), so you can adopt it in any existing visionOS app structure.

Integration Helpers (Library, not an entry point)

1. SpatialLayoutBootstrap.swift
- Models
  - Structs
    - SpatialLayoutConfiguration (initial policies for depth, scaling, hover spacing, limits)
- Views
  - None
- View Models
  - None
- Utilities / Managers
  - Structs
    - SpatialLayoutBootstrap (static configure/register helpers)
- Protocols
  - None
- Variables/Properties
  - SpatialLayoutBootstrap
    - isConfigured: Bool
- Functions
  - SpatialLayoutBootstrap
    - configure(using config: SpatialLayoutConfiguration)
    - registerDefaultManagers(container: SpatialLayoutContainer)
    - teardown()

2. SpatialLayoutEnvironment.swift (SwiftUI)
- Models
  - None
- Views
  - None
- View Models
  - None
- Utilities / Managers
  - Environment Keys
    - .fieldOfViewManager
    - .spatialAnchorManager
    - .depthManager
    - .scalingManager
    - .gestureHandler
    - .volumeManager
    - .bestPracticesEnforcer
- Protocols
  - None
- Variables/Properties
  - EnvironmentValues
    - fieldOfViewManager: FieldOfViewManaging
    - spatialAnchorManager: SpatialAnchorManaging
    - depthManager: DepthManaging
    - scalingManager: ScalingManaging
    - gestureHandler: GestureHandling
    - volumeManager: VolumeManaging
    - bestPracticesEnforcer: BestPracticesEnforcing
- Functions
  - View Modifiers
    - spatialLayoutManagers(_ container: SpatialLayoutContainer) -> some View

3. SpatialLayoutContainer.swift
- Models
  - None
- Views
  - None
- View Models
  - None
- Utilities / Managers
  - Classes
    - SpatialLayoutContainer (DI container for managers)
- Protocols
  - None
- Variables/Properties
  - SpatialLayoutContainer
    - fieldOfView: FieldOfViewManaging
    - anchors: SpatialAnchorManaging
    - depth: DepthManaging
    - scaling: ScalingManaging
    - gestures: GestureHandling
    - volumes: VolumeManaging
    - bestPractices: BestPracticesEnforcing
- Functions
  - SpatialLayoutContainer
    - init(fieldOfView:anchors:depth:scaling:gestures:volumes:bestPractices:)
    - static `default()` -> SpatialLayoutContainer

Field of View

4. FieldOfViewManager.swift
- Models
  - Structs
    - FOVRegion (horizontalDegrees, verticalDegrees, priority)
  - Enums
    - RecenterSource (digitalCrown, command, programmatic)
- Views
  - None
- View Models
  - Classes
    - FieldOfViewViewModel (optional)
- Utilities / Managers
  - Classes
    - FieldOfViewManager
- Protocols
  - FieldOfViewManaging (previously FOVProviding)
- Variables/Properties
  - FieldOfViewManager
    - currentRegion: FOVRegion
    - contentCenteringEnabled: Bool
    - recenterThresholdDegrees: Double
- Functions
  - FieldOfViewManager
    - isCriticalContentVisible() -> Bool
    - centerImportantContent(animated: Bool)
    - recenter(using source: RecenterSource)
    - updateFOV(from headPose: simd_float4x4)

Anchoring

5. SpatialAnchorManager.swift
- Models
  - Structs
    - AnchorSpec (id, position, orientation, uprightPreferred, angledOffset)
  - Enums
    - AnchorPlacementStyle (upright, angled)
- Views
  - None
- View Models
  - Classes
    - AnchorResolutionViewModel (optional)
- Utilities / Managers
  - Classes
    - SpatialAnchorManager
- Protocols
  - SpatialAnchorManaging (previously AnchorResolving/AnchorStoring)
- Variables/Properties
  - SpatialAnchorManager
    - activeAnchors: [UUID: AnchorSpec]
    - defaultPlacement: AnchorPlacementStyle
- Functions
  - SpatialAnchorManager
    - createAnchor(spec: AnchorSpec) -> UUID
    - resolveAnchor(id: UUID) -> AnchorSpec?
    - removeAnchor(id: UUID)
    - placeWindow(at anchorID: UUID)
    - placeVolume(at anchorID: UUID)
  - Optional Convenience
    - createAnchor(at position: simd_float3, orientation: simd_quatf, uprightPreferred: Bool) -> UUID

Depth

6. DepthManager.swift
- Models
  - Structs
    - DepthPolicy (zIndex, occlusionEnabled, shadowStyle) [internal tuning]
  - Enums
    - DepthLayer (background, midground, foreground, overlay, adaptive) [public surface]
- Views
  - None
- View Models
  - None
- Utilities / Managers
  - Classes
    - DepthManager
- Protocols
  - DepthManaging (previously DepthConfiguring)
- Variables/Properties
  - DepthManager
    - defaultPolicy: DepthPolicy
    - adaptiveDepthEnabled: Bool
- Functions
  - DepthManager
    - applyDepth(toWindow id: String, layer: DepthLayer)
    - applyDepth(toEntity entity: RealityKit.Entity, layer: DepthLayer)
    - setOcclusion(_ enabled: Bool, for entity: RealityKit.Entity)
    - updateDepthForMovement(delta: simd_float3)

Scaling

7. ScalingManager.swift
- Models
  - Structs
    - ScalingRule (mode, minScale, maxScale, lifeSizeEnabled)
  - Enums
    - ScalingMode (fixed, dynamicDistance, lifeSize)
- Views
  - None
- View Models
  - None
- Utilities / Managers
  - Classes
    - ScalingManager
- Protocols
  - ScalingManaging (previously ScalingProviding)
- Variables/Properties
  - ScalingManager
    - currentRule: ScalingRule
    - legibilityDistanceRange: ClosedRange<Float>
- Functions
  - ScalingManager
    - scale(forZDistance meters: Float) -> Float
    - applyScale(toWindow id: String, zDistance: Float)
    - applyScale(toEntity entity: RealityKit.Entity, zDistance: Float)

Interaction

8. GestureHandler.swift
- Models
  - Structs
    - HoverSpec (minSpacing, activationDelay, highlightStyle)
    - GesturePolicy (indirectPriority, directAllowed, dwellSelectionEnabled)
- Views
  - SwiftUI
    - Optional overlays for hover/selection guidance
- View Models
  - None
- Utilities / Managers
  - Classes
    - GestureHandler
- Protocols
  - GestureHandling (previously GestureConfiguring)
- Variables/Properties
  - GestureHandler
    - hoverSpec: HoverSpec
    - policy: GesturePolicy
- Functions
  - GestureHandler
    - configureIndirectGestures()
    - configureDirectGesturesIfAllowed()
    - applyHoverSpacing(to views: [AnyView])
    - handleDwellSelection(for viewID: String, dwellTime: TimeInterval)

Volumes and 3D

9. VolumeManager.swift
- Models
  - Structs
    - VolumeSpec (id, size, anchorID, contentKind)
  - Enums
    - VolumeContentKind (realityView, customEntityGraph)
- Views
  - visionOS
    - Volume scenes (e.g., RealityView integration)
- View Models
  - None
- Utilities / Managers
  - Classes
    - VolumeManager
- Protocols
  - VolumeManaging (previously VolumeProviding)
- Variables/Properties
  - VolumeManager
    - volumes: [String: VolumeSpec]
    - defaultSize: CGSize
- Functions
  - VolumeManager
    - createVolume(_ spec: VolumeSpec)
    - updateVolume(_ spec: VolumeSpec)
    - removeVolume(id: String)
    - attach(entity: RealityKit.Entity, toVolume id: String)
    - setDepthLayer(forVolume id: String, layer: DepthManager.DepthLayer)

Utilities

10. LayoutUtils.swift
- Models
  - Structs
    - SafeHoverZone (radius, margin)
- Views
  - None
- View Models
  - None
- Utilities / Managers
  - Structs
    - LayoutUtils
- Protocols
  - None
- Variables/Properties
  - LayoutUtils
    - defaults (spacing, alignment thresholds)
- Functions
  - LayoutUtils
    - spacing(for sizeClass: UserInterfaceSizeClass?) -> CGFloat
    - safeHoverZone(for viewBounds: CGRect) -> SafeHoverZone
    - alignToFloorIfNeeded(entity: RealityKit.Entity, tolerance: Float)

Best Practices

11. BestPracticesEnforcer.swift
- Models
  - Structs
    - PolicyLimits (maxWindows, maxVolumes, maxInteractiveDensity, minHoverSpacing)
- Views
  - None
- View Models
  - Classes
    - BestPracticesReportViewModel (optional)
- Utilities / Managers
  - Classes
    - BestPracticesEnforcer
- Protocols
  - BestPracticesEnforcing (previously PolicyEvaluating)
- Variables/Properties
  - BestPracticesEnforcer
    - limits: PolicyLimits
    - violations: [String]
- Functions
  - BestPracticesEnforcer
    - evaluateWindowCount(_ count: Int)
    - evaluateVolumeCount(_ count: Int)
    - evaluateDepthPolicies(_ policies: [DepthManager.DepthPolicy])
    - evaluateInteractionDensity(views: Int, area: CGRect)
    - generateReport() -> String

Notes
- Library-first design: No @main or App entry point. Use SpatialLayoutBootstrap and SpatialLayoutContainer to integrate into any app.
- Public surfaces: Prefer DepthLayer in public APIs; keep DepthPolicy for internal tuning.
- Optional conveniences: If you prefer the “createAnchor(at:)” convenience used in narrative docs, expose it alongside “createAnchor(spec:)”.
- Imports: Some APIs reference RealityKit.Entity, RealityView (RealityKit), simd_float3/simd_float4x4 (simd), AnyView/UserInterfaceSizeClass (SwiftUI). Ensure appropriate imports where implemented.

