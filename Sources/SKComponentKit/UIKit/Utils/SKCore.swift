//
//  SKCore.swift
//  SKComponentKit
//
//  Created by Suykorng on 22/9/26.
//

#if canImport(UIKit)
import UIKit

public enum SKCore {

  @MainActor
  public enum Label {
    public static var primary: UIColor {
      if #available(iOS 13.0, *) {
        return UIColor { trait in
          return trait.userInterfaceStyle == .light ? UIColor(hex: "041628") : .label
        }
      }
      return UIColor(hex: "041628")
    }

    public static var secondary: UIColor {
      if #available(iOS 13.0, *) {
        return UIColor { trait in
          return trait.userInterfaceStyle == .light ? UIColor(hex: "6E7C95") : UIColor.secondaryLabel
        }
      }
      return UIColor(hex: "6E7C95")
    }

    public static var tertiary: UIColor {
      if #available(iOS 13.0, *) {
        return UIColor { trait in
          return trait.userInterfaceStyle == .light ? UIColor(hex: "A7B2C4") : .tertiaryLabel
        }
      }
      return UIColor(hex: "A7B2C4")
    }

    public static var quarternary: UIColor {
      if #available(iOS 13.0, *) {
        return UIColor { trait in
          return trait.userInterfaceStyle == .light ? UIColor(hex: "D8DBE5") : .quaternaryLabel
        }
      }
      return UIColor(hex: "D8DBE5")
    }

    public static var lightGray: UIColor {
      if #available(iOS 13.0, *) {
        return UIColor { trait in
          return trait.userInterfaceStyle == .light ? UIColor(hex: "F2F3F7") : .separator
        }
      }
      return UIColor(hex: "F2F3F7")
    }

    public static var white: UIColor {
      UIColor(hex: "FFFFFF")
    }
  }

  @MainActor
  public enum Background {
    public static var background: UIColor {
      if #available(iOS 13.0, *) {
        return UIColor.systemBackground
      }
      return UIColor.white
    }

    public static var grayBackground: UIColor {
      if #available(iOS 13.0, *) {
        return UIColor { trait in
          return trait.userInterfaceStyle == .light ? UIColor(hex: "F5F6F8") : UIColor.systemGroupedBackground
        }
      }
      return UIColor(hex: "F5F6F8")
    }
  }

  @MainActor
  public enum Color {
    public static var red: UIColor {
      if #available(iOS 13.0, *) {
        return UIColor.systemRed
      }
      return UIColor(hex: "E73E3E")
    }

    public static var green: UIColor {
      UIColor(hex: "54B948")
    }

    public static var purple: UIColor {
      UIColor(hex: "6E44FF")
    }

    public static var darkYellow: UIColor {
      UIColor(hex: "CE9F1C")
    }

    public static var separator: UIColor {
      if #available(iOS 13.0, *) {
        return UIColor { trait in
          return trait.userInterfaceStyle == .light ? UIColor(hex: "E5E7EB") : UIColor.systemFill
        }
      }
      return UIColor(hex: "E5E7EB")
    }

    public static var thinBorderColor: UIColor {
      if #available(iOS 13.0, *) {
        return UIColor { trait in
          return UIColor.separator
        }
      }
      return UIColor(hex: "F2F3F7")
    }

    public static var tintColor: UIColor = UIColor(hex: "0077FF")
  }

  @MainActor
  public enum KeyValue {
    public static var key: UIColor {
      return UIColor(hex: "626F86")
    }

    public static var value: UIColor {
      return UIColor(hex: "041628")
    }
  }
}
#endif
