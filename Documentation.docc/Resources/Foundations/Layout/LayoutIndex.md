# Layout Module Index (Table of Contents)

This index catalogs the **Layout** module by files and types. Each entry lists **Models**, **Views**, **View Models**, **Utilities/Managers**, **Protocols**, then **Variables/Properties** and **Functions** grouped by the owning type so nothing is missed.

1. LayoutTokens.swift
- Models
  - Enums
    - SpacingScale (xxs, xs, s, m, l, xl, xxl)
    - RadiusScale (none, s, m, l)
    - ShadowLevel (none, s, m, l)
  - Structs
    - LayoutTokens (spacingTable, radiusTable, shadowTable)
- Utilities / Managers
  - Structs
    - LayoutTokens
- Variables/Properties
  - LayoutTokens
    - spacingTable: [SpacingScale: CGFloat]
    - radiusTable: [RadiusScale: CGFloat]
    - shadowTable: [ShadowLevel: CGFloat]
- Functions
  - LayoutTokens
    - spacing(_ scale: SpacingScale) -> CGFloat
    - radius(_ scale: RadiusScale) -> CGFloat
    - shadow(_ level: ShadowLevel) -> CGFloat

2. SpacingAndGrid.swift
- Models
  - Enums
    - GridIdiom (phone, pad, desktop, tv, watch, spatial)
  - Structs
    - GridSpec (columns: Int, gutter: CGFloat, margin: CGFloat)
- Utilities / Managers
  - Structs
    - SpacingAndGrid
- Variables/Properties
  - SpacingAndGrid
    - defaultPhone: GridSpec
    - defaultPad: GridSpec
    - defaultDesktop: GridSpec
- Functions
  - SpacingAndGrid
    - grid(for size: CGSize, idiom: GridIdiom) -> GridSpec
    - columnWidth(in width: CGFloat, spec: GridSpec) -> CGFloat

3. SafeAreasAndMargins.swift
- Models
  - Structs
    - SafeAreas (top, bottom, leading, trailing)
    - ContentInsets (top, bottom, leading, trailing)
- Utilities / Managers
  - Structs
    - SafeAreasAndMargins
- Variables/Properties
  - SafeAreas
    - top: CGFloat; bottom: CGFloat; leading: CGFloat; trailing: CGFloat
- Functions
  - SafeAreasAndMargins
    - safeAreas(for view: PlatformView) -> SafeAreas
    - contentInsets(for bars: [BarKind]) -> ContentInsets
    - applyInsets(to view: PlatformView, insets: ContentInsets)

4. AdaptiveSizing.swift
- Models
  - Enums
    - Breakpoint (compact, regular, expanded)
  - Structs
    - SizeClassContext (horizontal, vertical)
    - ReadableWidthSpec (min: CGFloat, max: CGFloat)
- Utilities / Managers
  - Structs
    - AdaptiveSizing
- Variables/Properties
  - AdaptiveSizing
    - defaultReadable: ReadableWidthSpec
- Functions
  - AdaptiveSizing
    - breakpoint(for size: CGSize, sizeClass: SizeClassContext) -> Breakpoint
    - readableWidth(for container: CGFloat, spec: ReadableWidthSpec) -> CGFloat

5. AlignmentAndHierarchy.swift
- Models
  - Enums
    - GroupLevel (section, group, item)
  - Structs
    - AlignmentGuideSpec (horizontal: HorizontalAlignment, vertical: VerticalAlignment)
- Utilities / Managers
  - Structs
    - AlignmentAndHierarchy
- Functions
  - AlignmentAndHierarchy
    - padding(for level: GroupLevel, scale: SpacingScale) -> EdgeInsets
    - dividerSpacing(between levelA: GroupLevel, _ levelB: GroupLevel) -> CGFloat

6. ContainersAndStacks.swift
- Models
  - None
- Views (SwiftUI)
  - StackContainer (configurable spacing/alignment wrapper)
- Utilities / Managers
  - Structs
    - ContainersAndStacks
- Functions
  - ContainersAndStacks
    - stackSpacing(for dynamicType: DynamicTypeSize) -> CGFloat
    - containerMaxWidth(for idiom: GridIdiom) -> CGFloat

7. GridsAndLists.swift
- Models
  - Enums
    - SectionRole (content, sidebar, accessories)
  - Structs
    - SwiftUIGridSpec (columns: [GridItem], spacing: CGFloat)
    - CompositionalSectionSpec (orthogonal: Bool, itemSize: NSCollectionLayoutSize)
- Utilities / Managers
  - Structs
    - GridsAndLists
- Functions
  - GridsAndLists
    - swiftUIGrid(for spec: SwiftUIGridSpec) -> some View
    - uikitSection(for role: SectionRole) -> NSCollectionLayoutSection

8. NavigationAndBarsLayout.swift
- Models
  - Structs
    - BarLayoutSpec (topPadding, bottomPadding, interItemSpacing)
- Utilities / Managers
  - Structs
    - NavigationAndBarsLayout
- Functions
  - NavigationAndBarsLayout
    - largeTitleTopPadding() -> CGFloat
    - toolbarSpacing(for idiom: GridIdiom) -> CGFloat
    - sidebarWidth(for platform: Platform) -> CGFloat

9. FocusAndTouchTargets.swift
- Models
  - Structs
    - TargetSpec (minTouch: CGSize, minFocus: CGSize, hitSlop: CGFloat)
- Utilities / Managers
  - Structs
    - FocusAndTouchTargets
- Variables/Properties
  - FocusAndTouchTargets
    - defaults: TargetSpec
- Functions
  - FocusAndTouchTargets
    - ensureMinSize(_ view: PlatformView)
    - focusSafeInsets(for tvOS: Bool) -> EdgeInsets

10. RTLAndLocalizationLayout.swift
- Models
  - Enums
    - SemanticDirection (ltr, rtl)
  - Structs
    - MirroringPolicy (mirrorDirectionalGlyphs: Bool)
- Utilities / Managers
  - Structs
    - RTLAndLocalizationLayout
- Functions
  - RTLAndLocalizationLayout
    - applySemantic(to view: PlatformView)
    - shouldMirror(symbol name: String) -> Bool

11. PlatformLayoutNotes.swift
- Models
  - Structs
    - PlatformLayoutNotes (platform, notes)
- Variables/Properties
  - Globals
    - iOSiPadOSNotes: PlatformLayoutNotes
    - macOSNotes: PlatformLayoutNotes
    - tvOSNotes: PlatformLayoutNotes
    - visionWatchNotes: PlatformLayoutNotes
- Functions
  - None (data only)

12. LayoutTestingToolkit.swift
- Utilities / Managers
  - Structs
    - LayoutTestingToolkit
- Functions
  - LayoutTestingToolkit
    - snapshotAtBreakpoints() -> [SnapshotResult]
    - runDynamicTypeSweeps() -> [String]
    - auditSafeAreas() -> [String]
    - exerciseRTL() -> [String]
    - verifyReadableWidth() -> [String]

---

**Notes**
- Use **leading/trailing** APIs, avoid hard left/right.
- Keep a single spacing scale; compose layout from tokens, not ad‑hoc numbers.
- Test across breakpoints, Dynamic Type sizes, RTL, and platform bars.

*↑ Back to Layout Article*
