#if canImport(UIKit)
//
//  PHTextField.swift
//
//
//  Created by Phanith on 16/04/24.
//

import UIKit

open class PHTextField: UITextField {

  /// Our custom input types. Use it to handle available cases.
  public enum InputType {
    case currency
    case `default`
    case email
    case number
    case phone
    case nonSpecialCharacter
    case customCurrency(UIKeyboardType)
    case bankAccountNumber
  }

  /// User action for our textField.
  public enum Action: CaseIterable {
    case copy
    case paste
    case selectAll
  }

  // MARK: - Properties

  /// Callback when user begin to edit (cursor inside textfield).
  public var onFocus: CallbackType<PHTextField>?

  /// Callback when user changed or switched to other input (cursor outside textfield).
  public var onLossFocus: CallbackType<PHTextField>?

  /// Callback when user tap on rightView.
  public var onRightViewTap: CallbackType<PHTextField>?

  /// Callback when user editing text (type .bankAccountNumber).
  public var onChangeBankAccountNumber: Callback?

  /// Callback when input over limit.
  public var onLimit: CallbackType<PHTextField>?

  /// All actions that allowed
  public var allowedActions: [Action] = Action.allCases

  /// If allowEditing is false, this closure will invoke when user tap.
  public var onTap: CallbackType<PHTextField>?

  /// Whether editable or not. Default is `true`.
  public var allowEditing: Bool = true

  /// Whether allow user to move cursor using keyboad. Default is false.
  public var allowCursorMovement: Bool = false

  /// Rect for left view.
  public var leftViewRect: CGRect?

  /// Rect for right view.
  public var rightViewRect: CGRect?

  /// Padding for text.
  public var padding: UIEdgeInsets = .init(top: 8, left: 8, bottom: 8, right: 8)

  /// The character that will always preserve in the first place. User cannot delete this character. Default is nil.
  public var prefixCharacter: String? = nil {
    didSet {
      if let prefixCharacter,
         prefixCharacter.trimmingCharacters(in: .whitespacesAndNewlines).isNotEmpty {
        if !["$", "៛"].contains(prefixCharacter) {
          return
        }

        if let text, text.isNotEmpty {
          var replacedText = text
            .replacingOccurrences(of: "$", with: prefixCharacter)
            .replacingOccurrences(of: "៛", with: prefixCharacter)
          if !replacedText.contains(prefixCharacter) {
            replacedText = prefixCharacter + replacedText
          }
          self.text = replacedText
        } else {
          self.text = prefixCharacter
        }
      }
    }
  }

  /// The value of current input text that excluded prefixCharacter.
  public var value: String {
    get {
      if let prefixCharacter = prefixCharacter?.trimmingCharacters(in: .whitespacesAndNewlines), prefixCharacter.isNotEmpty {
        return text.orEmpty.replacingOccurrences(of: prefixCharacter, with: "")
      }
      return text.orEmpty
    }
  }

  private var maximumAllowedCharacters: Int?
  private var preferredInputType: InputType = .default

  private let leftImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFit
    return imageView
  }()

  private lazy var rightImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFit
    imageView.isUserInteractionEnabled = true
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapRightView(_:)))
    imageView.addGestureRecognizer(tapGesture)
    return imageView
  }()

  // MARK: - Init / Deinit

  public override init(frame: CGRect) {
    super.init(frame: frame)

    prepareLayouts()
  }

  required public init?(coder: NSCoder) {
    fatalError()
  }

  public override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
    if action == #selector(copy(_:)), allowedActions.contains(.copy) {
      return true
    }

    if action == #selector(paste(_:)), allowedActions.contains(.paste) {
      return true
    }

    if action == #selector(selectAll(_:)), allowedActions.contains(.selectAll) {
      return true
    }

    return false
  }

  public override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
    var textRect = super.rightViewRect(forBounds: bounds)
    if let rect = self.rightViewRect {
      return CGRect(x: bounds.width - rect.width - rect.minX, y: rect.minY, width: rect.width, height: rect.height)
    }
    textRect.origin.x -= padding.right
    return textRect
  }

  public override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
    return leftViewRect ?? CGRect(x: 2, y: 2, width: 32, height: 32)
  }

  public override func textRect(forBounds bounds: CGRect) -> CGRect {
    return bounds.inset(by: padding)
  }

  public override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
    return bounds.inset(by: padding)
  }

  public override func editingRect(forBounds bounds: CGRect) -> CGRect {
    return bounds.inset(by: padding)
  }
}

