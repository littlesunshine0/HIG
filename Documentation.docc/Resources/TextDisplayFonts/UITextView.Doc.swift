//
//  UITextView.Doc.swift
//

// MARK: - UITextView

/// # UITextView
///
/// A scrollable, multiline text region that supports rich text, data detection,
/// drag & drop, and text editing.
///
/// Protocols
/// - UITextViewDelegate
/// - UIItemProviderWriting (drag)
/// - UIItemProviderReading (drop)
///
/// Variables/Properties (UITextView)
/// - text, attributedText, font, textColor, textAlignment
/// - isEditable, isSelectable, allowsEditingTextAttributes
/// - dataDetectorTypes, textContainerInset, linkTextAttributes
/// - delegate, inputAccessoryView, inputView
///
/// Functions (UITextView)
/// - scrollRangeToVisible(_:)
/// - becomeFirstResponder(), resignFirstResponder()
/// - insertText(_:)
/// - setMarkedText(_:selectedRange:)
///
/// Links
/// - DOCC: https://developer.apple.com/documentation/uikit/uitextview
///
/// EXAMPLE:
/// let tv = UITextView()
/// tv.isEditable = true
/// tv.font = .preferredFont(forTextStyle: .body)
/// tv.adjustsFontForContentSizeCategory = true
/// tv.dataDetectorTypes = [.link, .phoneNumber]
///
/// NOTE: For large documents, consider using textStorage and layoutManager for performance.
///
/// TODO: Add example for attributedText with links and custom attributes.
