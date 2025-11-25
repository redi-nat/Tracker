import UIKit

final class OnboardingViewController: UIPageViewController {
    
    // MARK: - Properties
    
    private lazy var pages: [OnboardingPage] = [
        OnboardingPage(imageName: "onboarding1", text: "Отслеживайте только то, что хотите"),
        OnboardingPage(imageName: "onboarding2", text: "Даже если это не литры воды и йога")
    ]
    
    private lazy var pageViewControllers: [UIViewController] = {
        return pages.map { OnboardingPageViewController(page: $0) }
    }()
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        pageControl.currentPageIndicatorTintColor = .ypBlack
        pageControl.pageIndicatorTintColor = .ypGray3
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()
    
    // MARK: - Initialization
    
    init() {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        return nil
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        
        setupInitialPage()
        setupUI()
    }
    
    // MARK: - Setup
    
    private func setupInitialPage() {
        if let firstVC = pageViewControllers.first {
            setViewControllers([firstVC], direction: .forward, animated: true, completion: nil)
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        let button = UIButton(type: .system)
        button.setTitle("Вот это технологии!", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .ypBlack
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTapDoneButton), for: .touchUpInside)
        
        view.addSubview(pageControl)
        view.addSubview(button)
        
        NSLayoutConstraint.activate([
            // Page Control
            pageControl.bottomAnchor.constraint(equalTo: button.topAnchor, constant: -24),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Кнопка
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            button.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func didTapDoneButton() {
        UserDefaultsService.shared.hasCompletedOnboarding = true
        let tabBarVC = MainTabBarController()
        
        guard let window = self.view.window else {
            return
        }
        
        window.rootViewController = tabBarVC
        
        UIView.transition(with: window,
                          duration: 0.3,
                          options: .transitionCrossDissolve,
                          animations: nil,
                          completion: nil)
    }
    
    // MARK: - Helper
    
    private func getIndex(of viewController: UIViewController) -> Int? {
        return pageViewControllers.firstIndex(of: viewController)
    }
}

extension OnboardingViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = getIndex(of: viewController) else { return nil }
        let count = pageViewControllers.count
        let previousIndex = (currentIndex - 1 + count) % count
        return pageViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = getIndex(of: viewController) else { return nil }
        let count = pageViewControllers.count
        let nextIndex = (currentIndex + 1) % count
        return pageViewControllers[nextIndex]
    }
}

extension OnboardingViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if completed,
           let currentViewController = pageViewController.viewControllers?.first,
           let currentIndex = getIndex(of: currentViewController)
        {
            pageControl.currentPage = currentIndex
        }
    }
}
