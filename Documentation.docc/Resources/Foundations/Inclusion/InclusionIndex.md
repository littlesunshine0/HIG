# Inclusion Module Index (Table of Contents)

This index provides a hierarchical overview of the **Inclusion** module. Each file lists **Models**, **Views**, **View Models**, **Utilities/Managers**, **Protocols**, and then **Variables/Properties** and **Functions** grouped by their owning type.

1. InclusiveLanguage.swift
- Models
  - Enums
    - CopyTone (neutral, friendly, professional)
    - ColloquialismSeverity (info, warn, block)
  - Structs
    - CopyIssue (range, message, severity)
- Views
  - None
- View Models
  - None
- Utilities / Managers
  - Structs
    - CopyLint
- Protocols
  - None
- Variables/Properties
  - CopyIssue
    - range: Range<String.Index>
    - message: String
    - severity: ColloquialismSeverity
- Functions
  - CopyLint
    - lint(_ text: String) -> [CopyIssue]
    - suggestRewrites(for text: String) -> String
    - enforceGenderNeutrality(in text: String) -> String
    - stripHumorIfNeeded(in text: String) -> String

2. ApproachabilityToolkit.swift
- Models
  - Structs
    - OnboardingStep (title, body, skippable)
- Views (SwiftUI)
  - OnboardingFlowView (steps)
- View Models
  - None
- Utilities / Managers
  - Structs
    - ApproachabilityToolkit
- Protocols
  - None
- Variables/Properties
  - OnboardingStep
    - title: String
    - body: String
    - skippable: Bool
- Functions
  - ApproachabilityToolkit
    - progressiveDisclosurePlan(for feature: String) -> [OnboardingStep]
    - simplicityScore(for viewHierarchy: Any) -> Double

3. GenderIdentitySupport.swift
- Models
  - Structs
    - PronounSet (subject, object, possessive)
- Views
  - None
- View Models
  - None
- Utilities / Managers
  - Structs
    - GenderIdentitySupport
- Protocols
  - None
- Variables/Properties
  - GenderIdentitySupport
    - defaultOptions: [String] // "nonbinary", "self-identify", "decline to state"
- Functions
  - GenderIdentitySupport
    - defaultPronouns(locale: Locale) -> [PronounSet]
    - presentGenderOptions() -> [String]

4. RepresentationReviewToolkit.swift
- Models
  - Structs
    - ImageRepresentationCheck (id, description, result)
- Views
  - None
- View Models
  - None
- Utilities / Managers
  - Structs
    - RepresentationReview
- Protocols
  - None
- Variables/Properties
  - ImageRepresentationCheck
    - id: UUID
    - description: String
    - result: Bool
- Functions
  - RepresentationReview
    - audit(images: [Any]) -> [ImageRepresentationCheck]
    - altTextTemplate(for role: String) -> String

5. BiasAndStereotypeScanner.swift
- Models
  - Structs
    - BiasFinding (excerpt, category, suggestion)
  - Enums
    - BiasCategory (family, affluence, culture, ability, gender)
- Views
  - None
- View Models
  - None
- Utilities / Managers
  - Structs
    - BiasScanner
- Protocols
  - None
- Variables/Properties
  - BiasFinding
    - excerpt: String
    - category: BiasCategory
    - suggestion: String
- Functions
  - BiasScanner
    - scan(_ texts: [String]) -> [BiasFinding]

6. InclusiveAccessibilityBridge.swift
- Models
  - None
- Views
  - None
- View Models
  - None
- Utilities / Managers
  - Structs
    - InclusiveA11y
- Protocols
  - None
- Functions
  - InclusiveA11y
    - ensurePerceivable(labels: [String]) -> Bool
    - applyMotionPreferences()
    - verifyContrastInContexts() -> [String]

7. LocalizationReadiness.swift
- Models
  - Structs
    - L10nIssue (key, message)
- Views
  - None
- View Models
  - None
- Utilities / Managers
  - Structs
    - LocalizationReadiness
- Protocols
  - None
- Variables/Properties
  - L10nIssue
    - key: String
    - message: String
- Functions
  - LocalizationReadiness
    - extractKeys(from bundle: Bundle) -> [String]
    - pseudolocalize(_ text: String) -> String
    - bidiRenderCheck(_ text: String) -> Bool

8. RTLSupport.swift
- Models
  - Enums
    - DirectionHint (leftToRight, rightToLeft, neutral)
- Views
  - None
- View Models
  - None
- Utilities / Managers
  - Structs
    - RTLSupport
- Protocols
  - None
- Functions
  - RTLSupport
    - needsMirroring(for symbol: String) -> Bool
    - mirroredSymbolName(for symbol: String) -> String

9. InclusionTestingToolkit.swift
- Models
  - None
- Views
  - None
- View Models
  - None
- Utilities / Managers
  - Structs
    - InclusionTestingToolkit
- Protocols
  - None
- Functions
  - InclusionTestingToolkit
    - runAll()
    - lintAllCopy(in bundle: Bundle) -> [CopyIssue]
    - snapshotRTL()
    - checkOnboardingClarity() -> [String]

10. InclusionPlatformNotes.swift
- Models
  - Structs
    - PlatformInclusionNotes (platform, notes)
- Views
  - None
- View Models
  - None
- Utilities / Managers
  - None (data only)
- Protocols
  - None
- Variables/Properties
  - Globals
    - iOSiPadOSNotes: PlatformInclusionNotes (no additional considerations)
    - macOSNotes: PlatformInclusionNotes (no additional considerations)
    - tvOSNotes: PlatformInclusionNotes (focus legibility, discoverability)
    - visionWatchNotes: PlatformInclusionNotes (legibility in depth/size)
- Functions
  - None

---

**Notes**
- Keep strings plain and respectful; avoid idioms and culture‑specific humor.
- Prefer nongendered references and customizable avatars.
- Treat accessibility, localization, and RTL as first‑class parts of inclusion.

*↑ Back to Inclusion Article*
