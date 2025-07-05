//
//  AppRouter.swift
//  MyPlate
//
//  Created by 𝕄𝕒𝕥𝕧𝕖𝕪 ℙ𝕠𝕕𝕘𝕠𝕣𝕟𝕚𝕪 on 01.07.2025.
//

import Foundation
import UIKit

final class AppRouter {

    static let shared = AppRouter()

    private init() {}

    func start(in window: UIWindow) {
        // Global UINavigationBarAppearance setup
        let appearance = UINavigationBar.appearance()
        appearance.tintColor = .black

//        let navAppearance = UINavigationBarAppearance()
////        navAppearance.configureWithOpaqueBackground()
//        navAppearance.backgroundColor = .clear
//        navAppearance.backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]
//        navAppearance.backButtonAppearance.highlighted.titleTextAttributes = [.foregroundColor: UIColor.clear]

//        appearance.standardAppearance = navAppearance
//        appearance.scrollEdgeAppearance = navAppearance
//        appearance.compactAppearance = navAppearance
        if !UserDefaults.standard.bool(forKey: "hasLaunchedBefore") {
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
            let onboardingVC = OnboardingViewController()
            let onboardingNav = UINavigationController(rootViewController: onboardingVC)
            onboardingVC.onFinish = {
                let personalizeVC = PersonalizeViewController()
                let personalizeNav = UINavigationController(rootViewController: personalizeVC)
                personalizeVC.onFinish = {
                    self.showPaywall(over: personalizeNav, in: window)
                }
                window.rootViewController = personalizeNav
            }
            window.rootViewController = onboardingNav
            window.makeKeyAndVisible()
        } else {
            showMainTabBar(in: window)
        }
    }

    private func showPaywall(over presentingVC: UIViewController, in window: UIWindow) {
        let paywallVC = PaywallViewController()
        paywallVC.onClose = { [weak window] in
            guard let window = window else { return }
            self.showMainTabBar(in: window)
        }
        paywallVC.modalPresentationStyle = .fullScreen
        presentingVC.present(paywallVC, animated: true)
    }

    private func showMainTabBar(in window: UIWindow) {
        let tabBarController = EntryTabBarController()
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }

}
