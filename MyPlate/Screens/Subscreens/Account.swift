//
//  Account.swift
//  MyPlate
//
//  Created by 𝕄𝕒𝕥𝕧𝕖𝕪 ℙ𝕠𝕕𝕘𝕠𝕣𝕟𝕚𝕪 on 04.07.2025.
//

import Foundation

import UIKit
import SnapKit
import UserNotifications

final class AccountSettingsViewController: UIViewController {

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    private let deleteButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Delete an Account", for: .normal)
        btn.setTitleColor(.red, for: .normal)
        btn.layer.borderColor = UIColor.red.cgColor
        btn.layer.borderWidth = 1
        btn.backgroundColor = Colors.background
        btn.layer.cornerRadius = 16
        return btn
    }()

    private let versionLabel: UILabel = {
        let label = UILabel()
        label.text = "App Version 1.0.0"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = Fonts.font(size: 12, weight: .regular)
        return label
    }()

    private var userProfile: UserProfile?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "My Account"
        // Add pro_label to navigation bar right only if no active subscription
        if SubscriptionHandler.shared.hasActiveSubscription {
            let proLabelImageView = UIImageView(image: UIImage(named: "pro_label"))
            proLabelImageView.contentMode = .scaleAspectFit
            proLabelImageView.snp.makeConstraints { make in
                make.width.equalTo(70)
                make.height.equalTo(32)
            }
            let barButtonItem = UIBarButtonItem(customView: proLabelImageView)
            navigationItem.rightBarButtonItem = barButtonItem
        }
        view.backgroundColor = Colors.background

        userProfile = DataFlow().loadUserProfileFromFile()

        setupViews()
        setupSections()
        setupFooter()

        deleteButton.addTarget(self, action: #selector(deleteAccountTapped), for: .touchUpInside)
    }

    private func setupViews() {
        view.addSubview(scrollView)
        scrollView.backgroundColor = Colors.background
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(32) // увеличить отступ снизу
            make.height.greaterThanOrEqualTo(view.safeAreaLayoutGuide.snp.height)
        }

        scrollView.addSubview(contentStack)
        contentStack.axis = .vertical
        contentStack.spacing = 32
        contentStack.alignment = .center
        contentStack.snp.remakeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalTo(view.snp.width) // фиксируем ширину, чтобы вертикальный скролл работал
        }
    }

    private func setupSections() {
        // 1. User Info (без заголовка)
        let userInfoSection = makeSection(title: nil, items: [
            ("Gender", userProfile?.gender.rawValue.capitalized ?? ""),
            ("Age", userProfile != nil ? "\(userProfile!.age)" : ""),
            ("Height", userProfile != nil ? "\(userProfile!.heightCm) cm" : ""),
            ("Current Weight", userProfile != nil ? "\(userProfile!.currentWeightKg) kg" : "")
        ])
        contentStack.addArrangedSubview(userInfoSection)

        // 2. My Goals
        let goalsSection = makeSection(title: "My Goals", items: [
            ("Goal", userProfile?.goal.rawValue.capitalized ?? ""),
            ("Weight Goal", userProfile != nil ? "\(userProfile!.targetWeightKg) kg" : ""),
            ("Calorie Goal", userProfile != nil ? "\(userProfile!.totalCalories) kcal" : ""),
            ("Type of Diet", userProfile?.dietType.rawValue.capitalized ?? ""),
            ("Type of Activity", userProfile?.activityLevel.raw ?? "")
        ])
        contentStack.addArrangedSubview(goalsSection)

        // 3. Application Settings
        let startOver = makeLabelRow(title: "Start Over", value: nil)
        let subscriptionManagement = makeLabelRow(title: "Subscription Management", value: nil)
        let tap = UITapGestureRecognizer(target: self, action: #selector(subscriptionTapped))
        subscriptionManagement.addGestureRecognizer(tap)
        subscriptionManagement.isUserInteractionEnabled = true
        let notifications = makeSwitchRow(title: "Notifications", isOn: true)

        let appSettingsStack = UIStackView(arrangedSubviews: [startOver, subscriptionManagement, notifications])
        appSettingsStack.axis = .vertical
        appSettingsStack.spacing = 12

        let appSettingsSection = makeSection(title: "Application Settings", customContent: appSettingsStack)
        contentStack.addArrangedSubview(appSettingsSection)

        // 4. Other
        let contactUs = makeLinkRow(title: "Contact Us", link: "mailto:horneabadiyv@gmail.com")
        let privacy = makeLinkRow(title: "Privacy Policy", link: "https://docs.google.com/document/d/1aABSUHe21EffUtRM2wgDdOVJMM_wMq1M2u_7EtTE-9M/edit?tab=t.0")
        let terms = makeLinkRow(title: "Terms of Use", link: "https://docs.google.com/document/d/1iwi_hR1-R-gI1QTmWcgLMtsoasqXx-9KnddslCHfTdY/edit?tab=t.0#heading=h.3i4qskbz79w1")
        let otherStack = UIStackView(arrangedSubviews: [contactUs, privacy, terms])
        otherStack.axis = .vertical
        otherStack.spacing = 12
        let otherSection = makeSection(title: "Other", customContent: otherStack)
        contentStack.addArrangedSubview(otherSection)
    }

    private func setupFooter() {
        deleteButton.setTitle("Reset Account", for: .normal)
        contentStack.addArrangedSubview(deleteButton)
        contentStack.addArrangedSubview(versionLabel)

        deleteButton.snp.makeConstraints { make in
            make.height.equalTo(44)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        versionLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-16)
        }
    }

    // MARK: - Helpers

    private func makeSection(title: String?, items: [(String, String)]) -> UIView {
        let sectionView = UIView()

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12

        if let title = title {
            let titleLabel = UILabel()
            titleLabel.text = title
            titleLabel.font = Fonts.font(size: 14, weight: .medium)
            titleLabel.textColor = .gray
            sectionView.addSubview(titleLabel)
            titleLabel.snp.makeConstraints { make in
                make.top.leading.trailing.equalToSuperview().inset(16)
            }

            sectionView.addSubview(stack)
            stack.snp.makeConstraints { make in
                make.top.equalTo(titleLabel.snp.bottom).offset(12)
                make.leading.trailing.bottom.equalToSuperview().inset(16)
                make.width.equalTo(340)
            }
        } else {
            sectionView.addSubview(stack)
            stack.snp.makeConstraints { make in
                make.edges.equalToSuperview().inset(16)
                make.width.equalTo(340)
            }
        }

        for (name, value) in items {
            let row = makeLabelRow(title: name, value: value)
            stack.addArrangedSubview(row)
        }

        return sectionView
    }

    private func makeSection(title: String?, customContent: UIView) -> UIView {
        let sectionView = UIView()

        if let title = title {
            let titleLabel = UILabel()
            titleLabel.text = title
            titleLabel.font = Fonts.font(size: 14, weight: .medium)
            titleLabel.textColor = .gray
            sectionView.addSubview(titleLabel)
            titleLabel.snp.makeConstraints { make in
                make.top.leading.trailing.equalToSuperview().inset(16)
            }

            sectionView.addSubview(customContent)
            customContent.snp.makeConstraints { make in
                make.top.equalTo(titleLabel.snp.bottom).offset(12)
                make.leading.trailing.bottom.equalToSuperview().inset(16)
                make.width.equalTo(340)
            }
        } else {
            sectionView.addSubview(customContent)
            customContent.snp.makeConstraints { make in
                make.edges.equalToSuperview().inset(16)
                make.width.equalTo(340)
            }
        }

        return sectionView
    }

    private func makeLabelRow(title: String, value: String?) -> UIView {
        let container = UIView()
        container.backgroundColor = .white
        container.layer.cornerRadius = 16

        let innerStack = UIStackView()
        innerStack.axis = .horizontal
        innerStack.alignment = .center
        innerStack.distribution = .fill
        innerStack.spacing = 8
        innerStack.isLayoutMarginsRelativeArrangement = true
        innerStack.layoutMargins = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = Fonts.font(size: 16, weight: .regular)
        titleLabel.textColor = .black

        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = Fonts.font(size: 16, weight: .regular)
        valueLabel.textColor = .darkGray
        valueLabel.textAlignment = .right
        valueLabel.setContentHuggingPriority(.required, for: .horizontal)

        innerStack.addArrangedSubview(titleLabel)
        innerStack.addArrangedSubview(valueLabel)

        container.addSubview(innerStack)
        innerStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        if let link = value, !link.isEmpty {
            container.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(handleLinkTap(_:)))
            container.addGestureRecognizer(tap)
            container.accessibilityHint = link
        }

        container.snp.makeConstraints { make in
            make.width.equalTo(340)
        }

        // Отступы вокруг контейнера при добавлении в стэк будут добавляться в setupSections
        // Но так как здесь не добавляем в стэк, нужно добавить отступы при добавлении.
        // Поэтому возвращаем container, а в setupSections добавим отступы.

        // Чтобы добавить отступы вокруг container при добавлении в UIStackView,
        // необходимо в setupSections заменить addArrangedSubview(row) на:
        // contentStack.addArrangedSubview(row)
        // row.snp.makeConstraints { make in
        //    make.leading.trailing.equalToSuperview().inset(16)
        // }

        return container
    }
    
    @objc private func subscriptionTapped() {
        let paywall = PaywallViewController()
        navigationController?.pushViewController(paywall, animated: true)
    }


    private func makeSwitchRow(title: String, isOn: Bool) -> UIView {
        let container = UIView()
        container.backgroundColor = .white
        container.layer.cornerRadius = 16

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = Fonts.font(size: 16, weight: .regular)
        titleLabel.textColor = .black

        let switchControl = UISwitch()
        switchControl.isOn = isOn
        switchControl.onTintColor = Colors.gray // оранжевый фон, когда включен
        switchControl.thumbTintColor = Colors.orange // серый кружок
        switchControl.addTarget(self, action: #selector(didChangeNotificationSwitch(_:)), for: .valueChanged)

        container.addSubview(titleLabel)
        container.addSubview(switchControl)

        titleLabel.snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview().inset(12)
        }
        switchControl.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel.snp.centerY)
            make.trailing.equalToSuperview().inset(16)
        }

        return container
    }

    // MARK: - Actions

    @objc private func deleteAccountTapped() {
        resetProfileTapped()
    }

    @objc private func didChangeNotificationSwitch(_ sender: UISwitch) {
        if sender.isOn {
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                DispatchQueue.main.async {
                    switch settings.authorizationStatus {
                    case .notDetermined:
                        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                            DispatchQueue.main.async {
                                sender.setOn(granted, animated: true)
                            }
                        }
                    case .denied:
                        sender.setOn(false, animated: true)
                        self.showNotificationsDeniedAlert()
                    case .authorized, .provisional, .ephemeral:
                        sender.setOn(true, animated: true)
                    @unknown default:
                        sender.setOn(false, animated: true)
                    }
                }
            }
        } else {
            if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(appSettings)
            }
            sender.setOn(false, animated: true)
        }
    }

    
    private func makeLinkRow(title: String, link: String) -> UIView {
        let container = UIView()
        container.backgroundColor = .white
        container.layer.cornerRadius = 16

        let label = UILabel()
        label.text = title
        label.font = Fonts.font(size: 16, weight: .regular)
        label.textColor = .black

        let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevron.tintColor = .gray
        chevron.setContentHuggingPriority(.required, for: .horizontal)

        let stack = UIStackView(arrangedSubviews: [label, chevron])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        stack.layoutMargins = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        stack.isLayoutMarginsRelativeArrangement = true

        container.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        container.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleLinkTap(_:)))
        container.addGestureRecognizer(tap)
        container.accessibilityHint = link

        container.snp.makeConstraints { make in
            make.width.equalTo(340)
        }

        return container
    }

    
    private func showNotificationsDeniedAlert() {
        let alert = UIAlertController(title: "Notifications Disabled", message: "Please enable notifications in Settings.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    @objc private func handleLinkTap(_ sender: UITapGestureRecognizer) {
        guard let view = sender.view,
              let link = view.accessibilityHint,
              let url = URL(string: link)
        else { return }
        UIApplication.shared.open(url)
    }
    
    
    @objc private func resetProfileTapped() {
        let dataFlow = DataFlow()
      
        let emptyProfile = UserProfile(
            gender: .male,
            age: 0,
            heightCm: 0,
            startWeight: 0,
            currentWeightKg: 0,
            targetWeightKg: 0,
            weightStat: [:],
            goal: .maintain,
            dietType: .balanced,
            activityLevel: .moderate,
            inputHeightUnit: .cm,
            inputWeightUnit: .kg
        )
        dataFlow.saveUserProfileToFile(profile: emptyProfile)
        
        let onboarding = PersonalizeViewController()
        onboarding.onFinish = { [weak self] in
            self?.userProfile = DataFlow().loadUserProfileFromFile()
            self?.contentStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
            self?.setupSections()
            self?.setupFooter()
            self?.dismiss(animated: true)
        }
        let nav = UINavigationController(rootViewController: onboarding)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }

}

