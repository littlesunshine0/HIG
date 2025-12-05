//
//  UITextFormattingCoordinator.Doc.swift
//

// MARK: - UITextFormattingCoordinator

/// # UITextFormattingCoordinator
///
/// Coordinates text formatting using the standard macOS font panel, bridging updates
/// back to UIKit text components.
///
/// Utilities / Managers
/// - UITextFormattingCoordinator
///
/// Variables/Properties
/// - allowsFontPanel: Bool
///
/// Functions
/// - setSelectedAttributes(_:)
/// - updateTextAttributes(using: UITextAttributesConversionHandler)
///
/// Links
/// - DOCC: https://developer.apple.com/documentation/uikit/uitextformattingcoordinator
///
/// EXAMPLE:
/// let c = UITextFormattingCoordinator(for: .body)
/// c.setSelectedAttributes([.font: UIFont.preferredFont(forTextStyle: .body)])
///
/// NOTE: Primarily used in macCatalyst environments.
///
/// TODO: Cross-platform considerations for iPadOS with keyboard/trackpad.
