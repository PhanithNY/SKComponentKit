//
//  SKDialogueViewController.swift
//  SKComponentKit
//
//  Created by Suykorng on 22/9/26.
//

#if canImport(UIKit)
import UIKit
import EasyAnchor

open class SKDialogueViewController: UIViewController {

  // MARK: - Properties

  /// Adjust content when keyboad appear/disappear. Default is true.
  open var allowKeyboardObservation: Bool {
    true
  }

  /// Allow dismissal when tap outside of contentView's bounds. Default is false.
  open var allowDismissOnTap: Bool {
    false
  }

  /// Radius of contentView. Defualt is 10.
  open var cornerRadius: CGFloat {
    10
  }

  /// X-Axis padding for contentView. Defualt is 50.
  open var horizontalPadding: CGFloat {
    50
  }

  /// Slide in from bottom transition. Default is true.
  open var prefersSlideInTransition: Bool {
    true
  }

  /// Show visual effect view as background. Defualt is true.
  open var prefersVisualEffect: Bool {
    true
  }

  /// Animation duration. Default is 0.3
  open var transitionDuration: TimeInterval {
    0.3
  }

  /// Intensity of blurness when enabled visual effect. Default is 1 (100%).
  open var blurIntensity: CGFloat {
    1.0
  }

  /// SKCallback when deinit.
  public var onDeinit: (@Sendable () -> Swift.Void)?

  /// SKCallback when tap outside contentView's bounds.
  public var onTapOutside: (() -> Swift.Void)?

  /// Background color of visual effect view. Default is nil.
  public var effectViewBackgroundColor: UIColor? {
    didSet {
      if let effectViewBackgroundColor = effectViewBackgroundColor {
        effectView.backgroundColor = effectViewBackgroundColor
      }
    }
  }

  /// Container view. Add subview to this instead of view.
  public lazy var contentView = UIView().config {
    $0.backgroundColor = .systemBackground
    $0.layer.cornerRadius = cornerRadius
    $0.layer.masksToBounds = true
    if #available(iOS 13.0, *) {
      $0.layer.cornerCurve = .continuous
    }
  }

  private lazy var effectView: SKCustomIntensityVisualEffectView = {
    let effect: UIBlurEffect
    if #available(iOS 13.0, *) {
      effect = UIBlurEffect(style: .systemThinMaterialDark)
    } else {
      effect = UIBlurEffect(style: .dark)
    }
    let effectView = SKCustomIntensityVisualEffectView(effect: effect, intensity: blurIntensity)
    return effectView
  }()

  // MARK: - Init / Deinit

  public init() {
    super.init(nibName: nil, bundle: nil)

    modalPresentationStyle = .overCurrentContext
    modalTransitionStyle = .crossDissolve
  }

  required public init?(coder: NSCoder) {
    fatalError()
  }

  deinit {
    onDeinit?()
    NotificationCenter.default.removeObserver(self)
  }

  // MARK: - ViewController's lifecycle

  public override var prefersHomeIndicatorAutoHidden: Bool {
    true
  }

  open override func loadView() {
    super.loadView()

    prepareLayouts()
  }

  open override func viewDidLoad() {
    super.viewDidLoad()

    if allowKeyboardObservation {
      addKeyboardObservers()
    }

    if prefersSlideInTransition {
      contentView.setNeedsLayout()
      contentView.layoutIfNeeded()

      let transform: CGAffineTransform = .init(translationX: 0, y: contentView.bounds.height)
      contentView.transform = transform
      contentView.alpha = 0.0
    }
  }

  open override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    UIView.animate(withDuration: transitionDuration, delay: 0.0, options: [.curveEaseInOut]) { [self] in
      contentView.transform = .identity
      contentView.alpha = 1.0
    } completion: { _ in }
  }

  // MARK: - Actions

  @objc
  public final func dismissWithSlideOut(_ completion: (() -> Void)? = nil) {
    let transform: CGAffineTransform = .init(translationX: 0, y: contentView.bounds.height)
    UIView.animate(withDuration: transitionDuration, delay: 0.0, options: [.curveEaseInOut]) { [self] in
      contentView.transform = transform
      effectView.alpha = 0.25
      contentView.alpha = 0.0
      view.backgroundColor = UIColor.black.withAlphaComponent(0.15)
    } completion: { [self] _ in
      dismiss(animated: true, completion: completion)
    }
  }

  @objc
  private func didTap(_ gesture: UITapGestureRecognizer) {
    let location = gesture.location(in: view)
    if contentView.frame.contains(location) {
      return
    }

    onTapOutside?()
    switch prefersSlideInTransition {
    case true:
      dismissWithSlideOut(nil)

    case false:
      dismiss(animated: true, completion: nil)
    }
  }

  // MARK: - Prepare layouts

  private func prepareLayouts() {
    view.backgroundColor = UIColor.black.withAlphaComponent(0.5)

    if prefersVisualEffect {
      effectView.layout {
        view.addSubview($0)
        $0.fill()
      }
      view.backgroundColor = .clear
    }

    contentView.layout {
      view.addSubview($0)
      if UIDevice.current.userInterfaceIdiom == .pad {
        $0.width(375 - 32)
          .center()
      } else {
        if #available(iOS 11.0, *) {
          $0.left(constraint: view.safeAreaLayoutGuide.leftAnchor, horizontalPadding)
            .right(constraint: view.safeAreaLayoutGuide.rightAnchor, horizontalPadding)
            .centerY()
        } else {
          $0.left(constraint: view.leftAnchor, horizontalPadding)
            .right(constraint: view.rightAnchor, horizontalPadding)
            .centerY()
        }
      }
    }

    if allowDismissOnTap {
      let tapGesture: UITapGestureRecognizer = .init(target: self, action: #selector(didTap(_:)))
      tapGesture.cancelsTouchesInView = false
      view.addGestureRecognizer(tapGesture)
    }
  }
}

