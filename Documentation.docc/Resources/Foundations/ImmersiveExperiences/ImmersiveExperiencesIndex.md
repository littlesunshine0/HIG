

# Immersive Experiences Module Index (Table of Contents)

This index catalogs the **Immersive** module by files and types. Each entry lists **Models**, **Views**, **View Models**, **Utilities/Managers**, **Protocols**, then **Variables/Properties** and **Functions** grouped by the owning type so nothing is missed.

1. SpatialSession.swift
- Models
  - Enums
    - ImmersionMode (windowed, volume, fullSpace)
    - SessionState (idle, starting, running, stopping, failed)
  - Structs
    - SessionConfig (allowsPassthrough, preferredRefreshRate, enableOcclusion)
- Views
  - None
- View Models
  - None
- Utilities / Managers
  - Classes
    - SpatialSession
- Variables/Properties
  - SpatialSession
    - state: SessionState
    - currentMode: ImmersionMode
    - config: SessionConfig
- Functions
  - SpatialSession
    - start(mode: ImmersionMode)
    - stop()
    - onStateChange(_ handler: (SessionState) -> Void)

2. SpatialLayout.swift
- Models
  - Structs
    - DistanceRule (near: CGFloat, ideal: CGFloat, far: CGFloat)
    - SizeRule (min: CGSize, ideal: CGSize, max: CGSize)
    - DepthRule (zIndex: Int, occludesPassthrough: Bool)
- Views
  - None
- View Models
  - None
- Utilities / Managers
  - Structs
    - SpatialLayout
- Variables/Properties
  - SpatialLayout
    - defaultDistance: DistanceRule
    - defaultSize: SizeRule
- Functions
  - SpatialLayout
    - place(entity: Entity, at distance: CGFloat)
    - clampSize(_ size: CGSize) -> CGSize
    - orderDepth(_ entities: [Entity]) -> [Entity]

3. GazeAndGestureInput.swift
- Models
  - Enums
    - GestureType (pinch, drag, rotate)
  - Structs
    - DwellConfig (time: TimeInterval)
- Views
  - None
- View Models
  - None
- Utilities / Managers
  - Structs
    - GazeAndGestureInput
- Variables/Properties
  - GazeAndGestureInput
    - dwell: DwellConfig
- Functions
  - GazeAndGestureInput
    - focusTarget(at gazeRay: Ray) -> Entity?
    - onGesture(_ type: GestureType, handler: @escaping (GestureContext) -> Void)
    - enableDwellSelection(_ enabled: Bool)

4. ImmersiveMaterials.swift
- Models
  - Enums
    - MaterialPreset (glass, matte, unlit, emissive)
- Views
  - None
- View Models
  - None
- Utilities / Managers
  - Structs
    - ImmersiveMaterials
- Functions
  - ImmersiveMaterials
    - material(_ preset: MaterialPreset) -> Material
    - applyEnvironmentLighting(to entity: Entity)

5. SpatialAudio.swift
- Models
  - Enums
    - DistanceCurve (linear, inverse, custom)
  - Structs
    - AudioConfig (curve: DistanceCurve, maxDistance: CGFloat)
- Views
  - None
- View Models
  - None
- Utilities / Managers
  - Structs
    - SpatialAudio
- Functions
  - SpatialAudio
    - attach(to entity: Entity, config: AudioConfig)
    - setReverbPreset(_ preset: ReverbPreset)

6. AnchorsAndPersistence.swift
- Models
  - Enums
    - AnchorKind (planeHorizontal, planeVertical, world, room)
  - Structs
    - SavedAnchor (id: UUID, transform: Transform, kind: AnchorKind)
- Views
  - None
- View Models
  - None
- Utilities / Managers
  - Structs
    - AnchorsAndPersistence
- Functions
  - AnchorsAndPersistence
    - place(on kind: AnchorKind) -> AnchorEntity
    - save(_ anchor: AnchorEntity) -> SavedAnchor
    - restore(_ saved: SavedAnchor) -> AnchorEntity?

7. ComfortAndSafety.swift
- Models
  - Structs
    - MotionPolicy (maxTranslationPerSecond: CGFloat, maxAngularVelocity: CGFloat)
- Views
  - None
- View Models
  - None
- Utilities / Managers
  - Structs
    - ComfortAndSafety
- Variables/Properties
  - ComfortAndSafety
    - reduceMotionEnabled: Bool
- Functions
  - ComfortAndSafety
    - animateOrFade(_ changes: () -> Void)
    - isWithinSafeZone(_ entity: Entity) -> Bool

8. LightingAndShadows.swift
- Models
  - Structs
    - LightingRig (keyIntensity: CGFloat, fillIntensity: CGFloat, rimIntensity: CGFloat)
- Views
  - None
- View Models
  - None
- Utilities / Managers
  - Structs
    - LightingAndShadows
- Functions
  - LightingAndShadows
    - apply(_ rig: LightingRig, to scene: Scene)
    - enableSoftShadows(_ enabled: Bool)

9. OcclusionAndDepth.swift
- Models
  - Enums
    - OcclusionMode (none, person, scene)
- Views
  - None
- View Models
  - None
- Utilities / Managers
  - Structs
    - OcclusionAndDepth
- Functions
  - OcclusionAndDepth
    - setOcclusion(_ mode: OcclusionMode)
    - sortByDepth(_ entities: [Entity]) -> [Entity]

10. ImmersiveTestingToolkit.swift
- Models
  - None
- Views
  - None
- View Models
  - None
- Utilities / Managers
  - Structs
    - ImmersiveTestingToolkit
- Functions
  - ImmersiveTestingToolkit
    - runAll()
    - measureFrameRate() -> FPSMetrics
    - auditLegibility(distances: [CGFloat]) -> [LegibilityResult]
    - verifyMotionPolicies() -> [PolicyViolation]

11. ImmersivePlatformNotes.swift
- Models
  - Structs
    - PlatformNotes (platform: String, notes: String)
- Views
  - None
- View Models
  - None
- Utilities / Managers
  - None (data only)
- Variables/Properties
  - Globals
    - visionOSNotes: PlatformNotes
    - iOSiPadOSNotes: PlatformNotes
    - macOSNotes: PlatformNotes
    - tvOSNotes: PlatformNotes
- Functions
  - None

---

**Notes**
- Favor window/volume before Full Space; escalate only when it truly helps the task.
- Keep targets within comfortable reach and eye‑level; avoid sudden camera motion.
- Persist anchors and provide a reset.

*↑ Back to Immersive Experiences Article*
