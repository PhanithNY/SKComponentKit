//
//  SKQRCodeScannerController.swift
//  SKComponentKit
//
//  Created by Suykorng on 22/9/26.
//

#if canImport(UIKit)
import AVFoundation
import UIKit
import EasyAnchor

@available(macCatalyst 14.0, *)
open class SKQRCodeScannerController: UIViewController {

  /// SKCallback after reading QR/Barcode.
  public var onResult: ((String) -> Swift.Void)?

  public enum DismissalMode {
    case dismiss
    case pop
  }

  // MARK: - Properties

  /// Control whether callback can be execute or not. Default is true.
  open var canProcessResult: Bool {
    true
  }

  /// Dismiss or pop. Override as needed. Default is pop.
  open var dismissalMode: DismissalMode {
    .pop
  }

  /// Color of transparent background outside of rect view. Default is black with alpha 0.5.
  open var fillLayerFillColor: CGColor {
    UIColor.black.withAlphaComponent(0.5).cgColor
  }

  /// Frame that allow to recognize data. Default is allow to recognize data inside of rect view.
  /// QR/Barcode that lie outside of rectView will never be recognized.
  open var rectOfInterest: CGRect {
    rectView.frame
  }

  /// X-Axis inset of rect view.
  open var rectViewHorizontalPadding: CGFloat {
    50.0
  }

  /// Title when error happen.
  open var errorTitle: String {
    "Scanning not supported"
  }

  /// Message when error happen.
  open var errorMessage: String {
    "It seems like your device does not support scanning. Please make sure your device's camera is working."
  }

  /// Title for button when error happen.
  open var errorButton: String {
    "OK"
  }

  /// Color of rect corner (scan rect)
  open var scanFrameCornerColor: UIColor {
    .blue
  }

  /// Scan rect
  public lazy var rectView: SKQRCornerRectangleView = {
    let view = SKQRCornerRectangleView()
    view.backgroundColor = .clear
    view.color = scanFrameCornerColor
    view.thickness = 5.0
    view.radius = 10.0
    view.length = 15
    return view
  }()

  private var sessionRunner: CaptureSessionRunner?
  private var captureSession: AVCaptureSession!
  private var previewLayer: AVCaptureVideoPreviewLayer!
  private let fillLayer = CAShapeLayer()
  private lazy var metadataOutput = AVCaptureMetadataOutput()

  // MARK: - Init / Deinit

  public init() {
    super.init(nibName: nil, bundle: nil)
  }

  required public init?(coder: NSCoder) {
    fatalError()
  }

  // MARK: - Lifecycle

  open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    .portrait
  }

  open override func loadView() {
    super.loadView()

    prepareLayouts()
  }

  open override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    if let previewLayer = previewLayer {
      previewLayer.frame = view.bounds
      metadataOutput.rectOfInterest = previewLayer.metadataOutputRectConverted(fromLayerRect: rectOfInterest)
    }

    do {
      let bigRect = view.bounds
      let smallRect = rectView.frame
      let pathBigRect = UIBezierPath(rect: bigRect)
      let pathSmallRect = UIBezierPath(roundedRect: smallRect,
                                       byRoundingCorners: .allCorners,
                                       cornerRadii: CGSize(width: 12, height: 12))
      pathBigRect.append(pathSmallRect)
      pathBigRect.usesEvenOddFillRule = true

      fillLayer.path = pathBigRect.cgPath
      fillLayer.fillRule = .evenOdd
      fillLayer.fillColor = fillLayerFillColor
      if fillLayer.superlayer == nil {
        view.layer.insertSublayer(fillLayer, below: rectView.layer)
      }
    }
  }

  open override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
#if !targetEnvironment(simulator)
    switch AVCaptureDevice.authorizationStatus(for: .video) {
    case .authorized:
      configureAndStartSession()
    case .notDetermined:
      AVCaptureDevice.requestAccess(for: .video) { [weak self] allowed in
        Task { @MainActor [weak self] in
          guard let self, viewIfLoaded?.window != nil else { return }
          if allowed { configureAndStartSession() } else { failed() }
        }
      }
    default:
      failed()
    }
#endif
  }

  open override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)

    stopSession()
  }

  // MARK: - Actions

  /// Start scanning process.
  public final func startSession() {
    sessionRunner?.start()
  }

  /// Stop scanning process. Session work is serialized off the main thread.
  public final func stopSession() {
    sessionRunner?.stop()
  }

}

// MARK: - AVCaptureMetadataOutputObjectsDelegate

@available(macCatalyst 14.0, *)
extension SKQRCodeScannerController: @preconcurrency AVCaptureMetadataOutputObjectsDelegate {
  public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
    if !canProcessResult {
      return
    }

    guard let metadataObject = metadataObjects.first,
          let readable = metadataObject as? AVMetadataMachineReadableCodeObject,
          readable.stringValue != nil else { return }
    stopSession()

    if let metadataObject = metadataObjects.first,
       let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
       let stringValue = readableObject.stringValue {
      dismissSelf { [weak self] in
        self?.onResult?(stringValue)
      }
    } else {
      dismissSelf()
    }
  }

  private func dismissSelf(completion: (() -> Void)? = nil) {
    if completion != nil {
      let generator = UINotificationFeedbackGenerator()
      generator.prepare()
      generator.notificationOccurred(.success)
    }

    switch dismissalMode {
    case .dismiss:
      dismiss(animated: true, completion: completion)

    case .pop:
      CATransaction.begin()
      CATransaction.setCompletionBlock {
        completion?()
      }
      navigationController?.popViewController(animated: true)
      CATransaction.commit()
    }

  }
}

