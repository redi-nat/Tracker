import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        
        let hasCompletedOnboarding = UserDefaultsService.shared.hasCompletedOnboarding
        
        let rootViewController: UIViewController
        
        if hasCompletedOnboarding {
            rootViewController = MainTabBarController()
        } else {
            rootViewController = OnboardingViewController()
        }

        window.rootViewController = rootViewController
        window.makeKeyAndVisible()
        
        self.window = window
    }
}



