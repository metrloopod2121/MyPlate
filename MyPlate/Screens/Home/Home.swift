//
//  Home.swift
//  MyPlate
//
//  Created by 𝕄𝕒𝕥𝕧𝕖𝕪 ℙ𝕠𝕕𝕘𝕠𝕣𝕟𝕚𝕪 on 01.07.2025.
//

import Foundation
import UIKit
import SnapKit

final class HomeViewController: UIViewController {
    
    private let nutritionDashboard = NutritionDashboardView()
    private let dataFlow = DataFlow()
    private var userProfile: UserProfile?
    
    // MARK: - UI Elements
    
    private let weekStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 12
        sv.distribution = .fillEqually
        return sv
    }()
    
    private var dayViews: [DayView] = []
    
    private var selectedDayIndex: Int = 0 {
        didSet {
            updateDaySelection()
            print("Selected day index: \(selectedDayIndex)")
            updateForSelectedDay()
            mealsCollectionView.reloadData()
        }
    }

    private var selectedDates: [Date] = []
    private var userHistory: [UserHistory] = []
    
    private let todayLabel: UILabel = {
        let label = UILabel()
        label.text = "Today"
        label.font = Fonts.font(size: 34, weight: .bold)
        label.textColor = .black
        return label
    }()
    
    private let streakContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 18
        return view
    }()
    
    private let streakIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "star"))
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private let streakCountLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.font(size: 14, weight: .regular)
        label.textColor = .black
        label.text = "0"
        return label
    }()
    
    private let calendarButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        button.setImage(UIImage(named: "cal_icon"), for: .normal)
        button.tintColor = .black
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4) // чтобы иконка стала 24x24
        return button
    }()

    private let userButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        button.setImage(UIImage(named: "user_icon"), for: .normal)
        button.tintColor = .black
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        return button
    }()
    
    private var mealsCollectionView: UICollectionView!
    
    private let historyLabel: UILabel = {
        let label = UILabel()
        label.text = "History"
        label.font = Fonts.font(size: 24, weight: .medium)
        label.textColor = .black
        return label
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.background
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 24, right: 16)
        mealsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        mealsCollectionView.backgroundColor = Colors.background
        mealsCollectionView.register(MealHistoryCell.self, forCellWithReuseIdentifier: "MealHistoryCell")
        mealsCollectionView.dataSource = self
        mealsCollectionView.delegate = self

        // Add calendar button target
        calendarButton.addTarget(self, action: #selector(calendarButtonTapped), for: .touchUpInside)
        userButton.addTarget(self, action: #selector(userButtonTapped), for: .touchUpInside)
        
        // Notification for mealAdded
        NotificationCenter.default.addObserver(self, selector: #selector(handleMealAdded(_:)), name: .mealAdded, object: nil)

        setupUI()
        setupWeekView()
        if let loadedProfile = dataFlow.loadUserProfileFromFile() {
            userProfile = loadedProfile
        } else {
            let defaultProfile = UserProfile(
                gender: .male,
                age: 25,
                heightCm: 180,
                startWeight: 80,
                currentWeightKg: 80,
                targetWeightKg: 75,
                weightStat: [Date(): 80],
                goal: .loseWeight,
                dietType: .balanced,
                activityLevel: .moderate,
                inputHeightUnit: .cm,
                inputWeightUnit: .kg
            )
            dataFlow.saveUserProfileToFile(profile: defaultProfile)
            userProfile = defaultProfile
        }
        if let loadedHistory = DataFlow().loadHistoryArrFromFile() {
            userHistory = loadedHistory
        }
        updateForSelectedDay()
        mealsCollectionView.reloadData()
        updateStreakCount()

        // Add tap gesture to streakContainer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(streakTapped))
        streakContainer.isUserInteractionEnabled = true
        streakContainer.addGestureRecognizer(tapGesture)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
// MARK: - Notification Handling

@objc private func handleMealAdded(_ notification: Notification) {
    guard let meal = notification.object as? Meal else { return }
    let today = Date()
    addMeal(meal, for: today)
    updateForSelectedDay()
    mealsCollectionView.reloadData()
}
    
    @objc private func userButtonTapped() {
           let accountVC = AccountSettingsViewController()
           // Если вы используете UINavigationController:
           navigationController?.pushViewController(accountVC, animated: true)
           // Или, если хотите модально:
           // present(accountVC, animated: true)
       }
    
    @objc private func streakTapped() {
        let trackingVC = TrackingViewController()
        if let nav = self.navigationController {
            nav.pushViewController(trackingVC, animated: true)
        } else {
            present(trackingVC, animated: true)
        }
    }

    
    @objc private func calendarButtonTapped() {
        let calendarVC = CalendarViewController()
        calendarVC.onDateSelected = { [weak self] selectedDate in
            guard let self = self else { return }
            if let index = self.selectedDates.firstIndex(where: { Calendar.current.isDate($0, inSameDayAs: selectedDate) }) {
                self.selectedDayIndex = index
            } else {
                self.selectedDates.append(selectedDate)
                self.selectedDayIndex = self.selectedDates.count - 1
            }
            self.updateForSelectedDay()
            self.mealsCollectionView.reloadData()
            self.dismiss(animated: true)
        }
        navigationController?.pushViewController(calendarVC, animated: true)
    }

    
    // MARK: - Setup
    
    private func setupWeekView() {
        // Очистка массивов перед заполнением
        dayViews.removeAll()
        selectedDates.removeAll()
        // Удаляем все subviews из weekStackView, если нужно пересоздать
        weekStackView.arrangedSubviews.forEach { weekStackView.removeArrangedSubview($0); $0.removeFromSuperview() }

        view.addSubview(weekStackView)
        weekStackView.snp.remakeConstraints {
            $0.top.equalTo(todayLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(60)
        }
        
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        
        let today = Date()
        let weekday = calendar.component(.weekday, from: today)
        
        let daysToMonday = (weekday + 7 - calendar.firstWeekday) % 7
        let monday = calendar.date(byAdding: .day, value: -daysToMonday, to: today)!
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = "EEE"
        
        for i in 0..<7 {
            let date = calendar.date(byAdding: .day, value: i, to: monday)!
            let dayName = dateFormatter.string(from: date)
            let dayNumber = calendar.component(.day, from: date)
            let dayView = DayView(dayName: dayName, dayNumber: dayNumber)
            dayView.tag = i
            dayView.addTarget(self, action: #selector(dayTapped(_:)), for: .touchUpInside)
            weekStackView.addArrangedSubview(dayView)
            dayViews.append(dayView)
            selectedDates.append(date)
        }
        
        selectedDayIndex = (weekday + 7 - calendar.firstWeekday) % 7
    }
    
    private func updateDaySelection() {
        for (index, dayView) in dayViews.enumerated() {
            dayView.isSelected = (index == selectedDayIndex)
        }
    }
    
    @objc private func dayTapped(_ sender: DayView) {
        selectedDayIndex = sender.tag
        updateForSelectedDay()
    }
    
    private func updateForSelectedDay() {
        guard let userProfile = userProfile else { return }
        let history = historyForSelectedDay()
        
        let totalCalories = userProfile.totalCalories
        let caloriesLeft = max(totalCalories - history.totalCaloriesFromMeals, 0)
        
        let totalCarbs = userProfile.totalCarbs
        let carbsConsumed = history.totalCarbsFromMeals
        
        let totalProtein = userProfile.totalProtein
        let proteinConsumed = history.totalProteinsFromMeals
        
        let totalFats = userProfile.totalFats
        let fatsConsumed = history.totalFatsFromMeals
        
        nutritionDashboard.update(
            caloriesLeft: caloriesLeft,
            caloriesTotal: totalCalories,
            carbsConsumed: carbsConsumed,
            carbsTotal: totalCarbs,
            proteinConsumed: proteinConsumed,
            proteinTotal: totalProtein,
            fatsConsumed: fatsConsumed,
            fatsTotal: totalFats
        )
        updateStreakCount()
    }

    private func updateStreakCount() {
        let streak = dataFlow.currentWeekStreak(from: userHistory)
        streakCountLabel.text = "\(streak)"
    }
    
    private func historyForSelectedDay() -> UserHistory {
        guard selectedDayIndex < selectedDates.count else {
            return UserHistory(day: Date(), history: [])
        }
        let selectedDate = selectedDates[selectedDayIndex]
        let calendar = Calendar.current
        return userHistory.first(where: {
            calendar.isDate($0.day, inSameDayAs: selectedDate)
        }) ?? UserHistory(day: selectedDate, history: [])
    }
    
    private func setupUI() {
        view.addSubview(todayLabel)
        view.addSubview(streakContainer)
        streakContainer.addSubview(streakIcon)
        streakContainer.addSubview(streakCountLabel)
        view.addSubview(calendarButton)
        view.addSubview(userButton)
        
        todayLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(80)
            $0.leading.equalToSuperview().offset(16)
        }
        
        streakContainer.snp.makeConstraints {
            $0.centerY.equalTo(todayLabel.snp.centerY)
            $0.trailing.equalTo(calendarButton.snp.leading).offset(-8)
            $0.height.equalTo(32)
            $0.width.equalTo(53)
        }
        
        streakIcon.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(8)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(20)
        }
        
        streakCountLabel.snp.makeConstraints {
            $0.leading.equalTo(streakIcon.snp.trailing).offset(8)
            $0.trailing.equalToSuperview().inset(8)
            $0.centerY.equalToSuperview()
        }
        
        calendarButton.snp.makeConstraints {
            $0.centerY.equalTo(todayLabel.snp.centerY)
            $0.trailing.equalTo(userButton.snp.leading).offset(-8)
            $0.width.height.equalTo(32)
        }
        
        userButton.snp.makeConstraints {
            $0.centerY.equalTo(todayLabel.snp.centerY)
            $0.trailing.equalToSuperview().inset(16)
            $0.width.height.equalTo(32)
        }
        
        view.addSubview(weekStackView)
        weekStackView.snp.remakeConstraints {
            $0.top.equalTo(todayLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(60)
        }
        
        view.addSubview(nutritionDashboard)
        nutritionDashboard.snp.makeConstraints {
            $0.top.equalTo(weekStackView.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(201)
        }

        view.addSubview(historyLabel)
        historyLabel.snp.makeConstraints {
            $0.top.equalTo(nutritionDashboard.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().inset(16)
        }

        view.addSubview(mealsCollectionView)
        mealsCollectionView.snp.makeConstraints {
            $0.top.equalTo(historyLabel.snp.bottom).offset(8)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    // MARK: - Meal Adding
    func addMeal(_ meal: Meal, for day: Date) {
        // Защита от некорректных дат и данных
        guard let _ = Calendar.current.dateComponents([.year, .month, .day], from: day).day else { return }
        // Добавление блюда в историю
        if let index = userHistory.firstIndex(where: { Calendar.current.isDate($0.day, inSameDayAs: day) }) {
            userHistory[index].history.append(meal)
        } else {
            let newUserHistory = UserHistory(day: day, history: [meal])
            userHistory.append(newUserHistory)
        }
        // Сохраняем изменения после модификации
        dataFlow.saveArr(arr: userHistory)
        // Безопасно обновляем коллекцию, если она инициализирована
        if let collectionView = mealsCollectionView {
            collectionView.reloadData()
        }
    }

}

// MARK: - DayView

final class DayView: UIControl {
    
    private let dayNameLabel = UILabel()
    private let dayNumberLabel = UILabel()
    private let selectionBackground = UIView()
    
    override var isSelected: Bool {
        didSet {
            updateSelection()
        }
    }
    
    init(dayName: String, dayNumber: Int) {
        super.init(frame: .zero)
        setupUI(dayName: dayName, dayNumber: dayNumber)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI(dayName: String, dayNumber: Int) {
        addSubview(dayNameLabel)
        addSubview(selectionBackground)
        addSubview(dayNumberLabel)
        
        selectionBackground.backgroundColor = Colors.orange
        selectionBackground.layer.cornerRadius = 12
        selectionBackground.isHidden = true
        
        dayNameLabel.text = dayName
        dayNameLabel.font = Fonts.font(size: 12, weight: .medium)
        dayNameLabel.textColor = Colors.gray
        dayNameLabel.textAlignment = .center
        
        dayNumberLabel.text = "\(dayNumber)"
        dayNumberLabel.font = Fonts.font(size: 20, weight: .regular)
        dayNumberLabel.textColor = Colors.gray
        dayNumberLabel.textAlignment = .center
        
        dayNameLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(4)
            $0.leading.trailing.equalToSuperview()
        }
        
        selectionBackground.snp.makeConstraints {
            $0.centerX.equalTo(dayNumberLabel.snp.centerX)
            $0.centerY.equalTo(dayNumberLabel.snp.centerY)
            $0.width.equalTo(32)
            $0.height.equalTo(32)
        }
        
        dayNumberLabel.snp.makeConstraints {
            $0.top.equalTo(dayNameLabel.snp.bottom).offset(2)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().inset(4)
        }
        
        clipsToBounds = true
        
        updateSelection()
    }
    
    private func updateSelection() {
        selectionBackground.isHidden = !isSelected
        let isToday = Calendar.current.isDateInToday(getDate())
        dayNumberLabel.textColor = isSelected ? .white : (isToday ? .black : Colors.gray)
        dayNumberLabel.font = isSelected ? Fonts.font(size: 20, weight: .regular) : Fonts.font(size: 20, weight: .medium)
        selectionBackground.backgroundColor = isSelected ? (isToday ? Colors.orange : .black) : .clear
    }

    private func getDate() -> Date {
        let calendar = Calendar.current
        let today = Date()
        let weekday = calendar.component(.weekday, from: today)
        let daysToMonday = (weekday + 7 - calendar.firstWeekday) % 7
        let monday = calendar.date(byAdding: .day, value: -daysToMonday, to: today)!
        return calendar.date(byAdding: .day, value: self.tag, to: monday)!
    }
}

extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return historyForSelectedDay().history.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let meal = historyForSelectedDay().history[indexPath.item]
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MealHistoryCell", for: indexPath) as? MealHistoryCell else {
            fatalError("Could not dequeue MealHistoryCell")
        }
        cell.configure(meal: meal)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width - 32
        return CGSize(width: width, height: 120)
    }
}



// MARK: - Notification.Name extension
extension Notification.Name {
    static let mealAdded = Notification.Name("mealAdded")
}
