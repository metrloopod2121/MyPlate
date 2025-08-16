//
//  WeightContorl.swift
//  MyPlate
//
//  Created by 𝕄𝕒𝕥𝕧𝕖𝕪 ℙ𝕠𝕕𝕘𝕠𝕣𝕟𝕚𝕪 on 04.07.2025.
//


import Foundation
import UIKit
import SnapKit
import Charts
import DGCharts

struct User {
    let startWeight: Double
    let currentWeight: Double
    let targetWeight: Double
}

class WeightControlViewController: UIViewController {

    var onFinish: (() -> Void)?

    private let dataFlow = DataFlow()

    // Новый профиль для выбора цели
    private var draftProfile: UserProfile = {
        let df = DataFlow()
        return df.loadUserProfileFromFile() ?? UserProfile(
            gender: .male,
            age: 30,
            heightCm: 180,
            startWeight: 70,
            currentWeightKg: 70,
            targetWeightKg: 70,
            weightStat: [Date(): 70],
            goal: .maintain,
            dietType: .balanced,
            activityLevel: .moderate,
            inputHeightUnit: .cm,
            inputWeightUnit: .kg
        )
    }()

    private var goalAchieved = false

    // MARK: - UI Elements
    private let containerView = UIView()
    private let headerLabel = UILabel()
    private let topLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let progressView = UIProgressView(progressViewStyle: .bar)
    private let leftWeightLabel = UILabel()
    private let rightWeightLabel = UILabel()
    private let addButton = UIButton(type: .system)
    private let weightChartView = LineChartView()
    private let historyLabel = UILabel()
    private var collectionView: UICollectionView!
    private var weightHistory: [(date: Date, weight: Double)] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.background
        setupUI()
        configureData()
    }

    private func setupUI() {
        // Header label
        view.addSubview(headerLabel)
        headerLabel.text = "Weight control"
        headerLabel.font = Fonts.font(size: 34, weight: .bold)
        headerLabel.textAlignment = .left
        headerLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.left.right.equalToSuperview().inset(24)
        }

        // PRO label (show if subscription is absent)
        if !SubscriptionHandler.shared.hasActiveSubscription {
            let proLabelImageView = UIImageView(image: UIImage(named: "pro_label"))
            proLabelImageView.contentMode = .scaleAspectFit
            proLabelImageView.isUserInteractionEnabled = true
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(proLabelTapped))
            proLabelImageView.addGestureRecognizer(tapGesture)
            view.addSubview(proLabelImageView)
            proLabelImageView.snp.makeConstraints { make in
                make.centerY.equalTo(headerLabel)
                make.right.equalToSuperview().inset(24)
                make.width.equalTo(70)
                make.height.equalTo(32)
            }
        }

        // Container view
        view.addSubview(containerView)
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 24
        containerView.layer.masksToBounds = true
        containerView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(headerLabel.snp.bottom).offset(32)
            make.left.right.equalToSuperview().inset(24)
            make.height.equalTo(158)
        }

        // Top label
        containerView.addSubview(topLabel)
        topLabel.font = Fonts.font(size: 20, weight: .medium)
        topLabel.textAlignment = .center
        topLabel.numberOfLines = 1
        topLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.left.right.equalToSuperview().inset(20)
        }

        // Subtitle label
        containerView.addSubview(subtitleLabel)
        subtitleLabel.font = Fonts.font(size: 14, weight: .regular)
        subtitleLabel.textAlignment = .center
        subtitleLabel.textColor = .gray
        subtitleLabel.numberOfLines = 1
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(topLabel.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(20)
        }

        // Progress view
        containerView.addSubview(progressView)
        progressView.trackTintColor = UIColor.systemGray5
        progressView.progressTintColor = UIColor.orange
        progressView.layer.cornerRadius = 4
        progressView.clipsToBounds = true
        progressView.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(18)
            make.left.right.equalToSuperview().inset(24)
            make.height.equalTo(8)
        }

        // Labels for start and target weight
        containerView.addSubview(leftWeightLabel)
        leftWeightLabel.font = UIFont.systemFont(ofSize: 13)
        leftWeightLabel.textAlignment = .left
        leftWeightLabel.textColor = .gray
        leftWeightLabel.snp.makeConstraints { make in
            make.top.equalTo(progressView.snp.bottom).offset(8)
            make.left.equalTo(progressView.snp.left)
        }

        containerView.addSubview(rightWeightLabel)
        rightWeightLabel.font = UIFont.systemFont(ofSize: 13)
        rightWeightLabel.textAlignment = .right
        rightWeightLabel.textColor = .gray
        rightWeightLabel.snp.makeConstraints { make in
            make.top.equalTo(progressView.snp.bottom).offset(8)
            make.right.equalTo(progressView.snp.right)
        }

        // Add Button
        view.addSubview(addButton)
        addButton.backgroundColor = Colors.orange
        addButton.setTitle("Add weighting", for: .normal)
        addButton.setTitleColor(.white, for: .normal)
        let plusImage = UIImage(systemName: "plus")
        addButton.setImage(plusImage, for: .normal)
        addButton.tintColor = .white
        addButton.layer.cornerRadius = 16
        addButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 8)
        addButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: -8)
        addButton.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(24)
            make.height.equalTo(48)
        }

        // Weight Chart View
        view.addSubview(weightChartView)
        weightChartView.snp.makeConstraints { make in
            make.top.equalTo(addButton.snp.bottom).offset(24)
            make.left.right.equalToSuperview().inset(24)
            make.height.equalTo(200)
        }

        // History label
        view.addSubview(historyLabel)
        historyLabel.text = "History"
        historyLabel.font = Fonts.font(size: 18, weight: .medium)
        historyLabel.textAlignment = .left
        historyLabel.snp.makeConstraints { make in
            make.top.equalTo(weightChartView.snp.bottom).offset(24)
            make.left.right.equalToSuperview().inset(24)
        }

        // Collection View
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 8, left: 24, bottom: 16, right: 24)

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = Colors.background
        collectionView.register(WeightHistoryCell.self, forCellWithReuseIdentifier: WeightHistoryCell.reuseIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self

        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(historyLabel.snp.bottom).offset(8)
            make.left.right.bottom.equalToSuperview()
        }

        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
    }

    private func updateUIWithProfile(_ profile: UserProfile) {
        let start = profile.startWeight
        let current = profile.currentWeightKg
        let target = profile.targetWeightKg

        if abs(current - target) < 0.01 && profile.goal == .maintain {
            topLabel.text = "Weight Maintained!"
            subtitleLabel.text = "You're maintaining your weight — great job!"
        } else {
            let lost = abs(start - current).rounded()
            topLabel.text = "You have lost \(Int(lost)) kg!"
            let left = abs(target - current).rounded()
            subtitleLabel.text = "There are only \(Int(left)) kg left to achieve the goal"
        }

        let total = abs(start - target)
        let progress: Float
        if total > 0.01 {
            progress = Float(abs(start - current) / total)
        } else {
            progress = 1.0
        }
        progressView.setProgress(progress, animated: true)

        leftWeightLabel.text = "\(Int(start)) kg"
        rightWeightLabel.text = "\(Int(target)) kg"
    }

    private func configureData() {
        guard let profile = dataFlow.loadUserProfileFromFile() else {
            topLabel.text = "Add your first weighting!"
            subtitleLabel.text = ""
            progressView.setProgress(0, animated: false)
            leftWeightLabel.text = "-"
            rightWeightLabel.text = "-"
            setupWeightChart(with: [:])
            weightHistory = []
            collectionView.reloadData()
            return
        }
        updateUIWithProfile(profile)
        setupWeightChart(with: profile.weightStat)
        weightHistory = profile.weightStat.sorted { $0.key > $1.key }.map { (date: $0.key, weight: $0.value) }
        collectionView.reloadData()
    }

    func setupWeightChart(with weightStat: [Date: Double]) {
        let sortedEntries = weightStat.sorted { $0.key < $1.key }
        if let minDate = sortedEntries.first?.key.timeIntervalSince1970,
           let maxDate = sortedEntries.last?.key.timeIntervalSince1970 {
            weightChartView.xAxis.axisMinimum = minDate - 864
            weightChartView.xAxis.axisMaximum = maxDate + 864
        }
        let dataEntries = sortedEntries.map { (date, weight) -> ChartDataEntry in
            ChartDataEntry(x: date.timeIntervalSince1970, y: weight.rounded())
        }
        let dataSet = LineChartDataSet(entries: dataEntries, label: "Weight over time")
        dataSet.colors = [.black]
        dataSet.circleColors = [.black]
        dataSet.circleRadius = 5
        dataSet.lineWidth = 2
        dataSet.mode = .cubicBezier
        dataSet.drawValuesEnabled = false
        let data = LineChartData(dataSet: dataSet)
        weightChartView.data = data
        weightChartView.xAxis.drawLabelsEnabled = true
        weightChartView.xAxis.labelPosition = .bottom
        weightChartView.xAxis.granularityEnabled = true
        weightChartView.xAxis.granularity = 3600 * 6 // каждые 6 часов
        weightChartView.xAxis.valueFormatter = DateValueFormatter()
        weightChartView.xAxis.drawGridLinesEnabled = false
        let minWeight = weightStat.values.min() ?? 0
        weightChartView.leftAxis.axisMinimum = max(0, minWeight - 10)
        let maxWeight = weightStat.values.max() ?? 100
        weightChartView.leftAxis.axisMaximum = maxWeight + 10
        weightChartView.leftAxis.granularityEnabled = true
        weightChartView.leftAxis.granularity = 5
        weightChartView.leftAxis.labelCount = 6
        weightChartView.leftAxis.valueFormatter = DefaultAxisValueFormatter(decimals: 0)
        weightChartView.rightAxis.enabled = false
        weightChartView.legend.enabled = false
        weightChartView.animate(xAxisDuration: 1.0)
    }
    
    @objc private func proLabelTapped() {
        print("pro")
        let paywall = PaywallViewController()
        let nav = UINavigationController(rootViewController: paywall)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }


    @objc private func addButtonTapped() {
        // Проверка на подписку
        if !SubscriptionHandler.shared.hasActiveSubscription {
            let paywall = PaywallViewController()
            let nav = UINavigationController(rootViewController: paywall)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
            return
        }
        if goalAchieved {
            let currentProfile = dataFlow.loadUserProfileFromFile()
            let personalizeVC = PersonalizeViewController(mode: .short, existingProfile: currentProfile)
            personalizeVC.modalPresentationStyle = .formSheet
            personalizeVC.onFinish = { [weak self] in
                self?.dismiss(animated: true)
                self?.onFinish?()
                self?.configureData()
            }
            self.present(personalizeVC, animated: true)
        } else {
            // Стандартное добавление веса
            guard let window = UIApplication.shared.windows.first(where: \.isKeyWindow) else { return }
            let weightAddVC = WeightAddViewController()
            weightAddVC.delegate = self
            weightAddVC.modalPresentationStyle = .pageSheet
            if let sheet = weightAddVC.sheetPresentationController {
                sheet.detents = [.custom(resolver: { _ in 470 })]
            }
            window.rootViewController?.present(weightAddVC, animated: true)
        }
    }
    
    private func updateWeightStatus(with profile: UserProfile, newWeight: Double, previousWeight: Double) {
        let goal = profile.goal
        let startWeight = profile.startWeight
        let targetWeight = profile.targetWeightKg
        let weightDiff = newWeight - previousWeight
        let totalDiff = abs(startWeight - targetWeight)
        let remaining = abs(targetWeight - newWeight)

        // Проверка достижения цели
        if (goal == .loseWeight && newWeight <= targetWeight) ||
           (goal == .gainWeight && newWeight >= targetWeight) ||
           (goal == .maintain && abs(newWeight - targetWeight) < 0.01) {
            goalAchieved = true
            topLabel.text = "Goal achieved!"
            subtitleLabel.text = "You've \(goal == .loseWeight ? "lost" : goal == .gainWeight ? "gained" : "maintained") \(Int(abs(weightDiff))) kg — amazing result! Your effort paid off. Proud of you!"
            addButton.setTitle("Choose a new goal", for: .normal)
            addButton.setImage(nil, for: .normal)
        } else {
            goalAchieved = false
            addButton.setTitle("Add weighting", for: .normal)
            let plusImage = UIImage(systemName: "plus")
            addButton.setImage(plusImage, for: .normal)
            // Существующая логика для разных целей и веса
            switch goal {
            case .loseWeight:
                if weightDiff < 0 {
                    topLabel.text = "You have lost \(Int(abs(weightDiff))) kg!"
                    subtitleLabel.text = "There are only \(Int(remaining)) kg left to achieve the goal"
                } else if weightDiff > 0 {
                    topLabel.text = "The weight increased by \(Int(weightDiff)) kg!"
                    subtitleLabel.text = "You wanted to lose weight, but you gained \(Int(weightDiff)) kg. Are you following your diet exactly?"
                } else {
                    topLabel.text = "Weight maintained!"
                    subtitleLabel.text = "You're maintaining your weight — great job!"
                }
            case .gainWeight:
                if weightDiff > 0 {
                    topLabel.text = "You have gained \(Int(weightDiff)) kg!"
                    subtitleLabel.text = "There are only \(Int(remaining)) kg left to achieve the goal"
                } else if weightDiff < 0 {
                    topLabel.text = "The weight decreased by \(Int(abs(weightDiff))) kg!"
                    subtitleLabel.text = "You wanted to gain weight, but you lost \(Int(abs(weightDiff))) kg. Are you following your diet exactly?"
                } else {
                    topLabel.text = "Weight maintained!"
                    subtitleLabel.text = "You're maintaining your weight — great job!"
                }
            case .maintain:
                if weightDiff == 0 {
                    topLabel.text = "Weight Maintained!"
                    subtitleLabel.text = "You're maintaining your weight — great job!"
                } else if weightDiff < 0 {
                    topLabel.text = "The weight decreased by \(Int(abs(weightDiff))) kg!"
                    subtitleLabel.text = "You wanted to maintain weight, but you lost \(Int(abs(weightDiff))) kg. Are you following your diet exactly?"
                } else {
                    topLabel.text = "The weight increased by \(Int(weightDiff)) kg!"
                    subtitleLabel.text = "You wanted to maintain weight, but you gained \(Int(weightDiff)) kg. Are you following your diet exactly?"
                }
            }
        }

        // Обновляем цвет графика (если есть)
        let graphColor: UIColor = goalAchieved ? .black : {
            switch goal {
            case .loseWeight:
                return weightDiff > 0 ? .red : .black
            case .gainWeight:
                return weightDiff < 0 ? .red : .black
            case .maintain:
                return weightDiff == 0 ? .black : .red
            }
        }()
        if let lineDataSet = weightChartView.data?.dataSets.first as? LineChartDataSet {
            lineDataSet.setColor(graphColor)
            lineDataSet.circleColors = [graphColor]
        }
        weightChartView.notifyDataSetChanged()

        // Прогресс и метки веса
        let progress: Float
        if totalDiff > 0.01 {
            progress = Float(abs(startWeight - newWeight) / totalDiff)
        } else {
            progress = 1.0
        }
        progressView.setProgress(progress, animated: true)
        leftWeightLabel.text = "\(Int(startWeight)) kg"
        rightWeightLabel.text = "\(Int(targetWeight)) kg"
    }

}