// MARK: - KVO

extension SKDialogueViewController {
  private func addKeyboardObservers() {
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
  }

  private func removeKeyboardObservers() {
    NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
  }

  @objc
  private func keyboardWillShow(_ notification: Notification) {
    guard let userInfo = notification.userInfo else {return}
    guard var keyboardFrame: CGRect = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {return}
    let aFrame = keyboardFrame
    keyboardFrame = contentView.convert(aFrame, from: nil)
    let intersect: CGRect = keyboardFrame.intersection(contentView.bounds)
    if !intersect.isNull {
      guard let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {return}
      guard let curveKey = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int else {return}
      let curve: Int = curveKey << 16
      UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: UIView.AnimationOptions(rawValue: UIView.AnimationOptions.RawValue(curve)), animations: {
        self.contentView.transform = .init(translationX: 0, y: -(intersect.size.height + self.horizontalPadding))
      }, completion: nil)
    }
  }

  @objc
  private func keyboardWillHide(_ notification: Notification) {
    guard let userInfo = notification.userInfo else {return}
    guard let duraton = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else {return}
    guard let curve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int else {return}
    UIView.animate(withDuration: duraton, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: UIView.AnimationOptions(rawValue: UIView.AnimationOptions.RawValue(curve)), animations: {
      self.contentView.transform = .identity
    }, completion: nil)
  }
}

public final class SKCustomIntensityVisualEffectView: UIVisualEffectView {
  /// Create visual effect view with given effect and its intensity
  ///
  /// - Parameters:
  ///   - effect: visual effect, eg UIBlurEffect(style: .dark)
  ///   - intensity: custom intensity from 0.0 (no effect) to 1.0 (full effect) using linear scale
  public init(effect: UIVisualEffect, intensity: CGFloat) {
    theEffect = effect
    customIntensity = intensity
    super.init(effect: nil)
  }

  required init?(coder aDecoder: NSCoder) { nil }


  public override func draw(_ rect: CGRect) {
    super.draw(rect)
    effect = nil
    animator?.stopAnimation(true)
    animator = UIViewPropertyAnimator(duration: 1, curve: .linear) { [weak self] in
      guard let self else { return }
      self.effect = theEffect
    }
    animator?.fractionComplete = customIntensity
  }

  private let theEffect: UIVisualEffect
  private let customIntensity: CGFloat
  private var animator: UIViewPropertyAnimator?
}
#endif
