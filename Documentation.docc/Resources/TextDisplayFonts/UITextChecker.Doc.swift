//
//  UITextChecker.Doc.swift
//

// MARK: - UITextChecker

/// # UITextChecker
///
/// Checks strings for misspelled words and provides correction suggestions.
///
/// Variables/Properties
/// - guesses: [String] (per query)
///
/// Functions
/// - rangeOfMisspelledWord(in:range:startingAt:wrap:language:) -> NSRange
/// - guesses(forWordRange:in:language:) -> [String]?
/// - learnWord(_:)
/// - hasLearnedWord(_:) -> Bool
/// - ignoreWord(_:)
///
/// Links
/// - DOCC: https://developer.apple.com/documentation/uikit/uitextchecker
///
/// EXAMPLE:
/// let checker = UITextChecker()
/// let text = "Ths is a tst"
/// let nsr = NSRange(location: 0, length: (text as NSString).length)
/// let miss = checker.rangeOfMisspelledWord(in: text, range: nsr, startingAt: 0, wrap: false, language: "en_US")
///
/// NOTE: Ensure the language code is installed on the device.
///
/// TODO: Integrate with UITextInput for live spell-check corrections.
