//
//  IngridientsCellView.swift
//  MyPlate
//
//  Created by 𝕄𝕒𝕥𝕧𝕖𝕪 ℙ𝕠𝕕𝕘𝕠𝕣𝕟𝕚𝕪 on 03.07.2025.
//


import UIKit
import SnapKit

final class IngredientCell: UICollectionViewCell {
    
    static let identifier = "IngredientCell"
    
    // MARK: - UI Elements
    
    private let backgroundContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.font(size: 16, weight: .medium)
        label.textColor = .black
        return label
    }()
    
    private let caloriesLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.font(size: 14, weight: .regular)
        label.textColor = UIColor.gray
        return label
    }()
    
    private let proteinsView = IngridientNutrientView(color: Colors.blue, iconName: "protein_colors")
    private let fatsView = IngridientNutrientView(color: Colors.yellow, iconName: "fats_colors")
    private let carbsView = IngridientNutrientView(color: Colors.purple, iconName: "carbs_colors")
    
    private let nutrientsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        return stackView
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = .clear
        
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout Setup
    
    private func setupLayout() {
        contentView.addSubview(backgroundContainer)
        backgroundContainer.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-8)
        }

        backgroundContainer.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview().offset(16)
            make.trailing.lessThanOrEqualToSuperview().offset(-16)
            make.height.equalTo(20)
        }

        backgroundContainer.addSubview(caloriesLabel)
        caloriesLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(16)
            make.trailing.lessThanOrEqualToSuperview().offset(-16)
            make.height.equalTo(20)
        }
        
        backgroundContainer.addSubview(nutrientsStackView)
        nutrientsStackView.snp.makeConstraints { make in
            make.top.equalTo(caloriesLabel.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(40)
        }
        
        nutrientsStackView.addArrangedSubview(carbsView)
        nutrientsStackView.addArrangedSubview(proteinsView)
        nutrientsStackView.addArrangedSubview(fatsView)
    }
    
    // MARK: - Configure
    
    func configure(title: String, weight: Int, calories: Int, carbs: Double, protein: Double, fat: Double) {
        print("Ingredient configure: \(title), calories: \(calories)") // debug print
        titleLabel.text = "\(title) - \(weight)g"
        caloriesLabel.text = "\(calories) kcal"
        carbsView.setAmount(carbs)
        proteinsView.setAmount(protein)
        fatsView.setAmount(fat)
    }
}

// MARK: - Helper view for nutrient info

final class IngridientNutrientView: UIView {
    private let iconImageView = UIImageView()
    private let amountLabel = UILabel()
    
    init(color: UIColor, iconName: String) {
        super.init(frame: .zero)
        
        layer.cornerRadius = 12
        layer.borderWidth = 1
        layer.borderColor = color.cgColor
        backgroundColor = .white

        // Remove setting fixed size on self, handled in parent
        // snp.makeConstraints { make in
        //     make.width.equalTo(53)
        //     make.height.equalTo(25)
        // }
        
        iconImageView.image = UIImage(named: iconName)
        iconImageView.contentMode = .scaleAspectFit
        // Set hugging and compression resistance priorities for iconImageView
        iconImageView.setContentHuggingPriority(.required, for: .horizontal)
        iconImageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        amountLabel.font = Fonts.font(size: 12, weight: .regular)
        amountLabel.textColor = color
        amountLabel.numberOfLines = 1
        amountLabel.lineBreakMode = .byTruncatingTail
        amountLabel.adjustsFontSizeToFitWidth = true
        amountLabel.minimumScaleFactor = 0.7
        // Set hugging and compression resistance priorities for amountLabel
        amountLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        amountLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        addSubview(iconImageView)
        addSubview(amountLabel)
        
        iconImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(8)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(16)
        }
        
        amountLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconImageView.snp.trailing).offset(12)
            make.centerY.equalToSuperview()
            make.trailing.lessThanOrEqualToSuperview().offset(-12)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setAmount(_ amount: Double) {
        if amount > 1 {
            amountLabel.text = String(format: "%.0f g", amount)
        } else {
            amountLabel.text = String(format: "%.1f g", amount)
        }
    }
}
