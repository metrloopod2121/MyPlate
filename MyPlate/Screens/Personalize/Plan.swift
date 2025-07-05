//
//  Plan.swift
//  MyPlate
//
//  Created by 𝕄𝕒𝕥𝕧𝕖𝕪 ℙ𝕠𝕕𝕘𝕠𝕣𝕟𝕚𝕪 on 01.07.2025.
//

import Foundation
import UIKit
import SnapKit

final class PlanSummaryViewController: UIViewController {

    private let titleLabel = UILabel()
    private let captionLabel = UILabel()

    private let caloriesContainer = UIView()
    private let caloriesTitleLabel = UILabel()
    private let caloriesValueLabel = UILabel()

    private let dateTitleLabel = UILabel()
    private let dateValueLabel = UILabel()
    private let dateContainer = UIView()
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private let macrosStack = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.background
        setupUI()
        populateData()
    }

    private func setupUI() {
        titleLabel.text = "Your plan is ready!"
        titleLabel.font = Fonts.font(size: 32, weight: .bold)
        titleLabel.textColor = .black
        titleLabel.numberOfLines = 0

        captionLabel.text = "We've considered your goals, eating preferences, and daily habits."
        captionLabel.font = Fonts.font(size: 16, weight: .regular)
        captionLabel.textColor = Colors.gray
        captionLabel.numberOfLines = 0

        // --- Calories container setup ---
        caloriesContainer.backgroundColor = .white
        caloriesContainer.layer.cornerRadius = 16

        caloriesTitleLabel.text = "Calories"
        caloriesTitleLabel.font = Fonts.font(size: 14, weight: .regular)
        caloriesTitleLabel.textColor = Colors.gray

        caloriesValueLabel.font = Fonts.font(size: 16, weight: .medium)
        caloriesValueLabel.textColor = .black

        caloriesContainer.addSubview(caloriesTitleLabel)
        caloriesContainer.addSubview(caloriesValueLabel)

        caloriesTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
        }

        caloriesValueLabel.snp.makeConstraints {
            $0.top.equalTo(caloriesTitleLabel.snp.bottom).offset(4)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(16)
        }
        // --- End calories container setup ---

        dateTitleLabel.text = "Estimated result date"
        dateTitleLabel.font = Fonts.font(size: 14, weight: .medium)
        dateTitleLabel.textColor = Colors.gray

        dateValueLabel.font = Fonts.font(size: 16, weight: .medium)
        dateValueLabel.textColor = .black

        dateContainer.backgroundColor = .white
        dateContainer.layer.cornerRadius = 16
        dateContainer.addSubview(dateTitleLabel)
        dateContainer.addSubview(dateValueLabel)

        dateTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(16)
            $0.leading.equalToSuperview().inset(16)
        }

        dateValueLabel.snp.makeConstraints {
            $0.top.equalTo(dateTitleLabel.snp.bottom).offset(4)
            $0.bottom.equalToSuperview().inset(16)
            $0.leading.equalToSuperview().inset(16)
        }

        scrollView.showsHorizontalScrollIndicator = false
        scrollView.alwaysBounceHorizontal = true
        scrollView.alwaysBounceVertical = false
        scrollView.bounces = true

        stackView.axis = .horizontal
        stackView.spacing = 16
        stackView.alignment = .fill
        scrollView.addSubview(stackView)

        view.addSubview(titleLabel)
        view.addSubview(captionLabel)
        view.addSubview(dateContainer)
        view.addSubview(scrollView)
        view.addSubview(caloriesContainer)
        view.addSubview(macrosStack)

        macrosStack.axis = .horizontal
        macrosStack.spacing = 12
        macrosStack.distribution = .fillEqually

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(32)
            $0.leading.trailing.equalToSuperview().inset(16)
        }

        captionLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        
        dateContainer.snp.makeConstraints {
            $0.top.equalTo(captionLabel.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(16)
        }

        scrollView.snp.makeConstraints {
            $0.top.equalTo(dateContainer.snp.bottom).offset(48)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(75) // фиксированная высота для скролла
        }

        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
            $0.height.equalToSuperview()
        }

        caloriesContainer.snp.makeConstraints {
            $0.top.equalTo(scrollView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.greaterThanOrEqualTo(80)
        }
        
        macrosStack.snp.makeConstraints {
            $0.top.equalTo(caloriesContainer.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(98)
        }
    }

    private func populateData() {
        guard let profile = DataFlow().loadUserProfileFromFile(),
              let plan = try? NutritionCalculator.calculate(for: profile) else { return }

        caloriesValueLabel.text = "\(plan.calories) kcal"

        if profile.goal != .maintain {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMMM d, yyyy"
            if let goalDate = plan.estimatedGoalDate {
                dateValueLabel.text = dateFormatter.string(from: goalDate)
            } else {
                dateValueLabel.text = "–"
            }
            dateContainer.isHidden = false

            scrollView.snp.remakeConstraints {
                $0.top.equalTo(dateContainer.snp.bottom).offset(8)
                $0.leading.trailing.equalToSuperview()
                $0.height.equalTo(75)
            }
        } else {
            dateContainer.isHidden = true
            scrollView.snp.remakeConstraints {
                $0.top.equalTo(captionLabel.snp.bottom).offset(24)
                $0.leading.trailing.equalToSuperview()
                $0.height.equalTo(75)
            }
        }

        var heightText: String
        switch profile.inputHeightUnit {
        case .cm:
            heightText = "\(Int(profile.heightCm)) cm"
        case .ft_in:
            let totalInches = profile.heightCm / 2.54
            let feet = Int(totalInches / 12)
            let inches = Int(totalInches.truncatingRemainder(dividingBy: 12))
            heightText = "\(feet)′ \(inches)″"
        }

        var weightText: String
        switch profile.inputWeightUnit {
        case .kg:
            weightText = "\(Int(profile.currentWeightKg)) kg"
        case .lbs:
            let lbs = profile.currentWeightKg / 0.453592
            weightText = "\(Int(lbs)) lbs"
        }

        var targetText: String
        switch profile.inputWeightUnit {
        case .kg:
            targetText = "\(Int(profile.targetWeightKg)) kg"
        case .lbs:
            let lbs = profile.targetWeightKg / 0.453592
            targetText = "\(Int(lbs)) lbs"
        }

        let items: [(String, String)] = [
            ("Age", "\(profile.age) years"),
            ("Height", heightText),
            ("Weight", weightText),
            ("Target", targetText),
            ("Goal", "\(profile.goal)".capitalized),
            ("Diet", "\(profile.dietType)".capitalized),
            ("Activity", "\(profile.activityLevel)".capitalized)
        ]

        for (label, value) in items {
            let card = buildCard(title: label, value: value)
            stackView.addArrangedSubview(card)
        }

        macrosStack.addArrangedSubview(buildMacroCard(icon: "carbs", title: "Carbs", value: "\(plan.carbGrams)g", color: Colors.purple))
        macrosStack.addArrangedSubview(buildMacroCard(icon: "protein", title: "Protein", value: "\(plan.proteinGrams)g", color: Colors.blue))
        macrosStack.addArrangedSubview(buildMacroCard(icon: "fats", title: "Fats", value: "\(plan.fatGrams)g", color: Colors.yellow))
    }

    private func buildCard(title: String, value: String) -> UIView {
        let container = UIView()
        container.backgroundColor = .white
        container.layer.cornerRadius = 16
        container.snp.makeConstraints { $0.width.equalTo(140) }

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = Fonts.font(size: 14, weight: .medium)
        titleLabel.textColor = Colors.gray

        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = Fonts.font(size: 16, weight: .medium)
        valueLabel.textColor = .black

        container.addSubview(titleLabel)
        container.addSubview(valueLabel)

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(12)
            $0.leading.trailing.equalToSuperview().inset(12)
        }

        valueLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.leading.trailing.equalToSuperview().inset(12)
            $0.bottom.equalToSuperview().inset(12)
        }

        return container
    }

    private func buildMacroCard(icon: String, title: String, value: String, color: UIColor) -> UIView {
        let container = UIView()
        container.backgroundColor = color
        container.layer.cornerRadius = 16

        let imageView = UIImageView(image: UIImage(named: icon))
        imageView.contentMode = .scaleAspectFit

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = Fonts.font(size: 15, weight: .regular)
        titleLabel.textColor = .white

        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = Fonts.font(size: 16, weight: .regular)
        valueLabel.textColor = .white

        container.addSubview(imageView)
        container.addSubview(titleLabel)
        container.addSubview(valueLabel)

        imageView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(10)
            $0.leading.equalToSuperview().inset(12)
            $0.width.height.equalTo(24)
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(6)
            $0.leading.equalToSuperview().inset(12)
        }

        valueLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(6)
            $0.leading.equalToSuperview().inset(12)
            $0.bottom.lessThanOrEqualToSuperview().inset(10)
        }

        return container
    }
}
