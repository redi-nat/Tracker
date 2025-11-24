import UIKit

final class MainTabBarController: UITabBarController {
    
    private let separator = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSeparator()
        setupViewControllers()
        self.view.isUserInteractionEnabled = true
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
    
    private func setupViewControllers() {
        
        let trackersVC = TrackersViewController()
        let statisticsVC = StatisticsViewController()
        
        let trackersNav = UINavigationController(rootViewController: trackersVC)
        let statisticsNav = UINavigationController(rootViewController: statisticsVC)
        
        trackersVC.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(resource: .trackerTabBar),
            selectedImage: nil
        )
        
        statisticsVC.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(resource: .statisticsTabBar),
            selectedImage: nil
        )
        
        self.viewControllers = [trackersNav, statisticsNav]
    }
}
