//
//  FoodCell.swift
//  MyPlate
//
//  Created by 𝕄𝕒𝕥𝕧𝕖𝕪 ℙ𝕠𝕣𝕟𝕚𝕪 on 01.07.2025.
//

import UIKit
import SnapKit

final class FoodCell: UICollectionViewCell {

    static let reuseIdentifier = "FoodCell"

    // MARK: - UI Elements

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()

    private let dishImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 12
        iv.layer.masksToBounds = true
        iv.backgroundColor = UIColor(white: 0.95, alpha: 1) // placeholder bg
        return iv
    }()

    private let caloriesLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.font(size: 20, weight: .medium)
        label.textColor = .black
        label.numberOfLines = 1
        return label
    }()

    private let dishNameLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.font(size: 14, weight: .regular)
        label.textColor = Colors.gray
        label.numberOfLines = 2
        return label
    }()

    private let carbsView = NutrientView(iconName: "carbs_small", borderColor: Colors.purple, textColor: Colors.purple)
    private let proteinView = NutrientView(iconName: "protein_small", borderColor: Colors.blue, textColor: Colors.blue)
    private let fatsView = NutrientView(iconName: "fats_small", borderColor: Colors.yellow, textColor: Colors.yellow)

    private let nutrientsStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 12
        sv.distribution = .fillEqually
        return sv
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup UI

    private func setupUI() {
        contentView.backgroundColor = .clear
        contentView.addSubview(containerView)

        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))
        }

        containerView.addSubview(dishImageView)
        dishImageView.snp.makeConstraints {
            $0.top.leading.bottom.equalToSuperview().inset(16)
            $0.width.equalTo(dishImageView.snp.height) // квадрат
        }

        containerView.addSubview(caloriesLabel)
        containerView.addSubview(dishNameLabel)
        containerView.addSubview(nutrientsStack)

        caloriesLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalTo(dishImageView.snp.trailing).offset(16)
            $0.trailing.equalToSuperview().inset(16)
        }

        dishNameLabel.snp.makeConstraints {
            $0.top.equalTo(caloriesLabel.snp.bottom).offset(4)
            $0.leading.equalTo(caloriesLabel.snp.leading)
            $0.trailing.equalTo(caloriesLabel.snp.trailing)
        }

        nutrientsStack.snp.makeConstraints {
            $0.top.equalTo(dishNameLabel.snp.bottom).offset(12)
            $0.leading.equalTo(caloriesLabel.snp.leading)
            $0.trailing.equalTo(caloriesLabel.snp.trailing)
            $0.bottom.lessThanOrEqualToSuperview().inset(16)
            $0.height.equalTo(40)
        }

        nutrientsStack.addArrangedSubview(carbsView)
        nutrientsStack.addArrangedSubview(proteinView)
        nutrientsStack.addArrangedSubview(fatsView)
    }

    // MARK: - Configure

    func configure(calories: Int, dishName: String, image: UIImage?, carbs: Int, protein: Int, fats: Int) {
        caloriesLabel.text = "\(calories) kcal"
        dishNameLabel.text = dishName
        if let image = image {
            dishImageView.image = image
        } else {
            dishImageView.image = nil
            dishImageView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        }
        carbsView.setValue("\(carbs)g")
        proteinView.setValue("\(protein)g")
        fatsView.setValue("\(fats)g")
    }
}

// MARK: - NutrientView

private final class NutrientView: UIView {

    private let iconImageView = UIImageView()
    private let valueLabel = UILabel()

    init(iconName: String, borderColor: UIColor, textColor: UIColor) {
        super.init(frame: .zero)
        setupUI(iconName: iconName, borderColor: borderColor, textColor: textColor)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI(iconName: String, borderColor: UIColor, textColor: UIColor) {
        backgroundColor = .white
        layer.cornerRadius = 8
        layer.borderWidth = 1.5
        layer.borderColor = borderColor.cgColor
        layer.masksToBounds = true

        iconImageView.image = UIImage(named: iconName)
        iconImageView.contentMode = .scaleAspectFit

        valueLabel.font = Fonts.font(size: 14, weight: .regular)
        valueLabel.textColor = textColor
        valueLabel.textAlignment = .center

        addSubview(iconImageView)
        addSubview(valueLabel)

        iconImageView.snp.makeConstraints {
            $0.top.leading.equalToSuperview().inset(6)
            $0.width.height.equalTo(20)
        }

        valueLabel.snp.makeConstraints {
            $0.centerY.equalTo(iconImageView.snp.centerY)
            $0.leading.equalTo(iconImageView.snp.trailing).offset(6)
            $0.trailing.equalToSuperview().inset(6)
        }
    }

    func setValue(_ value: String) {
        valueLabel.text = value
    }
}
