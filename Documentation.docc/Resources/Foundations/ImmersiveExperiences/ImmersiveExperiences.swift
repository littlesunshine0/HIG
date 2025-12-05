//
//  ImmersiveExperiences.swift
//  Doc-style façade for the Immersive module (visionOS-first; ARKit/RealityKit patterns)
//
//  NOTE: This file intentionally contains only doc comments and MARK separators.
//  Replace placeholders with app-specific code when integrating.
//
// References (HIG & Docs)
// - Immersive Experiences (HIG)
// - Spatial Input (HIG)
// - Motion / Animation (HIG)
// - Accessibility (HIG)
// - Materials (HIG)
// - RealityKit / ARKit developer documentation
//
// Domain Map (keep in sync with ImmersiveExperiencesArticle.md & ImmersiveExperiencesIndex.md)
// - Session control: SpatialSession.swift
// - Layout rules: SpatialLayout.swift
// - Input: GazeAndGestureInput.swift
// - Materials & lighting: ImmersiveMaterials.swift, LightingAndShadows.swift
// - Audio: SpatialAudio.swift
// - Anchors & persistence: AnchorsAndPersistence.swift
// - Depth & occlusion: OcclusionAndDepth.swift
// - Comfort & safety: ComfortAndSafety.swift
// - Testing & CI: ImmersiveTestingToolkit.swift
// - Platform notes: ImmersivePlatformNotes.swift
//
// MARK: - 1. SpatialSession.swift
/// # SpatialSession
/// Starts/stops immersion, manages lifecycle, and exposes state and mode.
///
/// Models
/// - Enums
///   - ImmersionMode: windowed, volume, fullSpace
///   - SessionState: idle, starting, running, stopping, failed
/// - Structs
///   - SessionConfig: allowsPassthrough, preferredRefreshRate, enableOcclusion
///
/// Utilities / Managers
/// - Classes
///   - SpatialSession
///
/// Variables/Properties (SpatialSession)
/// - state: SessionState
/// - currentMode: ImmersionMode
/// - config: SessionConfig
///
/// Functions (SpatialSession)
/// - start(mode:) -> Void
/// - stop() -> Void
/// - onStateChange(_:) -> Void
//
// MARK: - 2. SpatialLayout.swift
/// # SpatialLayout
/// Distance/size/depth rules, occlusion settings, window↔volume transitions.
///
/// Models
/// - Structs
///   - DistanceRule: near, ideal, far
///   - SizeRule: min, ideal, max
///   - DepthRule: zIndex, occludesPassthrough
///
/// Utilities
/// - Structs
///   - SpatialLayout
///
/// Functions
/// - place(entity:at:)
/// - clampSize(_:) -> CGSize
/// - orderDepth(_:) -> [Entity]
//
// MARK: - 3. GazeAndGestureInput.swift
/// # GazeAndGestureInput
/// Gaze focus, hand gestures (pinch/drag/rotate), and dwell selection.
///
/// Models
/// - Enums
///   - GestureType: pinch, drag, rotate
/// - Structs
///   - DwellConfig: time
///
/// Utilities
/// - Structs
///   - GazeAndGestureInput
///
/// Functions
/// - focusTarget(at:) -> Entity?
/// - onGesture(_:handler:)
/// - enableDwellSelection(_:) -> Void
//
// MARK: - 4. ImmersiveMaterials.swift
/// # ImmersiveMaterials
/// Material presets and environment lighting helpers.
///
/// Models
/// - Enums
///   - MaterialPreset: glass, matte, unlit, emissive
///
/// Utilities
/// - Structs
///   - ImmersiveMaterials
///
/// Functions
/// - material(_:) -> Material
/// - applyEnvironmentLighting(to:) -> Void
//
// MARK: - 5. SpatialAudio.swift
/// # SpatialAudio
/// Spatial mixing presets, rolloff curves, and reverb.
///
/// Models
/// - Enums
///   - DistanceCurve: linear, inverse, custom
/// - Structs
///   - AudioConfig: curve, maxDistance
///
/// Utilities
/// - Structs
///   - SpatialAudio
///
/// Functions
/// - attach(to:config:) -> Void
/// - setReverbPreset(_:) -> Void
//
// MARK: - 6. AnchorsAndPersistence.swift
/// # AnchorsAndPersistence
/// Plane/world/room anchors; save & restore placements.
///
/// Models
/// - Enums
///   - AnchorKind: planeHorizontal, planeVertical, world, room
/// - Structs
///   - SavedAnchor: id, transform, kind
///
/// Utilities
/// - Structs
///   - AnchorsAndPersistence
///
/// Functions
/// - place(on:) -> AnchorEntity
/// - save(_:) -> SavedAnchor
/// - restore(_:) -> AnchorEntity?
//
// MARK: - 7. ComfortAndSafety.swift
/// # ComfortAndSafety
/// Motion budgets, blink/fade transitions, safe zones.
///
/// Models
/// - Structs
///   - MotionPolicy: maxTranslationPerSecond, maxAngularVelocity
///
/// Utilities
/// - Structs
///   - ComfortAndSafety
///
/// Variables/Properties
/// - reduceMotionEnabled: Bool
///
/// Functions
/// - animateOrFade(_:) -> Void
/// - isWithinSafeZone(_:) -> Bool
//
// MARK: - 8. LightingAndShadows.swift
/// # LightingAndShadows
/// Lighting rigs and soft shadow presets.
///
/// Models
/// - Structs
///   - LightingRig: keyIntensity, fillIntensity, rimIntensity
///
/// Utilities
/// - Structs
///   - LightingAndShadows
///
/// Functions
/// - apply(_:to:) -> Void
/// - enableSoftShadows(_:) -> Void
//
// MARK: - 9. OcclusionAndDepth.swift
/// # OcclusionAndDepth
/// Person/scene occlusion and depth sorting.
///
/// Models
/// - Enums
///   - OcclusionMode: none, person, scene
///
/// Utilities
/// - Structs
///   - OcclusionAndDepth
///
/// Functions
/// - setOcclusion(_:) -> Void
/// - sortByDepth(_:) -> [Entity]
//
// MARK: - 10. ImmersiveTestingToolkit.swift
/// # ImmersiveTestingToolkit
/// FPS, legibility, motion, and a11y audits.
///
/// Utilities
/// - Structs
///   - ImmersiveTestingToolkit
///
/// Functions
/// - runAll() -> Void
/// - measureFrameRate() -> FPSMetrics
/// - auditLegibility(distances:) -> [LegibilityResult]
/// - verifyMotionPolicies() -> [PolicyViolation]
//
// MARK: - 11. ImmersivePlatformNotes.swift
/// # ImmersivePlatformNotes
/// Platform differences and fallbacks.
///
/// Models
/// - Structs
///   - PlatformNotes: platform, notes
///
/// Variables/Properties
/// - visionOSNotes, iOSiPadOSNotes, macOSNotes, tvOSNotes
