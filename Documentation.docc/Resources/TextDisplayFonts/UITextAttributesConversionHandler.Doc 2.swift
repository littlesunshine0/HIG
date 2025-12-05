//
//  UITextAttributesConversionHandler.Doc.swift
//

// MARK: - UITextAttributesConversionHandler

/// # UITextAttributesConversionHandler
///
/// A typealias defining a mutating handler for converting or updating
/// text attributes in response to font panel changes.
///
/// Typealiases
/// - UITextAttributesConversionHandler = (inout [NSAttributedString.Key: Any]) -> Void
///
/// Links
/// - DOCC: https://developer.apple.com/documentation/uikit/uitextattributesconversionhandler
///
/// EXAMPLE:
/// let handler: UITextAttributesConversionHandler = { attrs in
///     if attrs[.font] == nil { attrs[.font] = UIFont.preferredFont(forTextStyle: .body) }
/// }
///
/// NOTE: Normalize attributes from font panel to UIKit-compatible keys.
///
/// TODO: Document mapping between AppKit and UIKit attribute keys.
