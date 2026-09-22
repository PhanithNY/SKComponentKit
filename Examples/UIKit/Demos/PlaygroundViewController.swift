import UIKit

/// Standard UIKit controls for checking the example host before package components are added.
final class PlaygroundViewController: UIViewController {
    private let headingLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let statusLabel = UILabel()
    private var tapCount = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        headingLabel.text = "Ready to build."
        descriptionLabel.text = "This playground uses standard UIKit controls. Use Preview to check light and dark appearance and larger text sizes. Your package components will have their own demos in the catalog."
        descriptionLabel.textColor = .secondaryLabel
        statusLabel.text = "Button tapped 0 times"
        statusLabel.accessibilityIdentifier = "tapCount"

        for label in [headingLabel, descriptionLabel, statusLabel] {
            label.numberOfLines = 0
            label.adjustsFontForContentSizeCategory = true
        }
        updateFonts()

        var configuration = UIButton.Configuration.filled()
        configuration.title = "Try Interaction"
        configuration.cornerStyle = .large
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 16, bottom: 14, trailing: 16)
        let button = UIButton(configuration: configuration, primaryAction: UIAction { [weak self] _ in
            guard let self else { return }
            tapCount += 1
            statusLabel.text = "Button tapped \(tapCount) \(tapCount == 1 ? "time" : "times")"
        })
        button.accessibilityIdentifier = "playgroundButton"

        let stack = UIStackView(arrangedSubviews: [headingLabel, descriptionLabel, button, statusLabel])
        stack.axis = .vertical
        stack.spacing = 24
        stack.translatesAutoresizingMaskIntoConstraints = false

        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(stack)
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -24),
            stack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 24),
            stack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -24),
            stack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -48),
        ])
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory {
            updateFonts()
        }
    }

    private func updateFonts() {
        headingLabel.font = .preferredFont(forTextStyle: .largeTitle, compatibleWith: traitCollection)
        descriptionLabel.font = .preferredFont(forTextStyle: .body, compatibleWith: traitCollection)
        statusLabel.font = .preferredFont(forTextStyle: .footnote, compatibleWith: traitCollection)
    }
}
