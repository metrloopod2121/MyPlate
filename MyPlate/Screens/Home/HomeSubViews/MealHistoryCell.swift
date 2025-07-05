//
//  MealHistoryCell.swift
//  MyPlate
//
//  Created by 𝕄𝕒𝕥𝕧𝕖𝕪 ℙ𝕠𝕕𝕘𝕠𝕣𝕟𝕚𝕪 on 04.07.2025.
//

import UIKit
import SnapKit

final class MealHistoryCell: UICollectionViewCell {
    
    static let reuseIdentifier = "MealHistoryCell"
    
    private let mealImageView: UIImageView = {
        let iv = UIImageView()
        iv.layer.cornerRadius = 16
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    private let caloriesLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.font(size: 20, weight: .medium)
        label.textColor = .black
        return label
    }()
    
    private let mealNameLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.font(size: 14, weight: .regular)
        label.textColor = Colors.gray
        label.numberOfLines = 0
        return label
    }()
    
    private let proteinNutrientView = IngridientNutrientView(color: Colors.blue, iconName: "protein_colors")
    private let fatNutrientView = IngridientNutrientView(color: Colors.yellow, iconName: "fats_colors")
    private let carbNutrientView = IngridientNutrientView(color: Colors.purple, iconName: "carbs_colors")
    
    private lazy var macrosStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [proteinNutrientView, fatNutrientView, carbNutrientView])
        stack.axis = .horizontal
        stack.spacing = 12
        stack.distribution = .fillEqually
        return stack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
        setupConstraints()
    }
    
    private func setupViews() {
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true

        contentView.addSubview(mealImageView)
        contentView.addSubview(caloriesLabel)
        contentView.addSubview(mealNameLabel)
        contentView.addSubview(macrosStackView)
    }
    
    private func setupConstraints() {
        mealImageView.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 84, height: 84))
            make.left.top.equalToSuperview().inset(16)
            make.bottom.lessThanOrEqualToSuperview().inset(16)
        }
        
        caloriesLabel.snp.makeConstraints { make in
            make.top.equalTo(mealImageView.snp.top).offset(4)
            make.left.equalTo(mealImageView.snp.right).offset(16)
            make.right.lessThanOrEqualToSuperview().inset(16)
        }
        
        mealNameLabel.snp.makeConstraints { make in
            make.top.equalTo(caloriesLabel.snp.bottom).offset(4)
            make.left.equalTo(mealImageView.snp.right).offset(16)
            make.right.equalToSuperview().inset(16)
        }
        
        macrosStackView.snp.makeConstraints { make in
            make.top.equalTo(mealNameLabel.snp.bottom).offset(12)
            make.left.equalTo(mealImageView.snp.right).offset(16)
            make.right.lessThanOrEqualToSuperview().inset(16)
            make.height.equalTo(25)
            make.bottom.lessThanOrEqualToSuperview().inset(16)
        }
    }
    
    func configure(meal: Meal) {
        mealNameLabel.text = meal.total.title
        caloriesLabel.text = "\(Int(meal.totalCalories())) calories"
        proteinNutrientView.setAmount(meal.total.proteinsPer100g)
        fatNutrientView.setAmount(meal.total.fatsPer100g)
        carbNutrientView.setAmount(meal.total.carbohydratesPer100g)
        if let image = meal.image {
            mealImageView.image = image
        } else {
            mealImageView.image = UIImage(named: "meal_ph")
        }
    }
}

