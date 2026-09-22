#if canImport(UIKit)
//
//  PHButton.swift
//
//
//  Created by Phanith on 7/8/23.
//

import UIKit
import EasyAnchor

public final class PHButton: UIControl {

  /// Type of button.
  /// Available type are normal, primary, destructive.
  /// Normal: The default button style.
  /// Primary: The filled button style.
  /// Destructive: The negative button style.
  public enum ButtonType {
    case destructive
    case normal
    case primary

    @MainActor
    public var borderColor: UIColor {
      switch self {
      case .destructive:
        return Core.Color.red

      case .normal:
        return Core.Label.primary

      case .primary:
        return Core.Color.tintColor
      }
    }
  }

  /// Shape of button.
  /// Available shape are circular, plain, roundedRect
  public enum ButtonStyle {
    case circular
    case plain
    case roundedRect
  }

  /// Size of button.
  /// Available size are small and medium.
  /// Small size is 44, font 15 medium.
  /// Medium size is 52, font 16 medium.
  public enum ButtonSize {
    case small
    case medium

    public var height: CGFloat {
      switch self {
      case .small:
        return 44

      case .medium:
        return 52
      }
    }

    @MainActor
    public var font: UIFont {
      switch self {
      case .small:
        return Font.size(14, weight: .semibold)

      case .medium:
        return Font.size(16, weight: .semibold)
      }
    }
  }

  /// Border style of button.
  public enum ButtonBorderStyle {
    case none
    case border
  }

  // MARK: - Properties

  public var onTouchUpInside: Callback?

  /// Type of current button. Default is primary.
  public var type: ButtonType = .primary

  /// Style of current button. Default is roundedRect.
  public var style: ButtonStyle = .roundedRect

  /// Size of current button. Default is medium.
  public var size: ButtonSize = .medium

  /// Border style of current button. Default is none.
  public var borderStyle: ButtonBorderStyle = .none

  /// Content inset for all axis.
  public var edgeInsets: UIEdgeInsets = .init(top: 0, left: 8.0, bottom: 0.0, right: 8.0) {
    didSet {
      leadingConstraint?.constant = edgeInsets.left
      trailingConstraint?.constant = -edgeInsets.right
    }
  }

  public var showsActivityIndicator: Bool = false {
    didSet {
      isEnabled = !showsActivityIndicator
      setNeedsUpdateConfiguration()
    }
  }

  public override var isEnabled: Bool {
    didSet {
      isEnabled ? touchUp() : touchDown()
    }
  }

  private var animator = UIViewPropertyAnimator()
  private var heightConstraint: NSLayoutConstraint?
  private var leadingConstraint: NSLayoutConstraint?
  private var trailingConstraint: NSLayoutConstraint?

  private var normalBackgroundColor: UIColor? = nil {
    didSet {
      backgroundView.backgroundColor = normalBackgroundColor
    }
  }

  private var highlightedBackgroundColor: UIColor? {
    if let normalBackgroundColor, normalBackgroundColor != .clear {
      return normalBackgroundColor.withAlphaComponent(0.75)
    }
    return .clear
  }

  private var normalBorderColor: UIColor? = .clear {
    didSet {
      backgroundView.layer.borderColor = normalBorderColor?.cgColor
    }
  }

  private var highlightedBorderColor: UIColor? {
    normalBorderColor?.withAlphaComponent(0.5)
  }

  private var normalTitleColor: UIColor? = .white {
    didSet {
      titleLabel.textColor = normalTitleColor
    }
  }

  private var highlightedTitleColor: UIColor? {
    normalTitleColor?.withAlphaComponent(0.5)
  }

  private lazy var indicatorView = UIActivityIndicatorView(style: .medium).config {
    $0.isHidden = true
  }

  private lazy var titleLabel = UILabel().config {
    $0.font = size.font
    $0.textAlignment = .center
    $0.isUserInteractionEnabled = false
  }

  private lazy var leadingImageView = UIImageView().config {
    $0.contentMode = .scaleAspectFit
    $0.isUserInteractionEnabled = false
    $0.isHidden = true
    $0.size(equalTo: 24)
  }

