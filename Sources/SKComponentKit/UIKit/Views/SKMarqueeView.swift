//
//  SKMarqueeView.swift
//  SKComponentKit
//
//  Created by Suykorng on 22/9/26.
//

#if canImport(UIKit)
import UIKit

public final class SKMarqueeView: UIView {

  public var contentViewFrameConfigWhenCantMarquee: ((UIView)->())?

  /// Begin scrolling behavior automatically. Default is false.
  public var autoScroll: Bool = false

  /// The margin between marquee view
  public var contentMargin: CGFloat = 8

  /// Framerate for the animation. The default value is 0. When this value is 0, the preferred frame rate is equal to the maximum refresh rate of the display.
  public var preferredFramesPerSecond: Int = 0

  /// The animation speed for marquee view
  public var speed: CGFloat = 1.0

  /// The marquee view
  public var contentView: UIView? {
    didSet {
      self.setNeedsLayout()
    }
  }

  private lazy var containerView = UIView()

  private var displayLink: CADisplayLink?
  private lazy var displayLinkTarget = MarqueeDisplayLinkTarget(owner: self)

  // MARK: - Init

  public init() {
    super.init(frame: .zero)

    initializeViews()
  }

  override public init(frame: CGRect) {
    super.init(frame: frame)

    initializeViews()
  }

  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)

    initializeViews()
  }

  override public func didMoveToWindow() {
    super.didMoveToWindow()
    if window == nil {
      stopMarquee()
    } else {
      setNeedsLayout()
    }
  }

  override public func layoutSubviews() {
    super.layoutSubviews()

    layoutViews()
  }

  // MARK: - Actions

  public func reloadData() {
    self.setNeedsLayout()
  }

  public func startMarquee() {
    stopMarquee()
    guard contentView != nil else { return }

    displayLink = CADisplayLink(target: displayLinkTarget, selector: #selector(MarqueeDisplayLinkTarget.tick(_:)))
    displayLink?.preferredFramesPerSecond = max(0, preferredFramesPerSecond)
    displayLink?.add(to: RunLoop.main, forMode: RunLoop.Mode.common)
  }

  public func stopMarquee() {
    displayLink?.invalidate()
    displayLink = nil
  }

  @objc
  fileprivate func processMarquee() {
    var frame = self.containerView.frame

    guard let contentView else {
      stopMarquee()
      return
    }
    let targetX = -(contentView.bounds.width + contentMargin)
    if frame.origin.x <= targetX {
      frame.origin.x = 0
      self.containerView.frame = frame
    }else {
      frame.origin.x -= speed
      if frame.origin.x < targetX {
        frame.origin.x = targetX
      }
      self.containerView.frame = frame
    }
  }

  // MARK: - Layouts

  private func initializeViews() {
    self.backgroundColor = UIColor.clear
    self.clipsToBounds = true

    containerView.backgroundColor = UIColor.clear
    self.addSubview(containerView)
  }

  private func layoutViews() {
    stopMarquee()
    guard let validContentView = contentView else {
      return
    }

    containerView.subviews.forEach {
      $0.removeFromSuperview()
    }

    validContentView.sizeToFit()
    containerView.addSubview(validContentView)

    containerView.frame = CGRect(
      x: 0,
      y: 0,
      width: validContentView.bounds.size.width*2 + contentMargin,
      height: self.bounds.size.height
    )

    if validContentView.bounds.size.width > self.bounds.size.width {
      validContentView.frame = CGRect(
        x: 0,
        y: 0,
        width: validContentView.bounds.size.width,
        height: self.bounds.size.height
      )

      let otherContentView = validContentView.copyMarqueeView()
      otherContentView.frame = CGRect(
        x: validContentView.bounds.size.width + contentMargin,
        y: 0,
        width: validContentView.bounds.size.width,
        height: self.bounds.size.height
      )
      containerView.addSubview(otherContentView)

      if self.bounds.size.width != 0, autoScroll {
        self.startMarquee()
      }
    } else {
      if contentViewFrameConfigWhenCantMarquee != nil {
        contentViewFrameConfigWhenCantMarquee?(validContentView)
      } else {
        validContentView.frame = CGRect(
          x: 0,
          y: 0,
          width: validContentView.bounds.size.width,
          height: self.bounds.size.height
        )
      }
    }
  }
}

@MainActor
fileprivate protocol MarqueeViewCopyable {
  func copyMarqueeView() -> UIView
}

extension UIView: MarqueeViewCopyable {
  @objc
  open func copyMarqueeView() -> UIView {
    if let copiedView = try? self.copyObject() {
      return copiedView
    } else {
      return snapshotView(afterScreenUpdates: true) ?? UIView(frame: bounds)
    }
  }
}

extension UIView {
  func copyObject<T: UIView>() throws -> T? {
    let data = try NSKeyedArchiver.archivedData(withRootObject:self, requiringSecureCoding:false)
    let unarchiver = try NSKeyedUnarchiver(forReadingFrom: data)
    unarchiver.requiresSecureCoding = false
    defer { unarchiver.finishDecoding() }
    return unarchiver.decodeObject(forKey: NSKeyedArchiveRootObjectKey) as? T
  }
}
@MainActor
private final class MarqueeDisplayLinkTarget {
  weak var owner: SKMarqueeView?
  init(owner: SKMarqueeView) { self.owner = owner }
  @objc func tick(_ link: CADisplayLink) {
    guard let owner else {
      link.invalidate()
      return
    }
    owner.processMarquee()
  }
}
#endif
