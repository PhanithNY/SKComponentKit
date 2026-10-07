import SKComponentKit
import UIKit

final class TopScrollEdgeDemoViewController: SKViewController {
    private var isEffectEnabled = true
    private var originalPrefersLargeTitles: Bool?

    override var preferredCustomTopEdgeEffectOverSystemProvidedComponent: Bool { isEffectEnabled }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.alwaysBounceVertical = true
        view.addSubview(scroll)

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(stack)
        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: view.topAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stack.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor, constant: 24),
            stack.leadingAnchor.constraint(equalTo: scroll.contentLayoutGuide.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: scroll.contentLayoutGuide.trailingAnchor, constant: -24),
            stack.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor, constant: -24),
            stack.widthAnchor.constraint(equalTo: scroll.frameLayoutGuide.widthAnchor, constant: -48),
        ])

        let explanation = UILabel()
        explanation.numberOfLines = 0
        explanation.font = .preferredFont(forTextStyle: .body)
        explanation.adjustsFontForContentSizeCategory = true
        explanation.text = SKTopScrollEdgeEffect.isSupported
            ? "Scroll to see content blur beneath the navigation bar. Toggle the custom effect to compare."
            : "The custom top-edge blur activates on iOS 27 and later. Earlier versions keep their standard appearance."
        stack.addArrangedSubview(explanation)

        var configuration = UIButton.Configuration.tinted()
        configuration.title = "Toggle Custom Effect"
        let button = UIButton(configuration: configuration, primaryAction: UIAction { [weak self] _ in
            guard let self else { return }
            isEffectEnabled.toggle()
            updateTopScrollEdgeEffect()
        })
        stack.addArrangedSubview(button)
        for index in 1...30 {
            let label = SKPaddingLabel()
            label.text = "Row \(index) — Scroll-edge preview"
            label.font = .preferredFont(forTextStyle: .headline)
            label.adjustsFontForContentSizeCategory = true
            label.backgroundColor = index.isMultiple(of: 2) ? .secondarySystemBackground : .tertiarySystemBackground
            stack.addArrangedSubview(label)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if originalPrefersLargeTitles == nil {
            originalPrefersLargeTitles = navigationController?.navigationBar.prefersLargeTitles
        }
        navigationController?.navigationBar.prefersLargeTitles = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let originalPrefersLargeTitles {
            navigationController?.navigationBar.prefersLargeTitles = originalPrefersLargeTitles
        }
        originalPrefersLargeTitles = nil
    }
}
