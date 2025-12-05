//
//  UITextField.Doc.swift
//

// MARK: - UITextField

/// # UITextField
///
/// A control that displays editable text and sends an action message to a target object
/// when the user presses the return button.
///
/// Models
/// - Enums:
///   - BorderStyle: none, line, bezel, roundedRect
///   - ClearButtonMode: never, whileEditing, unlessEditing, always
///
/// Views
/// - Classes:
///   - UITextField
///
/// Protocols
/// - UITextFieldDelegate
///
/// Variables/Properties (UITextField)
/// - text, attributedText, placeholder, attributedPlaceholder
/// - font, textColor, textAlignment
/// - borderStyle, clearButtonMode
/// - leftView, rightView, leftViewMode, rightViewMode
/// - isSecureTextEntry, keyboardType, textContentType
/// - autocorrectionType, spellCheckingType
/// - smartQuotesType, smartDashesType, smartInsertDeleteType
/// - delegate
///
/// Functions (UITextField)
/// - becomeFirstResponder(), resignFirstResponder()
/// - textRect(forBounds:), editingRect(forBounds:), placeholderRect(forBounds:)
///
/// Links
/// - DOCC: https://developer.apple.com/documentation/uikit/uitextfield
///
/// EXAMPLE:
/// class VC: UIViewController, UITextFieldDelegate {
///     let field = UITextField()
///     override func viewDidLoad() {
///         super.viewDidLoad()
///         field.placeholder = "Email"
///         field.keyboardType = .emailAddress
///         field.borderStyle = .roundedRect
///         field.delegate = self
///     }
///     func textFieldShouldReturn(_ textField: UITextField) -> Bool {
///         textField.resignFirstResponder(); return true
///     }
/// }
///
/// NOTE: Set textContentType for better keyboard suggestions and AutoFill.
///
/// TODO: Document secure text entry best practices in sensitive flows.