  private lazy var trailingImageView = UIImageView().config {
    $0.contentMode = .scaleAspectFit
    $0.isUserInteractionEnabled = false
    $0.isHidden = true
    $0.size(equalTo: 24)
  }

  private lazy var stackView = UIStackView(arrangedSubviews: [leadingImageView, titleLabel, trailingImageView]).config {
    $0.axis = .horizontal
    $0.alignment = .center
    $0.spacing = 8.0
  }

  private lazy var backgroundView = UIView().config {
    if #available(iOS 13.0, *) {
      $0.layer.cornerCurve = .continuous
    }
    $0.layer.masksToBounds = true
    $0.isUserInteractionEnabled = false
    $0.backgroundColor = normalBackgroundColor
  }

  // MARK: - Init / Deinit

  public init(type: ButtonType = .primary) {
    self.type = type
    super.init(frame: .zero)

    prepareLayouts()
    setNeedsUpdateConfiguration()
  }

  required init?(coder: NSCoder) {
    fatalError()
  }

  public override func layoutSubviews() {
    super.layoutSubviews()

    switch style {
    case .circular:
      backgroundView.layer.cornerRadius = backgroundView.bounds.height / 2.0

    case .plain,
        .roundedRect:
      switch size {
      case .small:
        backgroundView.layer.cornerRadius = 8.0

      case .medium:
        backgroundView.layer.cornerRadius = 10.0
      }
    }
  }

  /// Set background color for current button. Use this method instead of property backgroundColor.
  /// - Parameter color: The provided color.
  public final func setBackgroundColor(_ color: UIColor) {
    normalBackgroundColor = color
  }

  /// Set title for current button.
  /// - Parameter title: The provided title.
  public final func setTitle(_ title: String?) {
    titleLabel.text = title
    accessibilityLabel = title
    setNeedsUpdateConfiguration()
  }

  /// Set title color for current button.
  /// - Parameter textColor: The provided color.
  public final func setTitleColor(_ textColor: UIColor) {
    normalTitleColor = textColor
  }

  /// Update current button appearance.
  public final func setNeedsUpdateConfiguration() {
    switch showsActivityIndicator {
    case true:
      stackView.arrangedSubviews.forEach { $0.isHidden = true }
      indicatorView.isHidden = false
      indicatorView.color = titleLabel.textColor
      indicatorView.startAnimating()

    case false:
      titleLabel.font = size.font
      heightConstraint?.constant = size.height
      leadingConstraint?.constant = edgeInsets.left
      trailingConstraint?.constant = -edgeInsets.right
      normalBorderColor = type.borderColor
      backgroundView.layer.borderWidth = borderStyle == .none ? 0.0 : (1.0 / UIScreen.main.scale) * 2
      titleLabel.isHidden = titleLabel.text.orEmpty.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
      leadingImageView.isHidden = leadingImageView.image == nil
      trailingImageView.isHidden = trailingImageView.image == nil
      stackView.spacing = titleLabel.isHidden ? 0.0 : 8.0
      indicatorView.stopAnimating()
      indicatorView.isHidden = true
    }

    setNeedsUpdateConstraints()
    setNeedsLayout()
    superview?.setNeedsLayout()
  }

  /// Set leading image
  /// - Parameter image: The provided image.
  public final func setLeadingImage(_ image: UIImage?, tintColor: UIColor? = nil) {
    leadingImageView.tintColor = tintColor
    leadingImageView.image = image
    leadingImageView.isHidden = image == nil
  }

  /// Set trailing image
  /// - Parameter image: The provided image.
  public final func setTrailingingImage(_ image: UIImage?, tintColor: UIColor? = nil) {
    trailingImageView.tintColor = tintColor
    trailingImageView.image = image
    trailingImageView.isHidden = image == nil
  }
}

// MARK: - Actions

extension PHButton {
  @objc
  private func touchUpInside() {
    animator = UIViewPropertyAnimator(duration: 0.5, curve: .easeOut, animations: { [self] in
      backgroundView.backgroundColor = normalBackgroundColor
      backgroundView.layer.borderColor = normalBorderColor?.cgColor
      titleLabel.textColor = normalTitleColor
      leadingImageView.alpha = 1.0
      trailingImageView.alpha = 1.0
      onTouchUpInside?()
    })
    animator.startAnimation()
  }

