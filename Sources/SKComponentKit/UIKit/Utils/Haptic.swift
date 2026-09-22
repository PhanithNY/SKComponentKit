#if canImport(UIKit)
//
//  Haptic.swift
//
//
//  Created by Suykorng on 16/4/24.
//

import UIKit

public enum Haptic {
  case impact(HapticFeedbackStyle)
  case notification(HapticFeedbackType)
  case selection

  @MainActor
  public func generate() {
    switch self {
    case .impact(let style):
      let generator = UIImpactFeedbackGenerator(style: style.value)
      generator.prepare()
      generator.impactOccurred()

    case .notification(let type):
      let generator = UINotificationFeedbackGenerator()
      generator.prepare()
      generator.notificationOccurred(type.value)

    case .selection:
      let generator = UISelectionFeedbackGenerator()
      generator.prepare()
      generator.selectionChanged()
    }
  }
}

public enum HapticFeedbackStyle: Int {
  case light, medium, heavy

  @available(iOS 13.0, *)
  case soft, rigid
}

public extension HapticFeedbackStyle {
  var value: UIImpactFeedbackGenerator.FeedbackStyle {
    return UIImpactFeedbackGenerator.FeedbackStyle(rawValue: rawValue)!
  }
}

public enum HapticFeedbackType: Int {
  case success
  case warning
  case error
}

public extension HapticFeedbackType {
  var value: UINotificationFeedbackGenerator.FeedbackType {
    return UINotificationFeedbackGenerator.FeedbackType(rawValue: rawValue)!
  }
}
#endif
