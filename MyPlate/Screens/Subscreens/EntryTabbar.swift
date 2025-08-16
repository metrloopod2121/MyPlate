//
//  EntryTabbar.swift
//  MyPlate
//
//  Created by 𝕄𝕒𝕥𝕧𝕖𝕪 ℙ𝕠𝕕𝕘𝕠𝕣𝕟𝕚𝕪 on 02.07.2025.
//

import Foundation
import UIKit

final class EntryTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Устанавливаем кастомный таббар
        setValue(CustomTabbar(), forKey: "tabBar")

        setupTabBar()
    }

    private func setupTabBar() {
        // Первый таб — Home
        let homeVC = UINavigationController(rootViewController: HomeViewController())
        homeVC.tabBarItem = UITabBarItem(
            title: "Home",
            image: UIImage(named: "home_icon_deactive")?.withRenderingMode(.alwaysOriginal),
            selectedImage: UIImage(named: "home_icon_active")?.withRenderingMode(.alwaysOriginal)
        )
        homeVC.tabBarItem.setTitleTextAttributes([.foregroundColor: UIColor.gray], for: .normal)
        homeVC.tabBarItem.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        homeVC.tabBarItem.imageInsets = UIEdgeInsets(top: -5, left: 0, bottom: 5, right: 0)
        homeVC.tabBarItem.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -4)
        homeVC.view.backgroundColor = Colors.background

        // Второй таб — Weight (пример)
        let weightVC = UINavigationController(rootViewController: WeightControlViewController())
        weightVC.tabBarItem = UITabBarItem(
            title: "Weight",
            image: UIImage(named: "weight_icon_deactive")?.withRenderingMode(.alwaysOriginal),
            selectedImage: UIImage(named: "weight_icon_active")?.withRenderingMode(.alwaysOriginal)
        )
        weightVC.tabBarItem.setTitleTextAttributes([.foregroundColor: UIColor.gray], for: .normal)
        weightVC.tabBarItem.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        weightVC.tabBarItem.imageInsets = UIEdgeInsets(top: -5, left: 0, bottom: 5, right: 0)
        weightVC.tabBarItem.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -4)
        weightVC.view.backgroundColor = Colors.background

        viewControllers = [homeVC, weightVC]

        tabBar.barStyle = .black
        tabBar.isTranslucent = false
        tabBar.backgroundColor = Colors.background
        tabBar.tintColor = .white
        tabBar.unselectedItemTintColor = .gray
    }

    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let index = tabBar.items?.firstIndex(of: item),
              let navController = viewControllers?[index] as? UINavigationController else {
            return
        }

        // При выборе таба возвращаемся к корню навигации
        navController.popToRootViewController(animated: true)
    }
}
