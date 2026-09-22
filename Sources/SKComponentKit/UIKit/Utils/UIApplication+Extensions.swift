#if canImport(UIKit)
//
//  UIApplication+Extensions.swift
//
//
//  Created by Suykorng on 15/7/24.
//

import UIKit

extension UIApplication {
  var currentWindow: UIWindow? {
    if #available(iOS 13.0, *) {
      return connectedScenes
        .filter({$0.activationState == .foregroundActive})
        .map({$0 as? UIWindowScene})
        .compactMap({$0})
        .first?.windows
        .filter({$0.isKeyWindow}).first
    } else {
      return keyWindow
    }
  }
}

@MainActor
func topViewController(_ viewController: UIViewController? = UIApplication.shared.currentWindow?.rootViewController) -> UIViewController? {
  if let nav = viewController as? UINavigationController {
    return topViewController(nav.visibleViewController)
  }
  if let tab = viewController as? UITabBarController {
    if let selected = tab.selectedViewController {
      return topViewController(selected)
    }
  }
  if let presented = viewController?.presentedViewController {
    return topViewController(presented)
  }

  return viewController
}
#endif