  @objc
  private func touchDown() {
    animator.stopAnimation(true)
    titleLabel.textColor = highlightedTitleColor
    backgroundView.backgroundColor = highlightedBackgroundColor
    backgroundView.layer.borderColor = highlightedBorderColor?.cgColor
    leadingImageView.alpha = 0.50
    trailingImageView.alpha = 0.50
  }

  @objc
  private func touchUp() {
    animator = UIViewPropertyAnimator(duration: 0.5, curve: .easeOut, animations: { [self] in
      backgroundView.backgroundColor = normalBackgroundColor
      backgroundView.layer.borderColor = normalBorderColor?.cgColor
      titleLabel.textColor = normalTitleColor
      leadingImageView.alpha = 1.0
      trailingImageView.alpha = 1.0
    })
    animator.startAnimation()
  }
}

// MARK: - Layouts

extension PHButton {
  private func prepareLayouts() {
    isAccessibilityElement = true
    accessibilityTraits = .button
    backgroundView.layout {
      addSubview($0)
      $0.fill()
    }

    stackView.layout {
      backgroundView.addSubview($0)
      $0.top()
        .bottom()

      leadingConstraint = $0.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor)
      leadingConstraint?.constant = edgeInsets.left
      leadingConstraint?.priority = .defaultHigh
      leadingConstraint?.isActive = true

      trailingConstraint = $0.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor)
      trailingConstraint?.constant = -edgeInsets.right
      trailingConstraint?.priority = .defaultHigh
      trailingConstraint?.isActive = true
    }

    indicatorView.layout {
      backgroundView.addSubview($0)
      $0.center()
    }

    heightConstraint = heightAnchor.constraint(equalToConstant: size.height)
    heightConstraint?.priority = .defaultHigh
    heightConstraint?.isActive = true

    addTarget(self, action: #selector(touchDown), for: [.touchDown, .touchDragEnter])
    addTarget(self, action: #selector(touchUp), for: [.touchDragExit, .touchCancel])
    addTarget(self, action: #selector(touchUpInside), for: [.touchUpInside])
  }
}

public extension PHButton {

  /// Build the default button.
  /// - Parameter borderStyle: Button border style.
  /// - Returns: Result of current button builder.
  static func `default`(borderStyle: ButtonBorderStyle) -> PHButton {
    PHButton(type: .normal).config {
      $0.setBackgroundColor(borderStyle == .none ? .clear : Core.Background.background)
      $0.style = .plain
      $0.size = .medium
      $0.borderStyle = borderStyle
      $0.setTitleColor(Core.Label.primary)
      $0.setNeedsUpdateConfiguration()
    }
  }

  /// Build the primary button.
  /// - Parameter borderStyle: Button border style.
  /// - Returns: Result of current button builder.
  static func primary(borderStyle: ButtonBorderStyle) -> PHButton {
    PHButton(type: .primary).config {
      $0.setBackgroundColor(borderStyle == .none ? Core.Color.tintColor : Core.Background.background)
      $0.style = .roundedRect
      $0.size = .medium
      $0.borderStyle = borderStyle
      $0.setTitleColor(borderStyle == .none ? .white : Core.Color.tintColor)
      $0.setNeedsUpdateConfiguration()
    }
  }

  /// Build the destructive button.
  /// - Parameter borderStyle: Button border style.
  /// - Returns: Result of current button builder.
  static func destructive(borderStyle: ButtonBorderStyle) -> PHButton {
    PHButton(type: .destructive).config {
      $0.setBackgroundColor(borderStyle == .none ? Core.Color.red : Core.Background.background)
      $0.style = .roundedRect
      $0.size = .medium
      $0.borderStyle = borderStyle
      $0.setTitleColor(borderStyle == .none ? .white : Core.Color.red)
      $0.setNeedsUpdateConfiguration()
    }
  }

}
#endif