// MARK: - UICollectionViewDataSource & UICollectionViewDelegateFlowLayout
extension WeightControlViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        weightHistory.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WeightHistoryCell.reuseIdentifier, for: indexPath) as? WeightHistoryCell else {
            return UICollectionViewCell()
        }
        let entry = weightHistory[indexPath.item]
        cell.configure(weight: entry.weight, date: entry.date)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width - 48, height: 60)
    }
}

class WeightHistoryCell: UICollectionViewCell {
    static let reuseIdentifier = "WeightHistoryCell"

    private let weightLabel = UILabel()
    private let dateLabel = UILabel()

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

        contentView.addSubview(weightLabel)
        contentView.addSubview(dateLabel)

        weightLabel.font = Fonts.font(size: 20, weight: .medium)
        weightLabel.textColor = .black

        dateLabel.font = Fonts.font(size: 14, weight: .regular)
        dateLabel.textColor = Colors.gray
    }

    private func setupConstraints() {
        weightLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.left.equalToSuperview().offset(16)
        }
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(weightLabel.snp.bottom).offset(4)
            make.left.equalTo(weightLabel)
            make.bottom.equalToSuperview().offset(-8)
        }
    }

    func configure(weight: Double, date: Date) {
        weightLabel.text = "Weight: \(String(format: "%.1f", weight)) kg"
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM dd, yyyy"
        dateLabel.text = formatter.string(from: date)
    }
}

