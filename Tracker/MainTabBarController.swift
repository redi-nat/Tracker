import UIKit

final class MainTabBarController: UITabBarController {

    private let separator = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSeparator()
    }

    private func setupSeparator() {
        separator.backgroundColor = .systemGray4
        separator.translatesAutoresizingMaskIntoConstraints = false
        tabBar.addSubview(separator)

        NSLayoutConstraint.activate([
            separator.topAnchor.constraint(equalTo: tabBar.topAnchor),
            separator.leadingAnchor.constraint(equalTo: tabBar.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: tabBar.trailingAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
}
