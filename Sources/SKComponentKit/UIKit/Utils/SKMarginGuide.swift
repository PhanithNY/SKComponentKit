//
//  SKMarginGuide.swift
//  SKComponentKit
//
//  Created by Suykorng on 22/9/26.
//

#if canImport(UIKit)
import UIKit

@MainActor
public enum SKMarginGuide {
  public static var horizontalPadding: CGFloat {
    switch _Config.shared.sizeClass {
    case .large,
        .extraLarge:
      return 24

    default:
      return 16
    }
  }
}

@MainActor
public enum SKDevice {
  public static var hasNotch: Bool {
    if UIDevice.current.userInterfaceIdiom == .phone {
      return UIScreen.main.bounds.height >= 812
    }
    return false
  }
}

enum SizeClass {
  /// Represent small device (iPhone 5, 5s, SE first gen)
  case compact

  /// Represent standard device including iPhone SE 2nd gen, 6s, 7, 8, X, Xs, 11 Pro, 12 Pro, 13 Pro, 12 mini, 13, 13 mini
  case regular

  /// Represent plus device like iPhone 6 plus, 7 plus, 8 plus, XR, 11, 12
  case large

  /// Represent extra large device including iPhone XS Max, 11 Pro Max, 12 Pro Max, 13 Pro Max
  case extraLarge
}

@MainActor
final class _Config {

  static let shared = _Config()

  var sizeClass: SizeClass {
    switch min(UIScreen.main.bounds.width, UIScreen.main.bounds.height) {
    case let width where width <= 320:
      return .compact

    case let width where width >= 375 && width < 414:
      return .regular

    case let width where width >= 414 && width < 420:
      return .large

    default:
      return .extraLarge
    }
  }

  private init() {}
}
#endif