class DateValueFormatter: AxisValueFormatter {
    private let dateFormatter = DateFormatter()

    init() {
        dateFormatter.dateFormat = "MMM dd, HH:mm"
    }

    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let date = Date(timeIntervalSince1970: value)
        return dateFormatter.string(from: date)
    }
}

class MonthValueFormatter: AxisValueFormatter {
    private let dateFormatter = DateFormatter()

    init() {
        dateFormatter.dateFormat = "MMM"
    }

    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let date = Date(timeIntervalSince1970: value)
        return dateFormatter.string(from: date)
    }
}

// MARK: - WeightAddViewControllerDelegate
extension WeightControlViewController: WeightAddViewControllerDelegate {
    func didAddNewWeight(_ weightStat: [Date: Double]) {
        let sortedWeights = weightStat.sorted { $0.key > $1.key }
        weightHistory = sortedWeights.map { (date: $0.key, weight: $0.value) }
        collectionView.reloadData()

        guard var profile = dataFlow.loadUserProfileFromFile() else { return }

        if let latestWeight = sortedWeights.first?.value {
            let previousWeight: Double
            if weightHistory.count > 1 {
                previousWeight = weightHistory[1].weight
            } else {
                previousWeight = profile.currentWeightKg
            }

            profile.currentWeightKg = latestWeight
            dataFlow.saveUserProfileToFile(profile: profile)

            updateWeightStatus(with: profile, newWeight: latestWeight, previousWeight: previousWeight)
            updateUIWithProfile(profile)

            setupWeightChart(with: weightStat)
        }
    }
}


