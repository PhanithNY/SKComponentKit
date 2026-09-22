//
//  SKHaptic.swift
//  SKComponentKit
//
//  Created by Suykorng on 22/9/26.
//

#if canImport(UIKit)
import UIKit

public enum SKHaptic {
  case impact(SKHapticFeedbackStyle)
  case notification(SKHapticFeedbackType)
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

public enum SKHapticFeedbackStyle: Int {
  case light, medium, heavy

  @available(iOS 13.0, *)
  case soft, rigid
}

public extension SKHapticFeedbackStyle {
  var value: UIImpactFeedbackGenerator.FeedbackStyle {
    return UIImpactFeedbackGenerator.FeedbackStyle(rawValue: rawValue)!
  }
}

public enum SKHapticFeedbackType: Int {
  case success
  case warning
  case error
}

public extension SKHapticFeedbackType {
  var value: UINotificationFeedbackGenerator.FeedbackType {
    return UINotificationFeedbackGenerator.FeedbackType(rawValue: rawValue)!
  }
}
#endif
