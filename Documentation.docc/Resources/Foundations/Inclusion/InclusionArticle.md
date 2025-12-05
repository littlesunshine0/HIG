# Inclusion Implementation Guide

**Summary**  
A pragmatic, Apple‑HIG–aligned blueprint for making apps and games **welcoming, understandable, and accessible to everyone** across iOS, iPadOS, macOS, tvOS, visionOS, and watchOS. This guide turns inclusion guidance into concrete files, patterns, and checks your team can apply in design, copy, UI, and code.

## Overview

Inclusive products put people first: they use **plain, respectful language**, present **approachable interfaces**, **represent diverse people and settings**, avoid stereotypes, integrate **accessibility** from the start, and localize for **languages, regions, and right‑to‑left (RTL)** contexts. This module provides drop‑in Swift/SwiftUI scaffolding to operationalize those goals in day‑to‑day work.

**What this gives you**
- A **module map** of focused Swift files (language, approachability, representation, bias checks, a11y bridge, localization/RTL, testing)
- Copy review helpers (tone, colloquialisms, pronouns, humor)
- UI guidance for approachable layouts and onboarding
- Representation & stereotype auditing checklists
- Accessibility integration surfaces (labels, perceivability, alternatives)
- Localization & RTL readiness checks (keys, pseudolocalization, asset mirroring)
- Testing & CI hooks to keep inclusion from regressing

**Cross‑links**  
- Index / API TOC: *InclusionIndex.md*  
- Code documentation façade: *Inclusion.swift*

---

## Core Principles

- **Inclusive by design**: research goals/perspectives; validate with diverse participants.
- **Welcoming language**: be clear, direct, respectful; avoid jargon and culture‑specific idioms.
- **Approachability**: present simple, predictable flows; layer learning via onboarding.
- **Representation**: depict diverse people/settings; avoid tokenism and stereotypes.
- **Accessibility**: support a spectrum of abilities; prioritize perceivability and simplicity.
- **Languages & culture**: design for localization early; support RTL and culture‑aware color.

---

## Module Map (files you’ll see)

- **InclusiveLanguage.swift** — tone/clarity checks, colloquialism detection, pronoun & gender‑neutral rewrites, humor guardrails, and copy linting helpers.
- **ApproachabilityToolkit.swift** — patterns for simple, intuitive flows and onboarding; progressive disclosure and “learn‑by‑doing” utilities.
- **GenderIdentitySupport.swift** — APIs for collecting pronouns (opt‑in), presenting inclusive gender options, and offering nongendered avatars & symbols.
- **RepresentationReviewToolkit.swift** — image/content checklists, alt‑text patterns, inclusive stock cues; encourages varied people & settings.
- **BiasAndStereotypeScanner.swift** — content heuristic scanner that flags assumptions, stereotype triggers, and exclusionary phrasing.
- **InclusiveAccessibilityBridge.swift** — glue to your Accessibility module for perceivability (labels, contrast, alternatives, motion preferences).
- **LocalizationReadiness.swift** — key extraction checks, pseudolocalization, string‑length expansion sweeps, and date/number formatting audits.
- **RTLSupport.swift** — bidirectional text validation, SF Symbols alternatives, icon mirroring, and layout flips where appropriate.
- **InclusionTestingToolkit.swift** — snapshot/automation utilities that run copy linting, RTL sweeps, a11y label coverage, and onboarding clarity checks.
- **InclusionPlatformNotes.swift** — platform notes (HIG: *no additional considerations*; still test idiom‑specific layouts).

> Keep product code free of case‑by‑case copy tweaks; pipe strings and assets through these utilities to enforce consistency.

---

## How‑to (Quick Start)

1) **Add** the Inclusion files to your project and wire the testing hooks into your CI.  
2) **Run copy linting** across all visible strings: titles, buttons, alerts, empty‑states.  
3) **Audit onboarding** for progressive disclosure and skip paths.  
4) **Review images** for representation & alt text; remove culture‑specific metaphors unless essential & explained.  
5) **Bridge a11y**: ensure perceivable labels, motion/contrast preferences respected.  
6) **Internationalize**: externalize strings, enable pseudolocalization, test RTL, and check icon mirroring.  
7) **Ship** after InclusionTestingToolkit passes.

**SwiftUI snippet — inclusive copy + a11y label**
```swift
import SwiftUI

struct ShareButton: View {
  var body: some View {
    Button {
      // action
    } label: {
      Label("Share", systemImage: "square.and.arrow.up")
    }
    .accessibilityLabel("Share") // explicit label for clarity in all locales
    .task { CopyLint.lint("Share") } // InclusiveLanguage: log idioms/jargon if any
  }
}
```

**UIKit snippet — pronouns opt‑in**
```swift
struct PronounSet: Codable { let subject: String; let object: String; let possessive: String }
let allowed = GenderIdentitySupport.defaultPronouns(locale: .current)
// Store only if *explicitly* provided by the person.
```

---

## Recipes / Implementation Notes

### Welcoming language
- Prefer **you/your** over *user/player*; reserve **we/our** for the product or company.
- Replace colloquialisms and idioms with plain language; avoid culture‑specific humor.
- Define specialized terms on first use and keep a plain‑language fallback.

### Approachability
- Use predictable layouts and familiar components; limit required prior knowledge.  
- Design onboarding to help newcomers progress while letting experts skip.

### Gender identity
- Avoid unnecessary gender references; when needed, provide **nonbinary/self‑identify/decline to state**.  
- Favor **nongendered** avatars & glyphs; let people customize.

### People & settings
- Show a range of races, ages, body types, abilities, and contexts; avoid stereotypes and affluence‑only scenes unless essential.

### Avoiding stereotypes
- Replace assumption‑driven flows (e.g., culture‑specific security questions) with **universal** alternatives.

### Accessibility
- Treat accessibility as a core inclusion pillar: perceivability, operability, simplicity.  
- Use your existing **Accessibility** module: labels, dynamic type, contrast, motion policies.

### Languages & RTL
- Internationalize early: externalize strings, avoid concatenation, handle pluralization.  
- Support RTL mirroring where icons imply direction; prefer SF Symbols variants.  
- Consider culture‑specific color meanings when using color to communicate.

---

## Platform Differences

HIG notes **no additional considerations** for iOS, iPadOS, macOS, tvOS, visionOS, or watchOS. Still validate idiom‑specific UI (focus on tvOS; depth/legibility on visionOS).

---

## Testing & CI

- **Copy linting**: idioms, jargon, pronouns, localization keys present.  
- **Onboarding clarity**: skip paths, step hints, help surfaces.  
- **Representation**: image sweeps, alt text present.  
- **A11y coverage**: label presence, contrast checks, Reduce Motion.  
- **Localization/RTL**: pseudolocalization, truncation, bidi rendering, mirrored icons.

---

## References (HIG & Docs)
- HIG: **Inclusion**; **Accessibility**; **Right to left**; **Designing for platforms**; **Onboarding**.  
- Apple Style Guide: **Writing inclusively** / **Writing about disability**.  
- Developer docs: **Localization (Xcode)**.  
- Related: **SF Symbols**, **Color** (culture & contrast), **Typography** (legibility).

*↑ Back to Inclusion Index*
