//
//  Splash.swift
//  MyPlate
//
//  Created by 𝕄𝕒𝕥𝕧𝕖𝕪 ℙ𝕠𝕕𝕘𝕠𝕣𝕟𝕚𝕪 on 30.06.2025.
//

import Foundation
import UIKit
import SnapKit
import StoreKit
import UserNotifications

final class OnboardingViewController: UIViewController {

    private let images = ["ob1", "ob2", "ob3", "ob4"]
    private var currentIndex = 0
    var onFinish: (() -> Void)?

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    private let bottomContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.font(size: 36, weight: .bold)
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.font(size: 16, weight: .regular)
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()

    private let titles = [
        "Snap & Track Your Meals",
        "See Your Progress Clearly",
        "Stay Consistent, Get Rewarded",
        "Stay on Track with Reminders"
    ]

    private let descriptions = [
        "Snap a photo or write down what you ate — we'll count the calories and keep you on track.",
        "Log your weight regularly and watch your transformation over time. Every step forward counts.",
        "Fill your diary daily and earn streaks — we celebrate your progress. Your habits build your success.",
        "Turn on notifications to get meal reminders, weight check-ins, and motivational tips."
    ]
    
    private let nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Next", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = Fonts.font(size: 16, weight: .regular)
        button.backgroundColor = Colors.orange
        button.layer.cornerRadius = 8
        return button
    }()
    
    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("✕", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = Fonts.font(size: 24, weight: .medium)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        updateImage()
        nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
    }

    private func setupLayout() {
        view.backgroundColor = .white
        view.addSubview(imageView)
        view.addSubview(bottomContainer)
        view.addSubview(closeButton)
        bottomContainer.addSubview(titleLabel)
        bottomContainer.addSubview(descriptionLabel)
        bottomContainer.addSubview(nextButton)

        imageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(40)
            make.leading.trailing.equalToSuperview()
            make.height.lessThanOrEqualToSuperview().multipliedBy(0.6)
        }

        bottomContainer.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(340)
            make.bottom.equalToSuperview().offset(24)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.leading.trailing.equalTo(titleLabel)
        }

        nextButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(48)
        }
        
        closeButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            make.trailing.equalToSuperview().inset(16)
            make.width.height.equalTo(36)
        }
    }

    @objc private func nextTapped() {
        if currentIndex == 3 {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                DispatchQueue.main.async {
                    self.onFinish?()
                }
            }
            return
        }

        currentIndex = (currentIndex + 1) % images.count
        updateImage()

        if currentIndex == 2 {
            if let scene = view.window?.windowScene {
                SKStoreReviewController.requestReview(in: scene)
            }
        }

        nextButton.setTitle(currentIndex == 3 ? "Turn on Notifications" : "Next", for: .normal)
    }

    @objc private func closeTapped() {
        print("Крестик нажат")
        onFinish?()
    }

    private func updateImage() {
        imageView.image = UIImage(named: images[currentIndex])
        titleLabel.text = titles[currentIndex]
        descriptionLabel.text = descriptions[currentIndex]
        closeButton.isHidden = currentIndex != 3
    }
}
