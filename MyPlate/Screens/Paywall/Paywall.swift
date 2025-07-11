//
//  Paywall.swift
//  MyPlate
//
//  Created by 𝕄𝕒𝕥𝕧𝕖𝕪 ℙ𝕠𝕕𝕘𝕠𝕣𝕟𝕚𝕪 on 30.06.2025.
//

import Foundation
import UIKit
import SnapKit
import ApphudSDK
import SwiftHelper

final class PaywallViewController: UIViewController {


    // MARK: - UI Utilities & Layout


    private enum Layout {
        static let sideInset: CGFloat = 16
        static let buttonHeight: CGFloat = 72
    }
    
    private let yearTitleLabel = UILabel()
    private let yearPriceLabel = UILabel()
    private let monthTitleLabel = UILabel()
    private let monthPriceLabel = UILabel()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let indicatorBackgroundView = UIView()
    private let indicatorBackground = UIView()

    struct SubscriptionOption {
        let product: ApphudProduct
        let price: Double
        let symbol: String
        let unit: String
        let duration: Int
        let hasTrial: Bool
        let trialValue: Int?
        let trialUnit: String?
    }

    private var products: [ApphudProduct] = []
    private var paywall: ApphudPaywall?
    private var isYearSelected = true
    private var yearOption: SubscriptionOption?
    private var monthOption: SubscriptionOption?
    var onClose: (() -> Void)?
    private let closeButton = UIButton(type: .system)
    private let continueButton = UIButton()
    private let privacyButton = UIButton(type: .system)
    private let restoreButton = UIButton(type: .system)
    private let termsButton = UIButton(type: .system)
    private let yearButton = UIButton()
    private let monthButton = UIButton()
    let discountBadge = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        selectPlan(isYear: true)
        loadProducts()
        closeButton.alpha = 0
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            UIView.animate(withDuration: 0.3) {
                self.closeButton.alpha = 1
            }
        }
    }

    private func setupUI() {
        view.backgroundColor = .white
        activityIndicator.color = .white
        activityIndicator.hidesWhenStopped = true
        // Indicator background for activityIndicator
        indicatorBackgroundView.isHidden = true
        view.addSubview(indicatorBackgroundView)
        indicatorBackgroundView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        indicatorBackground.backgroundColor = UIColor.white.withAlphaComponent(0.45)
        indicatorBackground.layer.cornerRadius = 16
        indicatorBackground.clipsToBounds = true
        indicatorBackgroundView.addSubview(indicatorBackground)
        indicatorBackground.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(80)
        }

        indicatorBackground.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        // continueButton
        continueButton.setTitle("Continue", for: .normal)
        continueButton.titleLabel?.font = Fonts.font(size: 16, weight: .regular)
        continueButton.backgroundColor = Colors.orange
        continueButton.layer.cornerRadius = 16
        continueButton.addTarget(self, action: #selector(didTapContinue), for: .touchUpInside)
        view.addSubview(continueButton)
        continueButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(Layout.sideInset)
            $0.bottom.equalToSuperview().inset(42)
            $0.height.equalTo(50)
        }

        // --- ScrollView and contentView ---
        let scrollView = UIScrollView()
        let contentView = UIView()
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalToSuperview().offset(50)
            $0.bottom.equalTo(continueButton.snp.top).offset(-16)
        }
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }

        // --- PW1, PW2, black overlay and feature stack ---
        let pw1ImageView = UIImageView(image: UIImage(named: "pw1"))
        pw1ImageView.contentMode = .scaleAspectFill
        pw1ImageView.isUserInteractionEnabled = true
        contentView.addSubview(pw1ImageView)
        pw1ImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
        }

        let pw2ImageView = UIImageView(image: UIImage(named: "pw2"))
        pw2ImageView.contentMode = .scaleAspectFill
        pw1ImageView.addSubview(pw2ImageView)
        pw2ImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview().offset(-10)
            $0.centerY.equalToSuperview().offset(-18)
            $0.width.equalToSuperview().multipliedBy(0.75)
            $0.height.equalTo(pw2ImageView.snp.width).multipliedBy(1.0)
        }

        let blackOverlayView = UIView()
        blackOverlayView.backgroundColor = Colors.darkGray
        blackOverlayView.layer.cornerRadius = 16
        blackOverlayView.clipsToBounds = true
        contentView.addSubview(blackOverlayView)
        blackOverlayView.snp.makeConstraints {
            $0.top.equalTo(pw1ImageView.snp.bottom).offset(-55)
//            $0.centerX.equalTo(pw1ImageView)
            $0.leading.trailing.equalToSuperview().inset(8)
        }

        let features = [
            "Adding dishes without restrictions",
            "Detailed statistics of your progress",
            "Smart Reminders"
        ]
        let featureStack = UIStackView()
        featureStack.axis = .vertical
        featureStack.alignment = .leading
        featureStack.spacing = 12
        blackOverlayView.addSubview(featureStack)
        featureStack.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(16)
        }

        features.forEach {
            let label = UILabel()
            label.text = $0
            label.font = Fonts.font(size: 16, weight: .medium)
            label.textColor = .white
            featureStack.addArrangedSubview(label)
        }

        // Move closeButton to pw1ImageView, top left
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.tintColor = .white
        closeButton.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
        pw1ImageView.addSubview(closeButton)
        closeButton.snp.remakeConstraints {
            $0.top.equalTo(pw1ImageView).offset(16)
            $0.leading.equalTo(pw1ImageView).offset(16)
            $0.size.equalTo(24)
        }

        // monthButton and yearButton with border (not background image)
        monthButton.setBackgroundImage(nil, for: .normal)
        monthButton.layer.cornerRadius = 16
        monthButton.layer.borderWidth = 1
        monthButton.layer.borderColor = UIColor(red: 176/255, green: 176/255, blue: 176/255, alpha: 1).cgColor
        monthButton.addTarget(self, action: #selector(monthTapped), for: .touchUpInside)
        contentView.addSubview(monthButton)

        yearButton.setBackgroundImage(nil, for: .normal)
        yearButton.layer.cornerRadius = 16
        yearButton.layer.borderWidth = 1
        yearButton.layer.borderColor = Colors.orange.cgColor
        yearButton.addTarget(self, action: #selector(yearTapped), for: .touchUpInside)
        contentView.addSubview(yearButton)

        // --- Tariff buttons constraints: yearButton below blackOverlayView, monthButton below yearButton ---
        yearButton.snp.remakeConstraints {
            $0.top.equalTo(blackOverlayView.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(Layout.sideInset)
            $0.height.equalTo(Layout.buttonHeight)
        }
        monthButton.snp.remakeConstraints {
            $0.top.equalTo(yearButton.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(Layout.sideInset)
            $0.height.equalTo(Layout.buttonHeight)
        }

        monthTitleLabel.textAlignment = .left
        monthButton.addSubview(monthTitleLabel)
        monthTitleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.centerY.equalToSuperview()
        }

        yearTitleLabel.textAlignment = .left
        yearButton.addSubview(yearTitleLabel)
        yearTitleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.centerY.equalToSuperview().offset(-10)
        }

        discountBadge.text = "SAVE 80%"
        discountBadge.font = Fonts.font(size: 14, weight: .medium)
        discountBadge.textColor = .black
        discountBadge.backgroundColor = Colors.orange
        discountBadge.textAlignment = .center
        discountBadge.layer.cornerRadius = 12
        discountBadge.clipsToBounds = true
        yearButton.addSubview(discountBadge)
        discountBadge.snp.makeConstraints {
            $0.centerY.equalToSuperview().offset(-10)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(25)
            $0.width.greaterThanOrEqualTo(85)
        }

        yearPriceLabel.font = Fonts.font(size: 14, weight: .regular)
        yearPriceLabel.textColor = .black
        yearButton.addSubview(yearPriceLabel)
        yearPriceLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.centerY.equalToSuperview().offset(12)
        }

        // --- Ensure contentView's bottom is below the last button for scrolling ---
        contentView.snp.makeConstraints {
            $0.bottom.equalTo(monthButton).offset(32)
        }

        // cancelInfoLabel and cancelIcon
        let cancelInfoLabel = UILabel()
        cancelInfoLabel.font = Fonts.font(size: 12, weight: .regular)
        cancelInfoLabel.textColor = Colors.gray
        cancelInfoLabel.textAlignment = .center
        cancelInfoLabel.text = "Cancel Anytime"

        let cancelIcon = UIImageView(image: UIImage(named: "cancel"))
        view.addSubview(cancelIcon)
        view.addSubview(cancelInfoLabel)
        cancelIcon.snp.makeConstraints {
            $0.trailing.equalTo(cancelInfoLabel.snp.leading).offset(-6)
            $0.centerY.equalTo(cancelInfoLabel)
            $0.width.height.equalTo(12)
        }
        cancelInfoLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview().offset(8)
            $0.bottom.equalTo(continueButton.snp.top).offset(-12)
        }

      

        // privacy, restore, terms buttons
        privacyButton.setTitle("Privacy Policy", for: .normal)
        privacyButton.setTitleColor(Colors.gray, for: .normal)
        privacyButton.titleLabel?.font = Fonts.font(size: 11, weight: .regular)
        privacyButton.addTarget(self, action: #selector(openPrivacy), for: .touchUpInside)
        view.addSubview(privacyButton)

        restoreButton.setTitle("Restore Purchase", for: .normal)
        restoreButton.setTitleColor(Colors.gray, for: .normal)
        restoreButton.titleLabel?.font = Fonts.font(size: 11, weight: .regular)
        restoreButton.addTarget(self, action: #selector(restorePurchases), for: .touchUpInside)
        view.addSubview(restoreButton)

        termsButton.setTitle("Terms of Use", for: .normal)
        termsButton.setTitleColor(Colors.gray, for: .normal)
        termsButton.titleLabel?.font = Fonts.font(size: 11, weight: .regular)
        termsButton.addTarget(self, action: #selector(openTerms), for: .touchUpInside)
        view.addSubview(termsButton)

        let bottomOffset: CGFloat = 4

        privacyButton.snp.remakeConstraints {
            $0.leading.equalToSuperview().inset(Layout.sideInset)
            $0.top.equalTo(continueButton.snp.bottom).offset(bottomOffset)
        }

        restoreButton.snp.remakeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(continueButton.snp.bottom).offset(bottomOffset)
        }

        termsButton.snp.remakeConstraints {
            $0.trailing.equalToSuperview().inset(Layout.sideInset)
            $0.top.equalTo(continueButton.snp.bottom).offset(bottomOffset)
        }

        // Ensure the indicatorBackgroundView is on top of all subviews
        view.bringSubviewToFront(indicatorBackgroundView)
    }

    private func showActivity() {
        indicatorBackgroundView.isHidden = false
        activityIndicator.startAnimating()
    }

    private func hideActivity() {
        activityIndicator.stopAnimating()
        indicatorBackgroundView.isHidden = true
    }

    private func loadProducts() {
        SwiftHelper.apphudHelper.fetchProducts(paywallID: "main") { products in
            self.products = products
            DispatchQueue.main.async {
                self.configureProducts()
            }
        }
    }

    private func configureProducts() {
        let yearProduct = products.first(where: { $0.productId.contains("year") })
        let monthProduct = products.first(where: { $0.productId.contains("week") })

        if let year = yearProduct {
            configureOption(for: year) { option in
                self.yearOption = option
                let priceText = "\(option.symbol)\(option.price.formatted(.number.precision(.fractionLength(2)))) / \(option.unit)"
                yearTitleLabel.attributedText = self.buildTitleText(priceText)
                let weeklyPrice = ((option.price / 52) * pow(10.0, Double(2))).rounded() / pow(10.0, Double(2))
                yearPriceLabel.text = "\(option.symbol)\(weeklyPrice) / week"
            }
        }

        if let month = monthProduct {
            configureOption(for: month) { option in
                self.monthOption = option
                let priceText = "\(option.symbol)\(option.price.formatted(.number.precision(.fractionLength(2)))) / \(option.unit)"
                monthTitleLabel.attributedText = self.buildTitleText(priceText)
            }
        }
    }

    private func configureOption(for product: ApphudProduct, completion: (SubscriptionOption) -> Void) {
        let priceTuple = SwiftHelper.apphudHelper.returnClearPriceAndSymbol(product: product)
        let unit = SwiftHelper.apphudHelper.returnSubscriptionUnit(product: product) ?? ""
        let duration = SwiftHelper.apphudHelper.returnSubscriptionDuration(product: product) ?? 0
        let hasTrial = SwiftHelper.apphudHelper.hasIntroductoryTrial(product: product)
        let trialInfo = SwiftHelper.apphudHelper.returnIntroductoryTrialDuration(product: product)
        let trialValue = trialInfo?.value
        let trialUnit = trialInfo?.unit

        let option = SubscriptionOption(
            product: product,
            price: priceTuple.price,
            symbol: priceTuple.symbol,
            unit: unit,
            duration: duration,
            hasTrial: hasTrial,
            trialValue: trialValue,
            trialUnit: trialUnit
        )
        completion(option)
    }

    private func buildTitleText(_ text: String) -> NSAttributedString {
        return NSAttributedString(string: text, attributes: [
            .font: Fonts.font(size: 17, weight: .regular),
            .foregroundColor: UIColor.black
        ])
    }

    @objc private func yearTapped() { selectPlan(isYear: true) }
   
    @objc private func monthTapped() { selectPlan(isYear: false) }

    private func selectPlan(isYear: Bool) {
        isYearSelected = isYear
        yearButton.setImage(nil, for: .normal)
        monthButton.setImage(nil, for: .normal)
        
        
        discountBadge.isHidden = !isYearSelected
        yearButton.layer.borderColor = isYear ? Colors.orange.cgColor : UIColor(red: 176/255, green: 176/255, blue: 176/255, alpha: 1).cgColor
        monthButton.layer.borderColor = isYear ? UIColor(red: 176/255, green: 176/255, blue: 176/255, alpha: 1).cgColor : Colors.orange.cgColor
        // Update text colors for plan selection
        yearTitleLabel.textColor = isYear ? Colors.orange : Colors.darkGray
        monthTitleLabel.textColor = isYear ? Colors.darkGray : Colors.orange
    }

    @objc private func didTapContinue() {
        let selected = isYearSelected ? yearOption?.product : monthOption?.product
        guard let selected = selected else { return }
        SwiftHelper.apphudHelper.purchaseSubscription(subscription: selected) { success in
            if success {
                self.onClose?()
            }
        }
    }

    @objc private func restorePurchases() {
        showActivity()
        SubscriptionHandler.shared.recoverPurchases { success in
            DispatchQueue.main.async {
                self.hideActivity()
                if success {
                    self.showRestoreSuccessAlert()
                    self.onClose?()
                } else {
                    self.showRestoreFailedAlert()
                }
            }
        }
    }

    private func showRestoreSuccessAlert() {
        let alert = UIAlertController(title: "Success", message: "Your purchases have been restored.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func showRestoreFailedAlert() {
        let alert = UIAlertController(title: "Restore Failed", message: "We could not restore your purchases. Please try again later.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    @objc private func openPrivacy() {
        if let url = URL(string: "https://docs.google.com/document/d/1LSTbzdupf1qxIRNL94Koh9SmlOuQksTYbWLUpwkw7Hg") {
            UIApplication.shared.open(url)
        }
    }

    @objc private func openTerms() {
        if let url = URL(string: "https://docs.google.com/document/d/1Xtnkxyx8WWapcriiYphHr3ZoXao1YOZ2ae-_vIluge8") {
            UIApplication.shared.open(url)
        }
    }

    @objc private func didTapClose() {
        if let onClose = onClose {
            onClose()
        } else {
            dismiss(animated: true)
        }
    }

}
 