// MARK: - Layouts
@available(macCatalyst 14.0, *)

extension SKQRCodeScannerController {
  private func prepareLayouts() {
    view.backgroundColor = .black
    rectView.layout {
      view.addSubview($0)
      $0.leading(rectViewHorizontalPadding)
        .trailing(rectViewHorizontalPadding)
        .height(dimension: $0.widthAnchor)
        .centerY()
    }
  }

  private func configureAndStartSession() {
    if sessionRunner != nil {
      startSession()
      return
    }
    captureSession = AVCaptureSession()
    guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
      failed()
      return
    }

    let videoInput: AVCaptureDeviceInput

    do {
      videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
    } catch {
      failed()
      return
    }

    if (captureSession.canAddInput(videoInput)) {
      captureSession.addInput(videoInput)
    } else {
      failed()
      return
    }

    if (captureSession.canAddOutput(metadataOutput)) {
      captureSession.addOutput(metadataOutput)

      metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
      metadataOutput.metadataObjectTypes = [.qr, .code128, .code39, .code39Mod43, .code93, .ean13, .ean8, .interleaved2of5, .itf14, .pdf417, .upce]
    } else {
      failed()
      return
    }

    sessionRunner = CaptureSessionRunner(session: captureSession)
    previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
    previewLayer.frame = view.layer.bounds
    previewLayer.videoGravity = .resizeAspectFill
    view.layer.insertSublayer(previewLayer, at: 0)

    view.setNeedsLayout()
    view.layoutIfNeeded()
    startSession()
  }

  private func failed() {
    let ac = UIAlertController(title: errorTitle,
                               message: errorMessage,
                               preferredStyle: .alert)
    ac.addAction(UIAlertAction(title: errorButton, style: .default))
    present(ac, animated: true)
    captureSession = nil

    let generator = UINotificationFeedbackGenerator()
    generator.prepare()
    generator.notificationOccurred(.error)
  }
}

public final class SKQRCornerRectangleView: UIView {
  public var color = UIColor.black {
    didSet {
      setNeedsDisplay()
    }
  }

  public var radius: CGFloat = 5 {
    didSet {
      setNeedsDisplay()
    }
  }

  public var thickness: CGFloat = 2 {
    didSet {
      setNeedsDisplay()
    }
  }

  public var length: CGFloat = 30 {
    didSet {
      setNeedsDisplay()
    }
  }

  public override func draw(_ rect: CGRect) {
    color.set()

    let t2 = thickness / 2
    let path = UIBezierPath()
    // Top left
    path.move(to: CGPoint(x: t2, y: length + radius + t2))
    path.addLine(to: CGPoint(x: t2, y: radius + t2))
    path.addArc(withCenter: CGPoint(x: radius + t2, y: radius + t2), radius: radius, startAngle: CGFloat.pi, endAngle: CGFloat.pi * 3 / 2, clockwise: true)
    path.addLine(to: CGPoint(x: length + radius + t2, y: t2))

    // Top right
    path.move(to: CGPoint(x: frame.width - t2, y: length + radius + t2))
    path.addLine(to: CGPoint(x: frame.width - t2, y: radius + t2))
    path.addArc(withCenter: CGPoint(x: frame.width - radius - t2, y: radius + t2), radius: radius, startAngle: 0, endAngle: CGFloat.pi * 3 / 2, clockwise: false)
    path.addLine(to: CGPoint(x: frame.width - length - radius - t2, y: t2))

    // Bottom left
    path.move(to: CGPoint(x: t2, y: frame.height - length - radius - t2))
    path.addLine(to: CGPoint(x: t2, y: frame.height - radius - t2))
    path.addArc(withCenter: CGPoint(x: radius + t2, y: frame.height - radius - t2), radius: radius, startAngle: CGFloat.pi, endAngle: CGFloat.pi / 2, clockwise: false)
    path.addLine(to: CGPoint(x: length + radius + t2, y: frame.height - t2))

    // Bottom right
    path.move(to: CGPoint(x: frame.width - t2, y: frame.height - length - radius - t2))
    path.addLine(to: CGPoint(x: frame.width - t2, y: frame.height - radius - t2))
    path.addArc(withCenter: CGPoint(x: frame.width - radius - t2, y: frame.height - radius - t2), radius: radius, startAngle: 0, endAngle: CGFloat.pi / 2, clockwise: true)
    path.addLine(to: CGPoint(x: frame.width - length - radius - t2, y: frame.height - t2))

    path.lineWidth = thickness
    path.stroke()
  }
}

// Configuration finishes before this runner is created. Only its serial queue
// subsequently starts/stops the session; no mutable state is exposed to callers.
private final class CaptureSessionRunner: @unchecked Sendable {
  private let session: AVCaptureSession
  private let queue = DispatchQueue(label: "SKComponentKit.camera", qos: .userInitiated)

  init(session: AVCaptureSession) { self.session = session }
  func start() {
    queue.async { [self] in
      if !session.isRunning { session.startRunning() }
    }
  }
  func stop() {
    queue.async { [self] in
      if session.isRunning { session.stopRunning() }
    }
  }
}
#endif
