//
//  SKRefreshingView.swift
//  SKComponentKit
//
//  Created by Suykorng on 22/9/26.
//

#if canImport(UIKit)
import UIKit

public final class SKRefreshingView: UIView {

  // MARK: - Properties

  public override var tintColor: UIColor! {
    didSet {
      if isAnimating { setUpAnimation() }
    }
  }

  public private(set) var isAnimating: Bool = false

  // MARK: - Actions

  public final func startAnimating() {
    if isAnimating {
      return
    }

    isHidden = false
    isAnimating = true
    layer.speed = 1
    setUpAnimation()
  }

  public final func stopAnimating() {
    if isAnimating {
      isHidden = true
      isAnimating = false
      layer.sublayers?.removeAll()
    }
  }

  private func setUpAnimation() {
    setUpAnimation(in: layer, size: CGSize(width: 32, height: 32), color: tintColor ?? SKCore.Color.tintColor)
  }

  private func setUpAnimation(in layer: CALayer, size: CGSize, color: UIColor) {
    layer.sublayers?.forEach { $0.removeFromSuperlayer() }
    let beginTime: Double = 0.5
    let strokeStartDuration: Double = 1.2
    let strokeEndDuration: Double = 0.7

    let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
    rotationAnimation.byValue = Float.pi * 2
    rotationAnimation.timingFunction = CAMediaTimingFunction(name: .linear)

    let strokeEndAnimation = CABasicAnimation(keyPath: "strokeEnd")
    strokeEndAnimation.duration = strokeEndDuration
    strokeEndAnimation.timingFunction = CAMediaTimingFunction(controlPoints: 0.4, 0.0, 0.2, 1.0)
    strokeEndAnimation.fromValue = 0
    strokeEndAnimation.toValue = 1

    let strokeStartAnimation = CABasicAnimation(keyPath: "strokeStart")
    strokeStartAnimation.duration = strokeStartDuration
    strokeStartAnimation.timingFunction = CAMediaTimingFunction(controlPoints: 0.4, 0.0, 0.2, 1.0)
    strokeStartAnimation.fromValue = 0
    strokeStartAnimation.toValue = 1
    strokeStartAnimation.beginTime = beginTime

    let groupAnimation = CAAnimationGroup()
    groupAnimation.animations = [rotationAnimation, strokeEndAnimation, strokeStartAnimation]
    groupAnimation.duration = strokeStartDuration + beginTime
    groupAnimation.repeatCount = .infinity
    groupAnimation.isRemovedOnCompletion = false
    groupAnimation.fillMode = .forwards

    let _circle = layerWith(size: size, color: color)
    _circle.strokeColor = UIColor.lightGray.withAlphaComponent(1.0).cgColor
    let frame = CGRect(x: 0, y: 0, width: size.width, height: size.height).integral
    _circle.frame = frame
    layer.addSublayer(_circle)

    let circle = layerWith(size: size, color: color)
    circle.frame = frame
    circle.add(groupAnimation, forKey: "animation")
    layer.addSublayer(circle)
  }

  private func layerWith(size: CGSize, color: UIColor) -> CAShapeLayer {
    let layer: CAShapeLayer = CAShapeLayer()
    let path: UIBezierPath = UIBezierPath()
    let lineWidth: CGFloat = 4

    path.addArc(withCenter: CGPoint(x: size.width / 2, y: size.height / 2),
                radius: size.width / 2,
                startAngle: -(.pi / 2),
                endAngle: .pi + .pi / 2,
                clockwise: true)
    layer.fillColor = nil
    layer.strokeColor = color.cgColor
    layer.lineWidth = lineWidth
    layer.lineCap = .round

    layer.backgroundColor = nil
    layer.path = path.cgPath
    layer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
    return layer
  }
}
#endif
