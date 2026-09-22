//
//  ImportedComponentDemos.swift
//  SKComponentKit
//
//  Created by Suykorng on 22/9/26.
//

import EasyAnchor
import SKComponentKit
import UIKit

@MainActor
enum ImportedComponentDemos {
    static let all: [ComponentDemo] = [
        demo("Buttons", "SKButton styles, icons, disabled and loading states.", "rectangle.and.hand.point.up.left", buttons),
        demo("Text Fields", "SKTextField padding, prefixes, limits, and input types.", "text.cursor", textFields),
        demo("Padding Label", "SKPaddingLabel with multiline text and content insets.", "text.alignleft", paddingLabel),
        demo("Marquee", "SKMarqueeView scrolling with start and stop controls.", "arrow.left.and.right", marquee),
        demo("Refresh Indicator", "SKRefreshingView animation and tint changes.", "arrow.clockwise", refreshing),
        demo("Zigzag", "SKZigzagView receipt-style shape.", "receipt", zigzag),
        demo("Scroll Container", "SKScrollViewController with keyboard-aware content.", "scroll", { ScrollComponentDemo() }),
        demo("Dialogue", "SKDialogueViewController presentation and dismissal.", "rectangle.on.rectangle", dialogue),
        demo("Loading Overlay", "SKLoadingViewController presentation and dismissal.", "hourglass", loading),
        demo("QR Scanner", "SKQRCodeScannerController; scanning requires a device.", "qrcode.viewfinder", scanner),
        demo("Blur Effect", "SKCustomIntensityVisualEffectView at three intensities.", "drop.halffull", blur),
        demo("QR Frame", "SKQRCornerRectangleView color and corner styling.", "viewfinder", qrFrame),
    ]

    private static func demo(
        _ title: String, _ summary: String, _ symbol: String,
        _ factory: @escaping @MainActor () -> UIViewController
    ) -> ComponentDemo {
        ComponentDemo(title: title, summary: summary, symbolName: symbol, makeViewController: factory)
    }

    private static func buttons() -> UIViewController {
        let screen = ComponentStackViewController()
        let status = screen.addText("Tap a button to test its callback.")
        status.accessibilityIdentifier = "componentButtonStatus"
        let styles: [(String, SKButton)] = [
            ("Primary", .primary(borderStyle: .none)),
            ("Outline", .primary(borderStyle: .border)),
            ("Normal", .default(borderStyle: .border)),
            ("Destructive", .destructive(borderStyle: .none)),
        ]
        for (title, button) in styles {
            button.setTitle(title)
            button.onTouchUpInside = { [weak status] in status?.text = "\(title) tapped" }
            screen.stack.addArrangedSubview(button)
        }
        let disabled = SKButton.primary(borderStyle: .none)
        disabled.setTitle("Disabled")
        disabled.isEnabled = false
        screen.stack.addArrangedSubview(disabled)
        let loading = SKButton.primary(borderStyle: .none)
        loading.setTitle("Loading")
        loading.showsActivityIndicator = true
        screen.stack.addArrangedSubview(loading)
        let icon = SKButton.primary(borderStyle: .none)
        icon.setTitle("With Icon")
        icon.setLeadingImage(UIImage(systemName: "star.fill"), tintColor: .white)
        screen.stack.addArrangedSubview(icon)
        return screen
    }

    private static func textFields() -> UIViewController {
        let screen = ComponentStackViewController()
        screen.addText("Try editing each field. Tap Done to dismiss the keyboard.")
        let configurations: [(String, SKTextField.InputType, String?)] = [
            ("Name (20 characters)", .default, nil),
            ("Amount", .currency, "$"),
            ("Account number", .bankAccountNumber, nil),
            ("Email address", .email, nil),
        ]
        for (placeholder, type, prefix) in configurations {
            let field = SKTextField(frame: .zero)
            field.placeholder = placeholder
            field.accessibilityLabel = placeholder
            field.setPreferredInputType(type)
            field.setMaximumAllowedCharacters(20)
            field.prefixCharacter = prefix
            field.height(48)
            screen.stack.addArrangedSubview(field)
        }
        screen.addButton("Done") { [weak screen] in screen?.view.endEditing(true) }
        return screen
    }

