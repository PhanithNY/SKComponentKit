//
//  SKFont.swift
//  SKComponentKit
//
//  Created by Suykorng on 22/9/26.
//

#if canImport(UIKit)
import UIKit

@MainActor
public final class SKFont {

  private init() {}

  public class func largeTitle(_ weight: UIFont.Weight = .regular) -> UIFont {
    UIFont.largeTitle(weight)
  }

  public class func title1(_ weight: UIFont.Weight = .regular) -> UIFont {
    UIFont.title1(weight)
  }

  public class func title2(_ weight: UIFont.Weight = .regular) -> UIFont {
    UIFont.title2(weight)
  }

  public class func title3(_ weight: UIFont.Weight = .regular) -> UIFont {
    UIFont.title3(weight)
  }

  public class func body(_ weight: UIFont.Weight = .regular) -> UIFont {
    UIFont.body(weight)
  }

  public class func callout(_ weight: UIFont.Weight = .regular) -> UIFont {
    UIFont.callout(weight)
  }

  public class func subheadline(_ weight: UIFont.Weight = .regular) -> UIFont {
    UIFont.subheadline(weight)
  }

  public class func footnote(_ weight: UIFont.Weight = .regular) -> UIFont {
    UIFont.footnote(weight)
  }

  public class func caption1(_ weight: UIFont.Weight = .regular) -> UIFont {
    UIFont.caption1(weight)
  }

  public class func caption2(_ weight: UIFont.Weight = .regular) -> UIFont {
    UIFont.caption2(weight)
  }

  public class func size(_ size: CGFloat, weight: UIFont.Weight = .regular) -> UIFont {
    UIFont.systemFont(ofSize: size, weight: weight)
  }
}

@MainActor
extension UIFont {

  public static func largeTitle(_ weight: Weight = .regular) -> UIFont {
    UIFont.preferredFont(forTextStyle: .largeTitle, weight: weight)
  }

  @available(iOS 17.0, *)
  public static func extraLargeTitle(_ weight: Weight = .regular) -> UIFont {
    UIFont.preferredFont(forTextStyle: .extraLargeTitle, weight: weight)
  }

  @available(iOS 17.0, *)
  public static func extraLargeTitle2(_ weight: Weight = .regular) -> UIFont {
    UIFont.preferredFont(forTextStyle: .extraLargeTitle2, weight: weight)
  }

  public static func title1(_ weight: Weight = .regular) -> UIFont {
    UIFont.preferredFont(forTextStyle: .title1, weight: weight)
  }

  public static func title2(_ weight: Weight = .regular) -> UIFont {
    UIFont.preferredFont(forTextStyle: .title2, weight: weight)
  }

  public static func title3(_ weight: Weight = .regular) -> UIFont {
    UIFont.preferredFont(forTextStyle: .title3, weight: weight)
  }

  public static func headline(_ weight: Weight = .regular) -> UIFont {
    UIFont.preferredFont(forTextStyle: .headline, weight: weight)
  }

  public static func subheadline(_ weight: Weight = .regular) -> UIFont {
    UIFont.preferredFont(forTextStyle: .subheadline, weight: weight)
  }

  public static func body(_ weight: Weight = .regular) -> UIFont {
    UIFont.preferredFont(forTextStyle: .body, weight: weight)
  }

  public static func callout(_ weight: Weight = .regular) -> UIFont {
    UIFont.preferredFont(forTextStyle: .callout, weight: weight)
  }

  public static func footnote(_ weight: Weight = .regular) -> UIFont {
    UIFont.preferredFont(forTextStyle: .footnote, weight: weight)
  }

  public static func caption1(_ weight: Weight = .regular) -> UIFont {
    UIFont.preferredFont(forTextStyle: .caption1, weight: weight)
  }

  public static func caption2(_ weight: Weight = .regular) -> UIFont {
    UIFont.preferredFont(forTextStyle: .caption2, weight: weight)
  }

}

@MainActor
extension UIFont {
  public static func preferredFont(forTextStyle style: TextStyle, weight: Weight) -> UIFont {
    let metrics = UIFontMetrics(forTextStyle: style)
    let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: style)
    let font = UIFont.systemFont(ofSize: descriptor.pointSize, weight: weight)
    return metrics.scaledFont(for: font)
  }
}

@MainActor
extension UIFont {
  public var bold: UIFont {
    return with(traits: .traitBold)
  }

  public var italic: UIFont {
    return with(traits: .traitItalic)
  }

  public var boldItalic: UIFont {
    return with(traits: [.traitBold, .traitItalic])
  }

  public var rounded: UIFont {
    if let descriptor = fontDescriptor.withDesign(.rounded) {
      return UIFont(descriptor: descriptor, size: pointSize)
    }
    return self
  }

  public func with(traits: UIFontDescriptor.SymbolicTraits) -> UIFont {
    guard let descriptor = self.fontDescriptor.withSymbolicTraits(traits) else {
      return self
    }
    return UIFont(descriptor: descriptor, size: 0)
  }
}
#endif
