#if canImport(UIKit)
//
//  PHZigzagView.swift
//  WingLandingPage
//
//  Created by Suykorng on 1/5/23.
//

import UIKit

public final class PHZigzagView: UIView {

  // MARK: - Init / Deinit

  private let numberOfZigZagLines: Int
  private let borderLayer = CAShapeLayer()

  public init(numberOfZigZagLines: Int) {
    self.numberOfZigZagLines = max(1, numberOfZigZagLines)
    super.init(frame: .zero)
    backgroundColor = .clear
    isOpaque = false
    contentMode = .redraw
    layer.insertSublayer(borderLayer, at: 0)

  }

  required init?(coder: NSCoder) {
    fatalError()
  }

  public override func draw(_ rect: CGRect) {
    guard rect.width > 0, rect.height > 0 else { return }
    let width: CGFloat = rect.width
    let height: CGFloat = rect.height
    let zigZagWidth: CGFloat = rect.width / CGFloat(numberOfZigZagLines) // Number of zigzag line compared to width, 24
    let zigZagHeight: CGFloat = 5
    let cornerRadius: CGFloat = 16
    let yInitial: CGFloat = height - zigZagHeight

    let zigZagPath = UIBezierPath()

    // Move to curve starting point
    zigZagPath.move(to: CGPoint(x: cornerRadius, y: 0))

    // Curve top-left
    zigZagPath.addArc(withCenter: CGPoint(x: cornerRadius, y: cornerRadius), radius: cornerRadius, startAngle: -CGFloat.pi/2, endAngle: .pi, clockwise: false)

    var slope: CGFloat = -1
    var x: CGFloat = 0
    var i: Int = 0

    while x < width {
      x = zigZagWidth * CGFloat(i)

      let p = zigZagHeight * slope

      let point = CGPoint(x: x, y: yInitial + p)
      //      zigZagPath.addLine(to: point)

      let controlPointY1: CGFloat = slope > 0 ? point.y + 2 : point.y
      let controlPointY2: CGFloat = point.y
      zigZagPath.addCurve(to: point, controlPoint1: CGPoint(x: point.x, y: controlPointY1), controlPoint2: CGPoint(x: point.x, y: controlPointY2))

      slope = slope * (-1)

      i += 1
    }

    // Move to curve starting point
    zigZagPath.addLine(to: CGPoint(x: width, y: cornerRadius))

    // Curve top-right
    zigZagPath.addArc(withCenter: CGPoint(x: rect.width - cornerRadius, y: cornerRadius), radius: cornerRadius, startAngle: 0, endAngle: CGFloat.pi * 3/2, clockwise: false)

    // Join
    zigZagPath.close()

    let borderWidth: CGFloat = UIScreen.main.scale >= 3 ? 0.66 : 1.0
    let borderColor: UIColor = Core.Color.separator
    borderLayer.path = zigZagPath.cgPath
    borderLayer.lineWidth = borderWidth
    borderLayer.strokeColor = borderColor.resolvedColor(with: traitCollection).cgColor
    borderLayer.fillColor = UIColor.secondarySystemBackground.resolvedColor(with: traitCollection).cgColor
    borderLayer.frame = rect
  }
}
#endif