    private static func paddingLabel() -> UIViewController {
        let screen = ComponentStackViewController()
        let label = SKPaddingLabel()
        label.text = "A padded label that supports multiple lines. Change text size using Preview."
        label.font = .preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        label.backgroundColor = .secondarySystemBackground
        label.insets = UIEdgeInsets(top: 24, left: 20, bottom: 24, right: 20)
        screen.stack.addArrangedSubview(label)
        screen.addButton("Toggle Padding") { [weak label] in
            guard let label else { return }
            label.insets = label.topInset == 24 ? .zero : UIEdgeInsets(top: 24, left: 20, bottom: 24, right: 20)
        }
        return screen
    }

    private static func marquee() -> UIViewController {
        let screen = ComponentStackViewController()
        let marquee = SKMarqueeView()
        let label = UILabel()
        label.text = "SKComponentKit • Reusable UIKit components • EasyAnchor layouts • "
        label.font = .preferredFont(forTextStyle: .title2)
        marquee.contentView = label
        marquee.autoScroll = true
        marquee.height(60)
        screen.stack.addArrangedSubview(marquee)
        screen.addButton("Start") { [weak marquee] in marquee?.startMarquee() }
        screen.addButton("Stop") { [weak marquee] in marquee?.stopMarquee() }
        return screen
    }

    private static func refreshing() -> UIViewController {
        let screen = ComponentStackViewController()
        let container = UIView()
        container.height(80)
        let spinner = SKRefreshingView()
        spinner.layout {
            container.addSubview($0)
            $0.size(equalTo: 32).center()
        }
        screen.stack.addArrangedSubview(container)
        spinner.startAnimating()
        screen.addButton("Start") { [weak spinner] in spinner?.startAnimating() }
        screen.addButton("Stop") { [weak spinner] in spinner?.stopAnimating() }
        screen.addButton("Change Tint") { [weak spinner] in spinner?.tintColor = .systemOrange }
        return screen
    }

    private static func zigzag() -> UIViewController {
        let screen = ComponentStackViewController()
        let receipt = SKZigzagView(numberOfZigZagLines: 24)
        receipt.height(160)
        let label = UILabel()
        label.text = "SKComponentKit\nReceipt preview"
        label.numberOfLines = 0
        label.textAlignment = .center
        label.layout {
            receipt.addSubview($0)
            $0.fill(insets: UIEdgeInsets(top: 20, left: 20, bottom: 28, right: 20))
        }
        screen.stack.addArrangedSubview(receipt)
        return screen
    }

    private static func dialogue() -> UIViewController {
        let screen = ComponentStackViewController()
        screen.addButton("Present Dialogue") { [weak screen] in
            screen?.present(DialogueComponentDemo(), animated: true)
        }
        return screen
    }

    private static func loading() -> UIViewController {
        let screen = ComponentStackViewController()
        screen.addText("The overlay dismisses automatically after one second.")
        screen.addButton("Show Loading") { [weak screen] in
            let overlay = SKLoadingViewController()
            screen?.present(overlay, animated: true) { [weak overlay] in
                SKMainThread.delay(after: .now() + 1) { [weak overlay] in
                    overlay?.dismiss(animated: true)
                }
            }
        }
        return screen
    }

    private static func scanner() -> UIViewController {
        let screen = ComponentStackViewController()
        let result = screen.addText("Use a physical device to scan QR codes. Simulator shows the scanning frame only.")
        screen.addButton("Open Scanner") { [weak screen, weak result] in
            let scanner = SKQRCodeScannerController()
            scanner.title = "Scan QR Code"
            scanner.onResult = { [weak result] value in result?.text = "Scanned: \(value)" }
            screen?.navigationController?.pushViewController(scanner, animated: true)
        }
        return screen
    }

