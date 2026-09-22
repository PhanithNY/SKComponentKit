//
//  DemoHostViewController.swift
//  SKComponentKit
//
//  Created by Suykorng on 22/9/26.
//

import UIKit

/// Hosts any UIKit demo with appearance and Dynamic Type overrides scoped to this screen.
final class DemoHostViewController: UIViewController {
    private let content: UIViewController
    private var selectedTextSize: UIContentSizeCategory?

    init(demo: ComponentDemo) {
        content = demo.makeViewController()
        super.init(nibName: nil, bundle: nil)
        title = demo.title
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("Use init(demo:)") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.largeTitleDisplayMode = .never

        addChild(content)
        content.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(content.view)
        NSLayoutConstraint.activate([
            content.view.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            content.view.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            content.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            content.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
        content.didMove(toParent: self)
        updatePreviewMenu()
    }

    private func updatePreviewMenu() {
        let appearances: [(String, UIUserInterfaceStyle)] = [
            ("System Appearance", .unspecified), ("Light", .light), ("Dark", .dark),
        ]
        let appearanceActions = appearances.map { title, style in
            UIAction(title: title, state: overrideUserInterfaceStyle == style ? .on : .off) { [weak self] _ in
                self?.overrideUserInterfaceStyle = style
                self?.updatePreviewMenu()
            }
        }
        let sizes: [(String, UIContentSizeCategory?)] = [
            ("System Text Size", nil),
            ("Large (Default)", .large),
            ("Extra Extra Extra Large", .extraExtraExtraLarge),
            ("Accessibility XXXL", .accessibilityExtraExtraExtraLarge),
        ]
        let textActions = sizes.map { title, size in
            UIAction(title: title, state: selectedTextSize == size ? .on : .off) { [weak self] _ in
                guard let self else { return }
                selectedTextSize = size
                let traits = size.map { UITraitCollection(preferredContentSizeCategory: $0) }
                setOverrideTraitCollection(traits, forChild: content)
                updatePreviewMenu()
            }
        }
        let menu = UIMenu(children: [
            UIMenu(title: "Demo Appearance", options: .displayInline, children: appearanceActions),
            UIMenu(title: "Demo Text Size", options: .displayInline, children: textActions),
        ])
        let item = UIBarButtonItem(title: "Preview", image: nil, primaryAction: nil, menu: menu)
        item.accessibilityIdentifier = "previewSettings"
        item.accessibilityLabel = "Preview settings"
        navigationItem.rightBarButtonItem = item
    }
}
