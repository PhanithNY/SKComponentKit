#if canImport(UIKit)
//
//  PHScrollViewController.swift
//
//
//  Created by Suykorng on 16/4/24.
//

import UIKit
import EasyAnchor

open class PHScrollViewController: UIViewController {

  /// Callback when keyboard about to show
  public var keyboardWillShowHandler: ((CGFloat) -> Swift.Void)?

  /// Callback when keyboard about to hide
  public var keyboardWillHideHandler: (() -> Swift.Void)?

  /// Automatically adjust content base on keyboard hide/show. Default is false.
  open var allowedKeyboardObservation: Bool {
    false
  }

  open var stickBottomContentViewToKeyboard: Bool {
    false
  }

  /// Should ignore safe area or not. Default is false.
  /// When true, scrollView will pin to topAnchor instead of safeArea.
  open var ignoredSafeArea: Bool {
    false
  }

  private var bottomInset: CGFloat {
    if stickBottomContentViewToKeyboard, #available(iOS 15.0, *) {
      let inset: CGFloat = bottomContentView.bounds.height + supplementaryView.bounds.height
      return inset
    }
    return .zero
  }

  // MARK: - Properties

  /// Background color of the whole screen
  public var backgroundColor: UIColor? = .systemBackground {
    didSet {
      scrollView.backgroundColor = backgroundColor
      contentView.backgroundColor = backgroundColor
      bottomContentView.backgroundColor = backgroundColor
      supplementaryView.backgroundColor = backgroundColor
      view.backgroundColor = backgroundColor
    }
  }

  public private(set) lazy var scrollView = PHScrollView().config {
    $0.backgroundColor = .systemBackground
    $0.alwaysBounceVertical = true
    $0.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    $0.keyboardDismissMode = .interactive
  }

  /// Our container view. Add subview to this instead of view.
  public private(set) lazy var contentView = UIView().config {
    $0.backgroundColor = backgroundColor
  }

  public private(set) lazy var bottomContentView = UIView().config {
    $0.backgroundColor = backgroundColor
  }

  private lazy var supplementaryView = UIView().config {
    $0.backgroundColor = backgroundColor
  }

  // MARK: - ViewController's lifecycle

  open override func loadView() {
    super.loadView()

    configureViews()
    if allowedKeyboardObservation {
      configureKeyboardObservers()
    }
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  // MARK: - Configure Views

  private func configureViews() {
    scrollView.layout {
      view.addSubview($0)
      $0.bottom()

      if #available(iOS 11.0, *) {
        $0.top(constraint: ignoredSafeArea ? view.topAnchor : view.safeAreaLayoutGuide.topAnchor)
          .leading(constraint: view.safeAreaLayoutGuide.leadingAnchor)
          .trailing(constraint: view.safeAreaLayoutGuide.trailingAnchor)
      } else {
        $0.top(constraint: ignoredSafeArea ? view.topAnchor : topLayoutGuide.bottomAnchor)
          .leading(constraint: view.leadingAnchor)
          .trailing(constraint: view.trailingAnchor)
      }
    }

    contentView.layout {
      scrollView.addSubview($0)
      $0.top(constraint: scrollView.contentLayoutGuide.topAnchor)
        .leading(constraint: scrollView.contentLayoutGuide.leadingAnchor)
        .trailing(constraint: scrollView.contentLayoutGuide.trailingAnchor)
        .bottom(constraint: scrollView.contentLayoutGuide.bottomAnchor)
        .width(dimension: scrollView.frameLayoutGuide.widthAnchor)
    }

    bottomContentView.layout {
      view.addSubview($0)
      $0.leading()
        .trailing()
      if stickBottomContentViewToKeyboard, #available(iOS 15.0, *) {
        $0.bottom(constraint: view.keyboardLayoutGuide.topAnchor)
        supplementaryView.layout {
          view.addSubview($0)
          $0.top(constraint: bottomContentView.bottomAnchor, -1)
            .leading()
            .trailing()
            .bottom()
        }
      } else {
        $0.bottom()
      }
    }

    scrollView.contentInset.bottom = bottomInset
    if #available(iOS 11.1, *) {
      scrollView.verticalScrollIndicatorInsets.bottom = bottomInset
    } else {
      scrollView.scrollIndicatorInsets.bottom = bottomInset
    }
  }

  // MARK: - Private

  private func configureKeyboardObservers() {
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
    keyboardFrame = scrollView.convert(aFrame, from: nil)
    let intersect: CGRect = keyboardFrame.intersection(scrollView.bounds)
    if !intersect.isNull {
      guard let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {return}
      guard let curveKey = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int else {return}
      let curve: Int = curveKey << 16
      let bottomContentViewHeight: CGFloat = bottomInset
      UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: UIView.AnimationOptions(rawValue: UIView.AnimationOptions.RawValue(curve)), animations: {
        self.scrollView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: intersect.size.height + bottomContentViewHeight, right: 0)
        self.scrollView.scrollIndicatorInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: intersect.size.height + bottomContentViewHeight, right: 0)
      }, completion: { [weak self] _ in
        self?.keyboardWillShowHandler?(intersect.size.height)
      })
    }
  }

  @objc
  private func keyboardWillHide(_ notification: Notification) {
    guard let userInfo = notification.userInfo else {return}
    guard let duraton = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else {return}
    guard let curve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int else {return}
    let bottomContentViewHeight: CGFloat = bottomInset
    UIView.animate(withDuration: duraton, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: UIView.AnimationOptions(rawValue: UIView.AnimationOptions.RawValue(curve)), animations: {
      self.scrollView.contentInset = .init(top: 0, left: 0, bottom: bottomContentViewHeight, right: 0)
      self.scrollView.scrollIndicatorInsets = .init(top: 0, left: 0, bottom: bottomContentViewHeight, right: 0)
    }, completion: { [weak self] _ in
      self?.keyboardWillHideHandler?()
    })
  }
}

public final class PHScrollView: UIScrollView {
  public override func touchesShouldCancel(in view: UIView) -> Bool {
    if type(of: view) == UITextField.self || type(of: view) == UITextView.self {
      return true
    }
    return super.touchesShouldCancel(in: view)
  }
}
#endif
