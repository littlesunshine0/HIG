//
//  Materials.swift
//
//
//  Created by garyrobertellis on 10/21/25.
//

import Foundation

//  Materials.swift
//  Doc-style façade for the Materials module (Liquid Glass + standard materials + vibrancy + platform notes + testing)
//
//  NOTE: This file intentionally contains only doc comments and MARK separators.
//  Replace placeholders with app-specific code when integrating.
//
// References (HIG & Docs)
// - HIG: Materials (Liquid Glass; standard materials; vibrancy; platform notes)
// - Related: HIG Color (Liquid Glass color), Accessibility, Dark Mode, Typography
// - Developer: Adopting Liquid Glass; SwiftUI View.glassEffect(_:in:); SwiftUI Material; UIKit UIVisualEffectView; AppKit NSVisualEffectView
//
// Domain Map (keep in sync with MaterialsArticle.md & MaterialsIndex.md)
// - MaterialTokens.swift
// - LiquidGlassSupport.swift
// - StandardMaterialsSupport.swift
// - VibrancyAndBlurs.swift
// - MaterialApplicators.swift
// - MaterialAccessibilityBridge.swift
// - MaterialTestingToolkit.swift
// - MaterialPlatformNotes.swift
//
// MARK: - 1. MaterialTokens.swift
/// # MaterialTokens
/// Enums and defaults for Liquid Glass variants, standard materials, and vibrancy levels.
///
/// Models
/// - Enums
///   - LiquidGlassVariant: regular, clear
///   - StandardMaterial: ultraThin, thin, regular, thick
///   - VibrancyLevelLabel: label, secondaryLabel, tertiaryLabel, quaternaryLabel
///   - VibrancyLevelFill: fill, secondaryFill, tertiaryFill
///   - SeparatorVibrancy: default
///
/// Variables/Properties
/// - defaultGlass: LiquidGlassVariant = .regular
/// - defaultMaterial: StandardMaterial = .regular
///
/// Functions
/// - preferredGlass(over:) -> LiquidGlassVariant
/// - preferredStandardMaterial(for:) -> StandardMaterial
//
// MARK: - 2. LiquidGlassSupport.swift
/// # LiquidGlassSupport
/// Helpers to apply Liquid Glass correctly and decide dimming.
///
/// Models
/// - Structs
///   - GlassConfig: variant, addDimmingIfBright
///
/// Functions
/// - applyRegularGlass(_:) -> some View
/// - applyClearGlass(_:dimIfBright:) -> some View
/// - shouldDim(for:) -> Bool // ~35% behind clear glass on bright content
//
// MARK: - 3. StandardMaterialsSupport.swift
/// # StandardMaterialsSupport
/// Choose standard materials by content role and thickness.
///
/// Models
/// - Enums
///   - ContentRole: background, card, sidebar, overlay
///
/// Functions
/// - material(for:) -> Material
/// - applyMaterial(_:role:) -> some View
//
// MARK: - 4. VibrancyAndBlurs.swift
/// # VibrancyAndBlurs
/// Map vibrancy to platforms; choose blur styles; AppKit blending.
///
/// Models
/// - Enums
///   - LabelVibrancy: label, secondaryLabel, tertiaryLabel, quaternaryLabel
///   - FillVibrancy: fill, secondaryFill, tertiaryFill
///
/// Functions
/// - uikitVibrancy(for label:) -> UIVibrancyEffectStyle
/// - uikitVibrancy(for fill:) -> UIVibrancyEffectStyle
/// - appKitBlendingMode(for:) -> NSVisualEffectView.BlendingMode
//
// MARK: - 5. MaterialApplicators.swift
/// # MaterialApplicators
/// Convenience wrappers for applying materials consistently across UI frameworks.
///
/// Functions
/// - swiftUIBackground(_:material:) -> some View
/// - uiKitBlur(container:style:)
/// - uiKitVibrancy(container:style:)
/// - appKitEffect(view:material:blending:)
//
// MARK: - 6. MaterialAccessibilityBridge.swift
/// # MaterialAccessibilityBridge
/// Contrast checks and vibrant‑foreground enforcement over materials.
///
/// Functions
/// - enforceVibrantForegrounds()
/// - verifyContrast(on:) -> [Double]
/// - avoidOveruseOfGlass(in:) -> [String]
//
// MARK: - 7. MaterialTestingToolkit.swift
/// # MaterialTestingToolkit
/// Snapshot and rule checks for materials usage.
///
/// Functions
/// - runAll()
/// - snapshotOverBackgrounds(_:) -> [SnapshotResult]
/// - auditVibrancyChoices() -> [String]
/// - checkDimmingRules() -> [String]
//
// MARK: - 8. MaterialPlatformNotes.swift
/// # MaterialPlatformNotes
/// Platform differences: iOS/iPadOS materials + vibrancy; macOS blending; tvOS focus + overlays; visionOS glass; watchOS modal context.
///
/// Models
/// - Structs
///   - PlatformMaterialNotes: platform, notes
///
/// Variables/Properties
/// - iOSiPadOSNotes, macOSNotes, tvOSNotes, visionOSNotes, watchOSNotes
