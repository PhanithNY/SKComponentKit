#if canImport(UIKit)
//
//  LoadingViewController.swift
//
//
//  Created by Suykorng on 15/7/24.
//

import UIKit
import EasyAnchor

public final class LoadingViewController: UIViewController {

  public static func show(transparent: CGFloat = 0.4,
                          tintColor: UIColor? = .white,
                          animated: Bool = true,
                          completion: (() -> Void)? = nil) {
    MainThread.run {
      if let viewController = topViewController(),
         type(of: viewController) != LoadingViewController.self {
        let loadingViewController: LoadingViewController = .init(transparent: transparent, tintColor: tintColor)
        viewController.present(loadingViewController, animated: animated, completion: completion)
      }
    }
  }

  public static func hide(animated: Bool = false, completion: (() -> Void)? = nil) {
    MainThread.run {
      if let loadingViewController = topViewController() as? LoadingViewController {
        loadingViewController.dismiss(animated: animated, completion: completion)
      }
    }
  }

  // MARK: - Properties

  private lazy var indicatorView = UIActivityIndicatorView().config {
    if #available(iOS 13.0, *) {
      $0.style = .medium
    } else {
      $0.style = .white
    }
    $0.color = tintColor
    $0.startAnimating()
  }

  // MARK: - Init / Deinit

  private let tintColor: UIColor?
  private let transparent: CGFloat

  public init(transparent: CGFloat = 0.4, tintColor: UIColor? = .white) {
    self.tintColor = tintColor
    self.transparent = transparent
    super.init(nibName: nil, bundle: nil)

    modalPresentationStyle = .overFullScreen
    modalTransitionStyle = .crossDissolve
  }

  required init?(coder: NSCoder) {
    fatalError()
  }

  // MARK: - ViewController's lifecycle

  public override func loadView() {
    super.loadView()

    view.backgroundColor = UIColor.black.withAlphaComponent(transparent)
    indicatorView.layout {
      view.addSubview($0)
      $0.center()
    }
  }
}
#endif
