import UIKit

final class ComponentCatalogViewController: UITableViewController, UISearchResultsUpdating {
    private let searchController = UISearchController(searchResultsController: nil)
    private var query = ""

    private var matchingComponents: [ComponentDemo] {
        ComponentRegistry.components.filter(matches)
    }

    private var matchingTools: [ComponentDemo] {
        [ComponentRegistry.playground].filter(matches)
    }

    init() {
        super.init(style: .insetGrouped)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("Use init()") }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "SKComponentKit"
        navigationController?.navigationBar.prefersLargeTitles = true
        tableView.accessibilityIdentifier = "componentCatalog"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "demo")
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search components"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }

    func updateSearchResults(for searchController: UISearchController) {
        query = (searchController.searchBar.text ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        tableView.reloadData()
    }

    override func numberOfSections(in tableView: UITableView) -> Int { 2 }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? matchingComponents.count : matchingTools.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 0 ? "Components" : "Development"
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        guard section == 0, matchingComponents.isEmpty else { return nil }
        return query.isEmpty
            ? "Your component catalog starts here. New UIKit demos will appear as components are added to the package."
            : "No components match your search."
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let demo = demo(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: "demo", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = demo.title
        content.secondaryText = demo.summary
        content.image = UIImage(systemName: demo.symbolName)
        content.imageProperties.tintColor = .systemBlue
        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator
        cell.isAccessibilityElement = true
        cell.accessibilityIdentifier = "demo.\(demo.title)"
        cell.accessibilityLabel = demo.title
        cell.accessibilityHint = demo.summary
        cell.accessibilityTraits = .button
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedDemo = demo(at: indexPath)
        navigationController?.pushViewController(DemoHostViewController(demo: selectedDemo), animated: true)
    }

    private func demo(at indexPath: IndexPath) -> ComponentDemo {
        indexPath.section == 0 ? matchingComponents[indexPath.row] : matchingTools[indexPath.row]
    }

    private func matches(_ demo: ComponentDemo) -> Bool {
        query.isEmpty || "\(demo.title) \(demo.summary)".localizedCaseInsensitiveContains(query)
    }
}