// MARK: - Actions

public extension PHTextField {

  /// Set action that allowed user to perform like copy, paste...
  /// - Parameter actions: Actions that user can perform.
  final func setAllowedActions(_ actions: [Action]) {
    allowedActions = actions
  }

  /// Set maximum number of characters.
  /// - Parameter count: Number of allow characters.
  final func setMaximumAllowedCharacters(_ count: Int?) {
    maximumAllowedCharacters = count
  }

  /// Preferred rounded left view.
  /// - Parameter rounded: If true, round the left view.
  final func setPreferredRoundedLeftView(_ rounded: Bool) {
    if let leftView = leftView {
      let cornerRadius = rounded ? min(leftView.bounds.height, leftView.bounds.width) / 2.0 : 0.0
      leftView.layer.masksToBounds = true
      leftView.layer.cornerRadius = cornerRadius
    }
  }

  /// Set input type for textfield.
  /// - Parameter inputType: Desired input type of textfield
  final func setPreferredInputType(_ inputType: InputType) {
    preferredInputType = inputType
    switch inputType {
    case .currency:
      keyboardType = .decimalPad

    case .customCurrency(let _keyboardType):
      keyboardType = _keyboardType

    case .default,
        .nonSpecialCharacter:
      keyboardType = .default

    case .email:
      keyboardType = .emailAddress

    case .number:
      keyboardType = .numberPad

    case .phone:
      keyboardType = .phonePad

    case .bankAccountNumber:
      keyboardType = .numberPad
    }
  }

  /// Set image to left view.
  /// - Parameters:
  ///   - image: The provided image.
  ///   - tintColor: Color to tint image.
  final func setLeftViewImage(_ image: UIImage?, tintColor: UIColor?) {
    if let tintColor = tintColor {
      leftImageView.tintColor = tintColor
    }
    leftImageView.image = image

    leftView = leftImageView
    leftViewMode = .always
  }

  /// Set custom left view
  /// - Parameters:
  ///   - view: Custom view to provide.
  ///   - tappable: Interaction enable or not.
  final func setLeftView(_ view: UIView, tappable: Bool = true) {
    if tappable {
      addTapGesture(for: view)
    }
    leftView = view
    leftViewMode = .always
  }

  /// Set image to right view.
  /// - Parameters:
  ///   - image: The provided image.
  ///   - tintColor: Color to tint image.
  final func setRightViewImage(_ image: UIImage?, tintColor: UIColor?) {
    if let tintColor = tintColor {
      rightImageView.tintColor = tintColor
    }
    rightImageView.image = image

    rightView = rightImageView
    rightViewMode = .always
  }

  /// Set custom right view
  /// - Parameters:
  ///   - view: Custom view to provide.
  ///   - tappable: Interaction enable or not.
  final func setRightView(_ view: UIView, tappable: Bool = true) {
    if tappable {
      addTapGesture(for: view)
    }
    rightView = view
    rightViewMode = .always
  }

  @objc
  private func didTapRightView(_ sender: UITapGestureRecognizer) {
    onRightViewTap?(self)
  }

  private func addTapGesture(for view: UIView) {
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapRightView(_:)))
    view.isUserInteractionEnabled = true
    view.addGestureRecognizer(tapGesture)
  }
}

// MARK: - Layouts

extension PHTextField {
  private func prepareLayouts() {
    borderStyle = .roundedRect
    delegate = self
  }
}

// MARK: - UITextFieldDelegate

