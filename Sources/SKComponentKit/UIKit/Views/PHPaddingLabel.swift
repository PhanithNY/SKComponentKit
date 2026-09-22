#if canImport(UIKit)
//
//  PHPaddingLabel.swift
//
//
//  Created by Phanith on 29/1/22.
//

import UIKit

public final class PHPaddingLabel: UILabel {

  public var topInset: CGFloat = 12.0 {
    didSet { invalidateIntrinsicContentSize(); setNeedsDisplay() }
  }
  public var bottomInset: CGFloat = 12.0 {
    didSet { invalidateIntrinsicContentSize(); setNeedsDisplay() }
  }
  public var leftInset: CGFloat = 12.0 {
    didSet { invalidateIntrinsicContentSize(); setNeedsDisplay() }
  }
  public var rightInset: CGFloat = 12.0 {
    didSet { invalidateIntrinsicContentSize(); setNeedsDisplay() }
  }

  public var insets: UIEdgeInsets = .init(top: 12.0, left: 12.0, bottom: 12.0, right: 12.0) {
    didSet {
      topInset = insets.top
      bottomInset = insets.bottom
      leftInset = insets.left
      rightInset = insets.right
    }
  }

  public override func drawText(in rect: CGRect) {
    let insets = UIEdgeInsets.init(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
    super.drawText(in: rect.inset(by: insets))
  }

  public override var intrinsicContentSize: CGSize {
    let size = super.intrinsicContentSize
    return CGSize(width: size.width + leftInset + rightInset,
                  height: size.height + topInset + bottomInset)
  }
}
#endif
