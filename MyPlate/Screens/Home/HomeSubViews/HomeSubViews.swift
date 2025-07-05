//
//  HomeSubViews.swift
//  MyPlate
//
//  Created by 𝕄𝕒𝕥𝕧𝕖𝕪 ℙ𝕠𝕕𝕘𝕠𝕣𝕟𝕚𝕪 on 03.07.2025.
//

import Foundation
import UIKit

final class NutritionDashboardView: UIView {
    
    private let caloriesProgressView = CaloriesProgressView()
    
    private let macrosStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 12
        sv.distribution = .fillEqually
        return sv
    }()
    
    private let carbsView = MacroProgressView(title: "Carbs", color: Colors.purple)
    private let proteinView = MacroProgressView(title: "Proteins", color: Colors.blue)
    private let fatsView = MacroProgressView(title: "Fats", color: Colors.yellow)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        NotificationCenter.default.addObserver(self, selector: #selector(handleMealAdded), name: .mealAdded, object: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        NotificationCenter.default.addObserver(self, selector: #selector(handleMealAdded), name: .mealAdded, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupUI() {
        backgroundColor = .white
        layer.cornerRadius = 20
        clipsToBounds = true
        
        addSubview(caloriesProgressView)
        addSubview(macrosStackView)
        
        macrosStackView.addArrangedSubview(carbsView)
        macrosStackView.addArrangedSubview(proteinView)
        macrosStackView.addArrangedSubview(fatsView)
        
        caloriesProgressView.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview().inset(16)
            make.width.equalTo(caloriesProgressView.snp.height)
        }
        
        macrosStackView.snp.makeConstraints { make in
            make.leading.equalTo(caloriesProgressView.snp.trailing).offset(24)
            make.top.bottom.trailing.equalToSuperview().inset(16)
        }
    }
    
    func update(caloriesLeft: Int, caloriesTotal: Int,
                carbsConsumed: Int, carbsTotal: Int,
                proteinConsumed: Int, proteinTotal: Int,
                fatsConsumed: Int, fatsTotal: Int) {
        
        caloriesProgressView.updateProgress(current: caloriesLeft, total: caloriesTotal)
        carbsView.updateProgress(consumed: carbsConsumed, total: carbsTotal)
        proteinView.updateProgress(consumed: proteinConsumed, total: proteinTotal)
        fatsView.updateProgress(consumed: fatsConsumed, total: fatsTotal)
    }
    
    @objc private func handleMealAdded() {
        // Здесь должен быть вызов update(...) с новыми значениями
        print("⚠️ mealAdded notification received — нужно обновить данные")
    }
}

final class CaloriesProgressView: UIView {
    
    private let progressLayer = CAShapeLayer()
    private let backgroundLayer = CAShapeLayer()
    
    private let caloriesLabel = UILabel()
    private let titleLabel = UILabel()
    
    // MARK: - Store current and total
    private var storedCurrent: Int = 0
    private var storedTotal: Int = 1
    
    private var currentProgress: CGFloat = 0.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
        setupLabels()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayers()
        setupLabels()
    }
    
    private func setupLayers() {
        backgroundColor = .clear
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = min(bounds.width, bounds.height) / 2 * 0.8
        let startAngle = CGFloat.pi * 0.75
        let endAngle = CGFloat.pi * 2.25
        
        let backgroundPath = UIBezierPath(arcCenter: center,
                                          radius: radius,
                                          startAngle: startAngle,
                                          endAngle: endAngle,
                                          clockwise: true)
        backgroundLayer.path = backgroundPath.cgPath
        backgroundLayer.strokeColor = UIColor(red: 237/255, green: 237/255, blue: 237/255, alpha: 1).cgColor
        backgroundLayer.fillColor = UIColor.clear.cgColor
        backgroundLayer.lineWidth = 10
        backgroundLayer.lineCap = .round
        layer.addSublayer(backgroundLayer)
        
        progressLayer.path = backgroundPath.cgPath
        progressLayer.strokeColor = UIColor.black.cgColor
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineWidth = 10
        progressLayer.lineCap = .round
        progressLayer.strokeEnd = 0
        layer.addSublayer(progressLayer)
    }
    
    override func layoutSubviews() {
        print("CaloriesProgressView.layoutSubviews → bounds: \(bounds)")
        super.layoutSubviews()
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = min(bounds.width, bounds.height) / 2 * 0.8
        let startAngle = CGFloat.pi * 0.75
        let endAngle = CGFloat.pi * 2.25
        
        let path = UIBezierPath(arcCenter: center,
                                radius: radius,
                                startAngle: startAngle,
                                endAngle: endAngle,
                                clockwise: true)
        
        backgroundLayer.path = path.cgPath
        progressLayer.path = path.cgPath
        
        // Update progressLayer.strokeEnd based on "consumed" progress
        let consumed = storedTotal - storedCurrent
        let progress = CGFloat(consumed) / CGFloat(max(storedTotal, 1))
        progressLayer.strokeEnd = progress
    }
    
    private func setupLabels() {
        caloriesLabel.font = Fonts.font(size: 32, weight: .bold)
        caloriesLabel.textColor = .black
        caloriesLabel.textAlignment = .center
        caloriesLabel.text = "0"
        
        titleLabel.font = Fonts.font(size: 14, weight: .regular)
        titleLabel.textColor = Colors.gray
        titleLabel.textAlignment = .center
        titleLabel.text = "Calories Left"
        
        addSubview(caloriesLabel)
        addSubview(titleLabel)
        
        caloriesLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-10)
        }
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(caloriesLabel.snp.bottom).offset(4)
        }
    }
    
    func updateProgress(current: Int, total: Int) {
        storedCurrent = current
        storedTotal = total
        caloriesLabel.text = "\(current)"
        setNeedsLayout()
    }
}

final class MacroProgressView: UIView {
    
    private let titleLabel = UILabel()
    private let progressBar = UIProgressView(progressViewStyle: .default)
    private let valuesLabel = UILabel()
    
    private let progressColor: UIColor
    
    init(title: String, color: UIColor) {
        progressColor = color
        super.init(frame: .zero)
        setupUI(title: title)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI(title: String) {
        addSubview(titleLabel)
        addSubview(progressBar)
        addSubview(valuesLabel)
        
        titleLabel.text = title
        titleLabel.font = Fonts.font(size: 14, weight: .regular)
        titleLabel.textColor = .black
        
        progressBar.progressTintColor = progressColor
        progressBar.trackTintColor = UIColor(red: 237/255, green: 237/255, blue: 237/255, alpha: 1)
        
        valuesLabel.font = Fonts.font(size: 12, weight: .regular)
        valuesLabel.textColor = Colors.gray
        valuesLabel.textAlignment = .right
        
        titleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        progressBar.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.height.equalTo(8)
        }
        valuesLabel.snp.makeConstraints { make in
            make.top.equalTo(progressBar.snp.bottom).offset(4)
            make.leading.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    func updateProgress(consumed: Int, total: Int) {
        let progress = Float(max(min(consumed, total), 0)) / Float(max(total, 1))
        progressBar.progress = progress
        valuesLabel.text = "\(consumed) / \(total) g"
    }
}

