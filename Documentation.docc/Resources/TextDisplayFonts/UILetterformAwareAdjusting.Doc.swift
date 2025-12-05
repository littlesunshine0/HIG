//
//  UILetterformAwareAdjusting.Doc.swift
//

// MARK: - UILetterformAwareAdjusting

/// # UILetterformAwareAdjusting
///
/// A protocol for typographic bounds-sizing behavior to correctly display text with
/// fonts containing oversize characters.
///
/// Protocols
/// - UILetterformAwareAdjusting
///
/// Variables/Properties
/// - usesLetterformAwareLayout: Bool
///
/// Functions
/// - updateTextBoundsIfNeeded()
///
/// Links
/// - DOCC: https://developer.apple.com/documentation/uikit/uiletterformawareadjusting
///
/// EXAMPLE:
/// class LetterAwareLabel: UILabel, UILetterformAwareAdjusting {
///     var usesLetterformAwareLayout = true
///     func updateTextBoundsIfNeeded() { /* adjust if needed */ }
/// }
///
/// NOTE: Helpful for scripts with tall ascenders/descenders.
///
/// TODO: Guidance for measuring typographic bounds in custom drawing.
