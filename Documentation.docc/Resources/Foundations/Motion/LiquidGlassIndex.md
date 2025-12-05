# Liquid Glass Module Index (Table of Contents)

This index catalogs the Liquid Glass module by files and types. Each entry lists Models, Utilities/Managers, then Variables/Properties and Functions grouped by the owning type.

1. GlassMaterials.swift
- Models
  - Enums
    - GlassLayer (foreground, middle, background)
  - Structs
    - IconLayer (id: String, opacity: Double, zIndex: Int)
    - GlassMaterialSpec (translucency: Double, blurRadius: Double, highlight: Double, shadow: Double)
- Utilities / Managers
  - Structs
    - GlassMaterials
- Functions
  - GlassMaterials
    - applySystemGlass(to view: PlatformView)
    - removeCustomBackgrounds(in container: PlatformView)
    - composeIconLayers(_ layers: [IconLayer])
    - previewIconWithSystemEffects()

2. LiquidGlassAdoptionChecklist.swift
- Models
  - Structs
    - GlassAdoptionChecklist (usesStandardComponents: Bool, removesCustomBackgrounds: Bool, honorsA11yTransparency: Bool, honorsReduceMotion: Bool)
- Utilities / Managers
  - Structs
    - LiquidGlassAdoptionChecklist
- Functions
  - LiquidGlassAdoptionChecklist
    - runAdoptionAudit() -> [String]
    - fixCommonConflicts()

3. GlassControls.swift
- Models
  - Structs
    - ControlAudit (crowding: Bool, overlap: Bool, colorUsage: String, usesSystemSpacing: Bool)
- Utilities / Managers
  - Structs
    - GlassControls
- Functions
  - GlassControls
    - registerScrollEdgeEffect(for view: PlatformView)
    - adoptRoundedGeometry()
    - adoptStandardButtonStyles()
    - verifyControlLegibility() -> [String]

4. GlassNavigationLayer.swift
- Models
  - Structs
    - NavigationAudit (hierarchyClear: Bool, contentSeparation: Bool, safeAreas: Bool)
- Utilities / Managers
  - Structs
    - GlassNavigationLayer
- Functions
  - GlassNavigationLayer
    - configureAdaptiveNavigation()
    - enableTabBarMinimizeBehavior(_ behavior: TabBarMinimizeBehavior)
    - configureSplitViewLayout()
    - extendBackgroundUnderSidebar()

5. GlassMenusAndToolbars.swift
- Models
  - Structs
    - ToolbarGrouping (groups: [[String]], fixedSpacers: Int, iconographyPolicy: String)
- Utilities / Managers
  - Structs
    - GlassMenusAndToolbars
- Functions
  - GlassMenusAndToolbars
    - adoptStandardMenuIcons()
    - groupToolbarItems(_ groups: [[ToolbarItem]])
    - auditToolbarCustomizations() -> [String]
    - ensureIconAccessibilityLabels()

6. GlassWindowsAndModals.swift
- Models
  - Structs
    - WindowResizingPolicy (minWidth: CGFloat, minHeight: CGFloat, supportsContinuousResize: Bool)
    - SheetBehavior (cornerRadius: CGFloat, insetEdges: Edge.Set, opacityOnExpand: Double)
- Utilities / Managers
  - Structs
    - GlassWindowsAndModals
- Functions
  - GlassWindowsAndModals
    - supportArbitraryWindowSizes(_ policy: WindowResizingPolicy)
    - adoptSplitViewForResizing()
    - auditSheetEdgesAndContent() -> [String]
    - setActionSheetSourceAnchor()

7. GlassOrganizationAndLayout.swift
- Models
  - Structs
    - ListStyleGuidelines (rowHeight: CGFloat, padding: CGFloat, sectionCornerRadius: CGFloat)
- Utilities / Managers
  - Structs
    - GlassOrganizationAndLayout
- Functions
  - GlassOrganizationAndLayout
    - adoptTitleStyleSectionHeaders()
    - adoptGroupedFormStyle()
    - auditOvercrowding() -> [String]

8. GlassSearchConventions.swift
- Models
  - Structs
    - SearchConventions (placement: String, tabRole: String, keyboardInteraction: String)
- Utilities / Managers
  - Structs
    - GlassSearchConventions
- Functions
  - GlassSearchConventions
    - markSearchTabRole()
    - verifySearchKeyboardBehavior() -> [String]

9. GlassPlatformConsiderations.swift
- Models
  - Structs
    - PlatformSupport (watchOS: String, tvOS: String, iOSiPadOS: String, macOS: String)
- Utilities / Managers
  - Structs
    - GlassPlatformConsiderations
- Functions
  - GlassPlatformConsiderations
    - adoptWatchOSToolbarsAndButtons()
    - adoptTVOSFocusAPIs()
    - profileAcrossDevices()

10. GlassEffectContainerBridge.swift
- Utilities / Managers
  - Structs
    - GlassEffectContainerBridge
- Functions
  - GlassEffectContainerBridge
    - combineCustomEffectsWithGlassContainer()
    - verifyMorphingPerformance() -> [String]

11. LiquidGlassTestingToolkit.swift
- Utilities / Managers
  - Structs
    - LiquidGlassTestingToolkit
- Functions
  - LiquidGlassTestingToolkit
    - measureUIFPS() -> Double
    - sweepReduceTransparencyAndMotion() -> [String]
    - detectCustomBackgroundConflicts() -> [String]
    - verifyTabBarMinimizeBehavior() -> Bool

12. LiquidGlassPlatformNotes.swift
- Models
  - Structs
    - LiquidGlassNotes (platform: String, notes: String)
- Variables/Properties
  - Globals
    - iOSiPadOSNotes: LiquidGlassNotes
    - macOSNotes: LiquidGlassNotes
    - tvOSNotes: LiquidGlassNotes
    - watchOSNotes: LiquidGlassNotes
- Functions
  - None (data only)

---

Notes
- Prefer standard components; avoid layering custom backgrounds over system materials.
- Keep navigation distinct from content; use split views and background extension effects.
- Honor Reduce Transparency and Reduce Motion; provide comfortable fallbacks.
- Validate search placement/behavior and toolbar/menu iconography.
- Test across platforms; combine custom effects using GlassEffectContainer for performance.
