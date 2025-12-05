//
//  Inclusion.swift
//  Doc-style façade for the Inclusion module (language, approachability, representation, a11y, localization/RTL)
//
//  NOTE: This file intentionally contains only doc comments and MARK separators.
//  Replace placeholders with app-specific code when integrating.
//
// References (HIG & Docs)
// - Inclusion (HIG)
// - Accessibility (HIG)
// - Writing inclusively (Apple Style Guide)
// - Localization — Xcode
// - Right to left (HIG)
// - SF Symbols (for nongendered/person symbols and RTL support)
//
// Domain Map (keep in sync with InclusionArticle.md & InclusionIndex.md)
// - Inclusive language: InclusiveLanguage.swift
// - Approachability & onboarding: ApproachabilityToolkit.swift
// - Gender & pronouns: GenderIdentitySupport.swift
// - Representation checks: RepresentationReviewToolkit.swift
// - Bias scanning: BiasAndStereotypeScanner.swift
// - Accessibility bridge: InclusiveAccessibilityBridge.swift
// - Localization readiness: LocalizationReadiness.swift
// - RTL: RTLSupport.swift
// - Testing/CI: InclusionTestingToolkit.swift
// - Platform notes: InclusionPlatformNotes.swift
//
// MARK: - 1. InclusiveLanguage.swift
/// # InclusiveLanguage
/// Tone/clarity checks, colloquialism detection, pronoun & gender-neutral rewrites,
/// humor guardrails, and copy linting helpers.
///
/// Models
/// - Enums
///   - CopyTone: neutral, friendly, professional
///   - ColloquialismSeverity: info, warn, block
/// - Structs
///   - CopyIssue: range, message, severity
///
/// Utilities
/// - Structs
///   - CopyLint
///
/// Functions
/// - lint(_:) -> [CopyIssue]
/// - suggestRewrites(for:) -> String
/// - enforceGenderNeutrality(in:) -> String
/// - stripHumorIfNeeded(in:) -> String
//
// MARK: - 2. ApproachabilityToolkit.swift
/// # ApproachabilityToolkit
/// Patterns for simple, intuitive flows and onboarding; progressive disclosure utilities.
///
/// Models
/// - Structs
///   - OnboardingStep: title, body, skippable
///
/// Views (SwiftUI)
/// - OnboardingFlowView: steps
///
/// Utilities
/// - Structs
///   - ApproachabilityToolkit
///
/// Functions
/// - progressiveDisclosurePlan(for:) -> [OnboardingStep]
/// - simplicityScore(for:) -> Double
//
// MARK: - 3. GenderIdentitySupport.swift
/// # GenderIdentitySupport
/// Inclusive pronouns (opt-in), options (nonbinary/self-identify/decline), and
/// nongendered avatars & symbols.
///
/// Models
/// - Structs
///   - PronounSet: subject, object, possessive
///
/// Utilities
/// - Structs
///   - GenderIdentitySupport
///
/// Variables/Properties
/// - defaultOptions: [String]
///
/// Functions
/// - defaultPronouns(locale:) -> [PronounSet]
/// - presentGenderOptions() -> [String]
//
// MARK: - 4. RepresentationReviewToolkit.swift
/// # RepresentationReviewToolkit
/// Image/content checklists, alt-text patterns, inclusive stock cues.
///
/// Models
/// - Structs
///   - ImageRepresentationCheck: id, description, result
///
/// Utilities
/// - Structs
///   - RepresentationReview
///
/// Functions
/// - audit(images:) -> [ImageRepresentationCheck]
/// - altTextTemplate(for:) -> String
//
// MARK: - 5. BiasAndStereotypeScanner.swift
/// # BiasAndStereotypeScanner
/// Heuristic scanner that flags assumptions, stereotype triggers, and exclusionary phrasing.
///
/// Models
/// - Structs
///   - BiasFinding: excerpt, category, suggestion
/// - Enums
///   - BiasCategory: family, affluence, culture, ability, gender
///
/// Utilities
/// - Structs
///   - BiasScanner
///
/// Functions
/// - scan(_:) -> [BiasFinding]
//
// MARK: - 6. InclusiveAccessibilityBridge.swift
/// # InclusiveAccessibilityBridge
/// Bridges to Accessibility module for perceivability (labels, motion, contrast).
///
/// Utilities
/// - Structs
///   - InclusiveA11y
///
/// Functions
/// - ensurePerceivable(labels:) -> Bool
/// - applyMotionPreferences() -> Void
/// - verifyContrastInContexts() -> [String]
//
// MARK: - 7. LocalizationReadiness.swift
/// # LocalizationReadiness
/// Key extraction, pseudolocalization, bidi rendering checks.
///
/// Models
/// - Structs
///   - L10nIssue: key, message
///
/// Utilities
/// - Structs
///   - LocalizationReadiness
///
/// Functions
/// - extractKeys(from:) -> [String]
/// - pseudolocalize(_:) -> String
/// - bidiRenderCheck(_:) -> Bool
//
// MARK: - 8. RTLSupport.swift
/// # RTLSupport
/// Bidirectional text validation, icon mirroring, SF Symbols alternatives.
///
/// Models
/// - Enums
///   - DirectionHint: leftToRight, rightToLeft, neutral
///
/// Utilities
/// - Structs
///   - RTLSupport
///
/// Functions
/// - needsMirroring(for:) -> Bool
/// - mirroredSymbolName(for:) -> String
//
// MARK: - 9. InclusionTestingToolkit.swift
/// # InclusionTestingToolkit
/// Snapshot/automation utilities for copy linting, RTL sweeps, a11y label coverage,
/// and onboarding clarity checks.
///
/// Utilities
/// - Structs
///   - InclusionTestingToolkit
///
/// Functions
/// - runAll() -> Void
/// - lintAllCopy(in:) -> [CopyIssue]
/// - snapshotRTL() -> Void
/// - checkOnboardingClarity() -> [String]
//
// MARK: - 10. InclusionPlatformNotes.swift
/// # InclusionPlatformNotes
/// Platform notes (HIG: no additional considerations) with idiom-specific reminders.
///
/// Models
/// - Structs
///   - PlatformInclusionNotes: platform, notes
///
/// Variables/Properties
/// - iOSiPadOSNotes, macOSNotes, tvOSNotes, visionWatchNotes