extension PHTextField: UITextFieldDelegate {
  public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
    if !allowEditing {
      onTap?(self)
      return false
    }

    return true
  }

  public func textFieldDidBeginEditing(_ textField: UITextField) {
    onFocus?(self)
  }

  public func textFieldDidEndEditing(_ textField: UITextField) {
    onLossFocus?(self)
  }

  public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    if let prefixCharacter,
       prefixCharacter.trimmingCharacters(in: .whitespacesAndNewlines).isNotEmpty,
       range.length > 0 && range.location == 0 {
      let changedText = NSString(string: textField.text.orEmpty).substring(with: range)
      if changedText.contains(prefixCharacter) {
        return false
      }
    }

//    if let maximumAllowedCharacters {
//      if value.unicodeScalars.count >= maximumAllowedCharacters {
//        onLimit?(self)
//      }
//
//      let text = value
//      let newLength = text.count + string.count - range.length
//      return newLength <= maximumAllowedCharacters
//    }

    switch preferredInputType {
    case .currency:
      // Only allow to enter number
      let safeSpacingNumber: String = (textField.text.orEmpty as NSString)
        .replacingCharacters(in: range, with: string)
        .replacingOccurrences(of: " ", with: "")
      if !safeSpacingNumber.isNumeric {
        return false
      }

      // Replace , with .
      // If user input , and has zero digit => 0.0
      // If user input , and has digit => input + .
      if string == ",", !value.contains(".") {
        if value.isEmpty {
          textField.text = textField.text.orEmpty + "0."
        } else {
          textField.text = textField.text.orEmpty + "."
        }
        return false
      }

      // Replace , with .
      if string == "0", value.isEmpty || value == "0" {
        if value.isEmpty {
          textField.text = textField.text.orEmpty + "0."
        } else {
          textField.text = textField.text.orEmpty + "."
        }
        return false
      }

      // If user input is not 0, and current value is 0 => prefix + input
      if string != "0", value == "0" {
        textField.text = prefixCharacter.orEmpty + string
        return false
      }

      if let maximumAllowedCharacters {
        if value.unicodeScalars.count >= maximumAllowedCharacters {
          onLimit?(self)
        }

        let text = value
        let newLength = text.count + string.count - range.length
        return newLength <= maximumAllowedCharacters && textField.text.orEmpty.limitComma(using: string, in: range)
      }

      // In case currency input, lock right decimal to 2 digit at max.
      return textField.text.orEmpty.replaceCommaWithDot(using: string, in: range)

    case .customCurrency(let inputType):
      // Only allow to enter number
      let safeSpacingNumber: String = (textField.text.orEmpty as NSString)
        .replacingCharacters(in: range, with: string)
        .replacingOccurrences(of: " ", with: "")
      if !safeSpacingNumber.isNumeric {
        return false
      }

      // Replace , with .
      // If user input , and has zero digit => 0.0
      // If user input , and has digit => input + .
      if string == ",", !value.contains("."), inputType != .numberPad {
        if value.isEmpty {
          textField.text = textField.text.orEmpty + "0."
        } else {
          textField.text = textField.text.orEmpty + "."
        }
        return false
      }

      // Replace , with .
      if string == "0", value.isEmpty || value == "0", inputType != .numberPad {
        if value.isEmpty {
          textField.text = textField.text.orEmpty + "0."
        } else {
          textField.text = textField.text.orEmpty + "."
        }
        return false
      }

      // If user input is not 0, and current value is 0 => prefix + input
      if string != "0", value == "0" {
        textField.text = prefixCharacter.orEmpty + string
        return false
      }

      if let maximumAllowedCharacters {
        if value.unicodeScalars.count >= maximumAllowedCharacters {
          onLimit?(self)
        }

        let text = value
        let newLength = text.count + string.count - range.length
        return newLength <= maximumAllowedCharacters && textField.text.orEmpty.limitComma(using: string, in: range)
      }

      return textField.text.orEmpty.limitComma(using: string, in: range)

    case .bankAccountNumber:
      let safeSpacingNumber: String = (textField.text.orEmpty as NSString)
        .replacingCharacters(in: range, with: string)
        .replacingOccurrences(of: " ", with: "")

      // Only allow to enter number
      if !safeSpacingNumber.isNumeric {
        return false
      }

      let allowedCharacters = CharacterSet.decimalDigits
      // In case have numberOfCharacters, lock max character to numberOfCharacters.
      if let maximumAllowedCharacters = maximumAllowedCharacters {
        let allowed: Bool = (safeSpacingNumber.rangeOfCharacter(from: allowedCharacters.inverted) == nil) && (safeSpacingNumber.unicodeScalars.count <= maximumAllowedCharacters)
        if allowed {
          ///For track if the case is delete or add character
          let previousRange = text?.count ?? 0
          ///Track cursor location before apply text change
          let selectRange: UITextRange? = textField.selectedTextRange
          ///TextChange
          text = safeSpacingNumber
          ///Move Cursor back
          if let selectRange = selectRange {
            ///if case is delete, offset -1. if case is adding move offset to + 1
            if let newPosition = textField.position(from: selectRange.start, offset: previousRange > safeSpacingNumber.count ? -1 : +1) {
              textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
            }
          }
          onChangeBankAccountNumber?()
        }
        return false
      }

      let allowed: Bool = (safeSpacingNumber.rangeOfCharacter(from: allowedCharacters.inverted) == nil)
      if allowed {
        ///For track if the case is delete or add character
        let previousRange = text?.count ?? 0
        ///Track cursor location before apply text change
        let selectRange: UITextRange? = textField.selectedTextRange
        ///TextChange
        text = safeSpacingNumber
        ///Move Cursor back
        if let selectRange = selectRange {
          ///if case is delete, offset -1. if case is adding move offset to + 1
          if let newPosition = textField.position(from: selectRange.start, offset: previousRange > safeSpacingNumber.count ? -1 : +1) {
            textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
          }
        }
        onChangeBankAccountNumber?()
        return false
      }

      // Default
      return (safeSpacingNumber.rangeOfCharacter(from: allowedCharacters.inverted) == nil)

    case .nonSpecialCharacter:
      let newText = (textField.text.orEmpty as NSString).replacingCharacters(in: range, with: string)
      let allowedCharacters = CharacterSet.letters.union(CharacterSet(charactersIn: " "))

      // In case have numberOfCharacters, lock max character to numberOfCharacters.
      if let maximumAllowedCharacters = maximumAllowedCharacters {
        return (newText.rangeOfCharacter(from: allowedCharacters.inverted) == nil) && (newText.unicodeScalars.count <= maximumAllowedCharacters)
      }

      // Default
      return (newText.rangeOfCharacter(from: allowedCharacters.inverted) == nil)

    case .number:
      // Only allow to enter number
      let safeSpacingNumber: String = (textField.text.orEmpty as NSString)
        .replacingCharacters(in: range, with: string)
        .replacingOccurrences(of: " ", with: "")
      if !safeSpacingNumber.isNumeric {
        return false
      }

      // In case have numberOfCharacters, lock max character to numberOfCharacters.
      if let maximumAllowedCharacters = maximumAllowedCharacters {
        let text = textField.text.orEmpty
        let newLength = text.count + string.count - range.length
        return newLength <= maximumAllowedCharacters
      }
      return true

    default:
      // In case have numberOfCharacters, lock max character to numberOfCharacters.
      if let maximumAllowedCharacters = maximumAllowedCharacters {
        let text = textField.text.orEmpty
        let newLength = text.count + string.count - range.length
        return newLength <= maximumAllowedCharacters
      }
      return true
    }
  }

  open override func closestPosition(to point: CGPoint) -> UITextPosition? {
    if allowCursorMovement {
      return super.closestPosition(to: point)
    }

    switch preferredInputType {
    case .currency,
        .customCurrency:
      return self.endOfDocument

    default:
      return super.closestPosition(to: point)
    }
  }
}
#endif
