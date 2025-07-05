//
//  MealInfoCell.swift
//  MyPlate
//
//  Created by 𝕄𝕒𝕥𝕧𝕖𝕪 ℙ𝕠𝕕𝕘𝕠𝕣𝕟𝕚𝕪 on 03.07.2025.
//

import Foundation
import UIKit

final class MealInfoCell: UICollectionViewCell {
    static let identifier = "MealInfoCell"

    private var carbsLabel: UILabel!
    private var proteinsLabel: UILabel!
    private var fatsLabel: UILabel!
    private var portionCount: Int = 1 {
        didSet {
            portionLabel.text = "\(portionCount)"
            updatePortionButtonStates()
            onPortionChange?(portionCount)
        }
    }
    var onPortionChange: ((Int) -> Void)?

    private func updatePortionButtonStates() {
        minusButton.setTitleColor(portionCount > 1 ? .black : UIColor.lightGray, for: .normal)
        plusButton.setTitleColor(.black, for: .normal)
    }

    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 16
        return iv
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Name"
        label.font = Fonts.font(size: 16, weight: .medium)
        return label
    }()

    private let nameField: UILabel = {
        let label = UILabel()
        label.font = Fonts.font(size: 16, weight: .regular)
        label.textColor = .black
        label.textAlignment = .left
        return label
    }()

    private let caloriesLabel: UILabel = {
        let label = UILabel()
        label.text = "Calories"
        label.font = Fonts.font(size: 16, weight: .medium)
        return label
    }()

    private let caloriesField: UILabel = {
        let label = UILabel()
        label.font = Fonts.font(size: 16, weight: .regular)
        label.textColor = .black
        label.textAlignment = .left
        return label
    }()

    private let portionTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Portion"
        label.font = Fonts.font(size: 16, weight: .medium)
        label.textAlignment = .left
        return label
    }()

    private let minusButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("–", for: .normal)
        button.titleLabel?.font = Fonts.font(size: 24, weight: .regular)
        return button
    }()

    private let plusButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("+", for: .normal)
        button.titleLabel?.font = Fonts.font(size: 24, weight: .regular)
        return button
    }()

    private let portionLabel: UILabel = {
        let label = UILabel()
        label.text = "1"
        label.textAlignment = .center
        label.font = Fonts.font(size: 14, weight: .regular)
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = Colors.background
        backgroundColor = Colors.background
        setupLayout()
        setupActions()
        updatePortionButtonStates()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupActions() {
        minusButton.addTarget(self, action: #selector(decreasePortion), for: .touchUpInside)
        plusButton.addTarget(self, action: #selector(increasePortion), for: .touchUpInside)
    }

    @objc private func decreasePortion() {
        if portionCount > 1 {
            portionCount -= 1
        }
    }

    @objc private func increasePortion() {
        portionCount += 1
    }

    private func fieldContainer(with view: UIView) -> UIView {
        let container = UIView()
        container.backgroundColor = .white
        container.layer.cornerRadius = 16
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor(red: 237/255, green: 237/255, blue: 237/255, alpha: 1).cgColor
        container.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            view.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            view.topAnchor.constraint(equalTo: container.topAnchor, constant: 10),
            view.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -10),
            container.heightAnchor.constraint(equalToConstant: 48)
        ])
        return container
    }

    func configure(image: UIImage, meal: Meal) {
        imageView.image = image
        nameField.text = meal.total.title
        caloriesField.text = "\(Int(meal.totalCalories()))"
        carbsLabel.text = "\(meal.total.carbohydratesPer100g) g"
        proteinsLabel.text = "\(meal.total.proteinsPer100g) g"
        fatsLabel.text = "\(meal.total.fatsPer100g) g"
    }

    private func setupLayout() {
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.top.equalTo(contentView.safeAreaLayoutGuide.snp.top).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(200)
        }

        let nameContainer = fieldContainer(with: nameField)
        contentView.addSubview(nameLabel)
        contentView.addSubview(nameContainer)
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(12)
            make.leading.equalToSuperview().inset(16)
            make.height.equalTo(20)
        }
        nameContainer.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(2)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(48)
        }

        let caloriesContainer = fieldContainer(with: caloriesField)
        contentView.addSubview(caloriesLabel)
        contentView.addSubview(caloriesContainer)
        caloriesLabel.snp.makeConstraints { make in
            make.top.equalTo(nameContainer.snp.bottom).offset(16)
            make.leading.equalToSuperview().inset(16)
            make.height.equalTo(20)
        }
        caloriesContainer.snp.makeConstraints { make in
            make.top.equalTo(caloriesLabel.snp.bottom).offset(4)
            make.leading.equalToSuperview().inset(16)
            make.width.equalTo(contentView.snp.width).multipliedBy(0.45)
            make.height.equalTo(48)
        }

        // Portion controls container
        let portionControls = UIStackView(arrangedSubviews: [minusButton, portionLabel, plusButton])
        portionControls.axis = .horizontal
        portionControls.distribution = .equalSpacing
        let portionContainer = fieldContainer(with: portionControls)
        contentView.addSubview(portionTitleLabel)
        contentView.addSubview(portionContainer)
        portionTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(nameContainer.snp.bottom).offset(16)
            make.leading.equalTo(caloriesContainer.snp.trailing).offset(12)
            make.height.equalTo(20)
        }
        portionContainer.snp.makeConstraints { make in
            make.top.equalTo(portionTitleLabel.snp.bottom).offset(4)
            make.leading.equalTo(caloriesContainer.snp.trailing).offset(12)
            make.trailing.equalToSuperview().inset(16)
            make.height.equalTo(48)
        }

        // Nutrient stacks
        func nutrientView(title: String, iconName: String) -> (UIStackView, UILabel) {
            let titleLabel = UILabel()
            titleLabel.text = title
            titleLabel.font = Fonts.font(size: 16, weight: .medium)

            let valueLabel = UILabel()
            valueLabel.font = Fonts.font(size: 16, weight: .regular)
            valueLabel.textColor = .black
            valueLabel.textAlignment = .left

            let icon = UIImageView(image: UIImage(named: iconName))
            icon.contentMode = .scaleAspectFit
            icon.snp.makeConstraints { make in
                make.width.height.equalTo(20)
            }

            let spacer = UIView()
            spacer.snp.makeConstraints { make in
                make.width.equalTo(8)
            }

            let hStack = UIStackView(arrangedSubviews: [icon, spacer, valueLabel])
            hStack.axis = .horizontal
            hStack.spacing = 4
            hStack.alignment = .center

            let container = fieldContainer(with: hStack)

            let vStack = UIStackView(arrangedSubviews: [titleLabel, container])
            vStack.axis = .vertical
            vStack.spacing = 4

            return (vStack, valueLabel)
        }

        let (carbsStack, carbsLabel) = nutrientView(title: "Carbs", iconName: "carbs_colors")
        self.carbsLabel = carbsLabel
        let (proteinsStack, proteinsLabel) = nutrientView(title: "Protein", iconName: "protein_colors")
        self.proteinsLabel = proteinsLabel
        let (fatsStack, fatsLabel) = nutrientView(title: "Fats", iconName: "fats_colors")
        self.fatsLabel = fatsLabel

        contentView.addSubview(carbsStack)
        contentView.addSubview(proteinsStack)
        contentView.addSubview(fatsStack)

        carbsStack.snp.makeConstraints { make in
            make.top.equalTo(caloriesContainer.snp.bottom).offset(16)
            make.leading.equalToSuperview().inset(16)
            make.trailing.equalToSuperview().inset(16)
            make.height.equalTo(72)
        }
        proteinsStack.snp.makeConstraints { make in
            make.top.equalTo(carbsStack.snp.bottom).offset(12)
            make.leading.equalToSuperview().inset(16)
            make.width.equalTo(contentView.snp.width).multipliedBy(0.45)
            make.height.equalTo(72)
        }
        fatsStack.snp.makeConstraints { make in
            make.top.equalTo(carbsStack.snp.bottom).offset(12)
            make.trailing.equalToSuperview().inset(16)
            make.width.equalTo(contentView.snp.width).multipliedBy(0.45)
            make.height.equalTo(72)
        }

        fatsStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16).isActive = true
    }
}
