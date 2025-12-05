# Motion Module Index (Table of Contents)

This index catalogs the **Motion** module by files and types. Each entry lists **Models**, **Views**, **View Models**, **Utilities/Managers**, **Protocols**, then **Variables/Properties** and **Functions** grouped by the owning type so nothing is missed.

1. MotionTokens.swift
- Models
  - Enums
    - MotionDuration (xShort, short, medium, long)
    - MotionCurve (linear, easeIn, easeOut, easeInOut, spring)
    - MotionDistance (near, mid, far)
  - Structs
    - SpringSpec (response: Double, damping: Double, blendDuration: Double)
- Utilities / Managers
  - Structs
    - MotionTokens
- Variables/Properties
  - MotionTokens
    - defaultDurations: [MotionDuration: TimeInterval]
    - defaultCurves: [MotionCurve: Any]
    - defaultSprings: [String: SpringSpec]
- Functions
  - MotionTokens
    - duration(_ d: MotionDuration) -> TimeInterval
    - curve(_ c: MotionCurve) -> Any
    - spring(_ name: String) -> SpringSpec

2. MotionPolicies.swift
- Models
  - Enums
    - MotionPolicy (reduced, standard, enhanced)
    - Interruptibility (interruptible, uninterruptible)
  - Structs
    - MotionSettings (reduceMotion: Bool, preferCrossFade: Bool, allowOscillation: Bool)
- Utilities / Managers
  - Structs
    - MotionPolicies
- Variables/Properties
  - MotionPolicies
    - reduceMotionEnabled: Bool
- Functions
  - MotionPolicies
    - currentPolicy() -> MotionPolicy
    - shouldCrossFade() -> Bool
    - isOscillationAllowed(frequencyHz: Double) -> Bool // avoid ~0.2 Hz

3. MotionEngine.swift
- Models
  - Structs
    - AnimationHandle (cancel: () -> Void, isRunning: Bool)
- Utilities / Managers
  - Classes
    - MotionEngine
- Functions
  - MotionEngine
    - animate(duration: TimeInterval, curve: MotionCurve, animations: () -> Void, completion: (() -> Void)?) -> AnimationHandle
    - animateSpring(spec: SpringSpec, animations: () -> Void) -> AnimationHandle
    - crossFade(_ changes: () -> Void, duration: TimeInterval) -> AnimationHandle
    - cancelAll()

4. FeedbackAnimations.swift
- Models
  - Enums
    - FeedbackEvent (success, warning, error, selection, impactLight, impactMedium, impactHeavy)
  - Structs
    - FeedbackStyle (haptic: Bool, audio: Bool, motion: Bool)
- Utilities / Managers
  - Structs
    - FeedbackAnimations
- Functions
  - FeedbackAnimations
    - play(_ event: FeedbackEvent)
    - pulse(view: PlatformView, scale: CGFloat = 1.04, duration: TimeInterval = 0.18)
    - shake(view: PlatformView, amplitude: CGFloat = 8, cycles: Int = 2)

5. TransitionLibrary.swift
- Models
  - Enums
    - TransitionKind (fade, crossFade, slide, scale, depth, matchedGeometry, flip)
- Utilities / Managers
  - Structs
    - TransitionLibrary
- Functions
  - TransitionLibrary
    - transition(for kind: TransitionKind) -> Any // SwiftUI AnyTransition / UIKit animator
    - apply(to view: PlatformView, kind: TransitionKind)
    - reducedMotionFallback() -> TransitionKind // typically .crossFade

6. GestureLinkedMotion.swift
- Models
  - Structs
    - GestureProgress (fraction: CGFloat, velocity: CGFloat)
- Utilities / Managers
  - Structs
    - GestureLinkedMotion
- Functions
  - GestureLinkedMotion
    - attachPanDismiss(to view: PlatformView)
    - update(progress: GestureProgress)
    - completeOrCancel()

7. MotionAccessibilityBridge.swift
- Utilities / Managers
  - Structs
    - MotionA11y
- Functions
  - MotionA11y
    - reduceMotionEnabled() -> Bool
    - prefersCrossFade() -> Bool
    - flashGuard(on view: PlatformView)
    - preventOscillationNear(_ frequencyHz: Double) -> Bool

8. VisionOSMotionGuidelines.swift
- Models
  - Structs
    - ComfortSpec (avoidPeriphery: Bool, maxAngularVelocity: CGFloat, translucencyBoost: CGFloat, contrastReduction: CGFloat)
- Utilities / Managers
  - Structs
    - VisionOSMotionGuidelines
- Functions
  - VisionOSMotionGuidelines
    - applyComfortSpec(_ spec: ComfortSpec)
    - fadeRelocation(_ changes: () -> Void)
    - maintainStationaryFrame()

9. tvOSFocusMotion.swift
- Utilities / Managers
  - Structs
    - tvOSFocusMotion
- Functions
  - tvOSFocusMotion
    - applyParallax(to view: PlatformView)
    - focusBounce(view: PlatformView)
    - focusSafeRegionInsets() -> EdgeInsets

10. WatchOSMotionGuidelines.swift
- Utilities / Managers
  - Structs
    - WatchOSMotionGuidelines
- Functions
  - WatchOSMotionGuidelines
    - animateGlanceableChange(on view: PlatformView)
    - minimizeContinuousMotion()

11. MotionTestingToolkit.swift
- Utilities / Managers
  - Structs
    - MotionTestingToolkit
- Functions
  - MotionTestingToolkit
    - measureFPS() -> Double
    - verifyCancelable() -> Bool
    - sweepReduceMotion() -> [String]
    - detectOscillationFrequency(_ samples: [Double]) -> Double
    - peripheryMotionAudit() -> [String]

12. MotionPlatformNotes.swift
- Models
  - Structs
    - PlatformMotionNotes (platform, notes)
- Variables/Properties
  - Globals
    - iOSiPadOSNotes: PlatformMotionNotes
    - macOSNotes: PlatformMotionNotes
    - tvOSNotes: PlatformMotionNotes
    - visionOSNotes: PlatformMotionNotes
    - watchOSNotes: PlatformMotionNotes
- Functions
  - None (data only)

---

**Notes**
- Prefer concise, purposeful motion; always provide non‑motion alternatives (haptics/audio/state changes).
- Honor **Reduce Motion** and let people cancel/interrupt at any time.
- Avoid sustained oscillation near ~0.2 Hz and peripheral motion in immersive contexts.

*↑ Back to Motion Article*