    private static func blur() -> UIViewController {
        let screen = ComponentStackViewController()
        for intensity: CGFloat in [0.2, 0.5, 1] {
            screen.addText("Blur intensity: \(intensity)")
            let background = UIView()
            background.backgroundColor = .systemBlue
            background.height(100)
            let label = UILabel()
            label.text = "Background content"
            label.textColor = .white
            label.layout { background.addSubview($0); $0.center() }
            let blur = SKCustomIntensityVisualEffectView(effect: UIBlurEffect(style: .systemMaterial), intensity: intensity)
            blur.layout { background.addSubview($0); $0.fill() }
            screen.stack.addArrangedSubview(background)
        }
        return screen
    }

    private static func qrFrame() -> UIViewController {
        let screen = ComponentStackViewController()
        let frame = SKQRCornerRectangleView()
        frame.backgroundColor = .secondarySystemBackground
        frame.color = .systemBlue
        frame.radius = 16
        frame.thickness = 4
        frame.height(220)
        screen.stack.addArrangedSubview(frame)
        return screen
    }
}

@MainActor
private final class ComponentStackViewController: UIViewController {
    let stack = UIStackView()

    init() {
        super.init(nibName: nil, bundle: nil)
        stack.axis = .vertical
        stack.spacing = 20
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("Use init()") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        let scroll = UIScrollView()
        scroll.keyboardDismissMode = .interactive
        scroll.layout { view.addSubview($0); $0.fill() }
        stack.layout {
            scroll.addSubview($0)
            $0.top(constraint: scroll.contentLayoutGuide.topAnchor, 24)
                .leading(constraint: scroll.contentLayoutGuide.leadingAnchor, 24)
                .trailing(constraint: scroll.contentLayoutGuide.trailingAnchor, 24)
                .bottom(constraint: scroll.contentLayoutGuide.bottomAnchor, 24)
            // EasyAnchor does not expose dimension equality with a constant.
            $0.widthAnchor.constraint(equalTo: scroll.frameLayoutGuide.widthAnchor, constant: -48).isActive = true
        }
    }

    @discardableResult
    func addText(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        stack.addArrangedSubview(label)
        return label
    }

    func addButton(_ title: String, action: @escaping @MainActor () -> Void) {
        var configuration = UIButton.Configuration.tinted()
        configuration.title = title
        let button = UIButton(configuration: configuration, primaryAction: UIAction { _ in action() })
        stack.addArrangedSubview(button)
    }
}

private final class ScrollComponentDemo: SKScrollViewController {
    override var allowedKeyboardObservation: Bool { true }

    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundColor = .systemBackground
        bottomContentView.height(0)
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 20
        for index in 1...12 {
            let field = SKTextField(frame: .zero)
            field.placeholder = "Field \(index)"
            field.height(48)
            stack.addArrangedSubview(field)
        }
        stack.layout { contentView.addSubview($0); $0.fill(insets: UIEdgeInsets(top: 24, left: 24, bottom: 24, right: 24)) }
    }
}

private final class DialogueComponentDemo: SKDialogueViewController {
    override var allowDismissOnTap: Bool { true }

    override func viewDidLoad() {
        super.viewDidLoad()
        let label = UILabel()
        label.text = "A reusable dialogue"
        label.numberOfLines = 0
        label.textAlignment = .center
        var configuration = UIButton.Configuration.filled()
        configuration.title = "Dismiss Dialogue"
        let button = UIButton(configuration: configuration, primaryAction: UIAction { [weak self] _ in
            self?.dismissWithSlideOut()
        })
        let stack = UIStackView(arrangedSubviews: [label, button])
        stack.axis = .vertical
        stack.spacing = 24
        stack.layout { contentView.addSubview($0); $0.fill(insets: UIEdgeInsets(top: 24, left: 24, bottom: 24, right: 24)) }
    }
}
