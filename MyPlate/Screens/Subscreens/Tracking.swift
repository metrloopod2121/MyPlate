//
//  Tracking .swift
//  MyPlate
//
//  Created by 𝕄𝕒𝕥𝕧𝕖𝕪 ℙ𝕠𝕕𝕘𝕠𝕣𝕟𝕚𝕪 on 04.07.2025.
//

import Foundation
import UIKit
import SnapKit

final class TrackingViewController: UIViewController {

    // MARK: - UI Elements

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

    private let trackImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "track"))
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let streakLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.font(size: 28, weight: .bold)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()

    private let dataFlow = DataFlow()

    private let progressDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.font(size: 14, weight: .regular)
        label.textColor = .darkGray
        label.textAlignment = .center
        label.numberOfLines = 2
        label.text = "You're making great progress — stay strong, and every day will bring you one step closer to your goal!"
        return label
    }()

    private let weekContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.layer.cornerRadius = 20
        return view
    }()

    private let daysStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.distribution = .equalSpacing
        sv.alignment = .center
        sv.spacing = 12
        return sv
    }()

    // MARK: - Data

    // Пример стрика — число дней подряд с записями (можно заменить вызовом твоей функции)
    private var streak: Int = 5

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.background
        
        // Установка заголовка навигации
        self.title = "Tracking"
        
        // Настройка кнопки назад с пустым текстом и черным цветом
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        navigationController?.navigationBar.tintColor = .black
        
        let accountButtonItem = UIBarButtonItem(customView: userButton)
        navigationItem.rightBarButtonItem = accountButtonItem
        
        userButton.addTarget(self, action: #selector(userButtonTapped), for: .touchUpInside)
        
        setupUI()
        updateStreak()
        configureWeekDays()
    }

    @objc private func userButtonTapped() {
        print("User button tapped")
        // Добавь здесь логику перехода в профиль
    }

    private func updateStreak() {
        guard let history = dataFlow.loadHistoryArrFromFile() else {
            streakLabel.text = "0 days"
            return
        }

        let currentStreak = dataFlow.currentWeekStreak(from: history)
        streakLabel.text = "\(currentStreak) days"
    }

    // MARK: - Setup

    private func setupUI() {
        // Убрал userButton из view
        // view.addSubview(userButton)

        view.addSubview(trackImageView)
        view.addSubview(streakLabel)
        view.addSubview(progressDescriptionLabel)
        view.addSubview(weekContainerView)

        weekContainerView.addSubview(daysStackView)

        // Layout with SnapKit

        trackImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(64)
            make.centerX.equalToSuperview()
            make.width.equalTo(285)
            make.height.equalTo(247)
        }

        streakLabel.snp.makeConstraints { make in
            make.top.equalTo(trackImageView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        progressDescriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(streakLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(32)
        }

        weekContainerView.snp.makeConstraints { make in
            make.top.equalTo(progressDescriptionLabel.snp.bottom).offset(24)
            make.centerX.equalToSuperview()
            make.height.equalTo(88)
            make.leading.trailing.equalToSuperview().inset(24)
            make.bottom.lessThanOrEqualTo(view.safeAreaLayoutGuide).offset(-16)
        }

        daysStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
        }
    }

    // MARK: - Configuration

    private func configureStreak() {
        streakLabel.text = "\(streak) days"
    }

    private func configureWeekDays() {
        daysStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")

        guard let shortWeekdaySymbols = dateFormatter.shortWeekdaySymbols else {
            return
        }

        // Переупорядочиваем, чтобы понедельник был первым
        let reorderedSymbols = Array(shortWeekdaySymbols[1...6]) + [shortWeekdaySymbols[0]]

        guard let history = dataFlow.loadHistoryArrFromFile() else {
            // Если нет истории, показываем дни без отметок
            for dayName in reorderedSymbols {
                let dayView = createDayView(dayName: dayName, hasRecord: false, isInStreak: false)
                daysStackView.addArrangedSubview(dayView)
            }
            return
        }

        let streakLength = dataFlow.currentWeekStreak(from: history)
        let hasRecordForDays = determineHasRecordForCurrentWeek(history: history)

        for (index, dayName) in reorderedSymbols.enumerated() {
            let isInStreak = hasRecordForDays[index]
            let dayView = createDayView(dayName: dayName, hasRecord: hasRecordForDays[index], isInStreak: isInStreak)
            daysStackView.addArrangedSubview(dayView)
        }
    }

    private func createDayView(dayName: String, hasRecord: Bool, isInStreak: Bool) -> UIView {
        let container = UIView()

        let dayLabel = UILabel()
        dayLabel.text = dayName
        dayLabel.font = Fonts.font(size: 16, weight: .regular)
        dayLabel.textColor = .white
        dayLabel.textAlignment = .center

        let markImageView = UIImageView()
        let markImageName = (hasRecord && isInStreak) ? "mark" : "unmark"
        markImageView.image = UIImage(named: markImageName)
        markImageView.contentMode = .scaleAspectFit

        container.addSubview(dayLabel)
        container.addSubview(markImageView)

        dayLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(18)
        }

        markImageView.snp.makeConstraints { make in
            make.top.equalTo(dayLabel.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(24)
            make.bottom.equalToSuperview()
        }

        return container
    }
}

private extension TrackingViewController {
    func determineHasRecordForCurrentWeek(history: [UserHistory]) -> [Bool] {
        var result = [Bool](repeating: false, count: 7)
        let calendar = Calendar.current
        
        guard
            let monday = Date().startOfWeek()?.startOfDay(calendar: calendar),
            let sunday = Date().endOfWeek()?.startOfDay(calendar: calendar)
        else {
            print("Failed to get start or end of week")
            return result
        }
        
        print("Current week range:", monday, "to", sunday)
        
        for userHistory in history {
            let day = userHistory.day.startOfDay(calendar: calendar)
            print("Checking history day:", day)
            if day >= monday && day <= sunday {
                let weekdayIndex = calendar.component(.weekday, from: day)
                // Сдвигаем так, чтобы понедельник был индексом 0
                let adjustedIndex = (weekdayIndex + 5) % 7
                print("Weekday \(weekdayIndex) adjusted to index \(adjustedIndex)")
                result[adjustedIndex] = userHistory.history.count > 0
            }
        }
        
        print("Has record for days:", result)
        return result
    }
}

private extension Date {
    func startOfDay(calendar: Calendar = Calendar.current) -> Date {
        return calendar.startOfDay(for: self)
    }
    
    func startOfWeek(calendar: Calendar = Calendar.current) -> Date? {
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return calendar.date(from: components)
    }

    func endOfWeek(calendar: Calendar = Calendar.current) -> Date? {
        guard let start = startOfWeek(calendar: calendar) else { return nil }
        return calendar.date(byAdding: .day, value: 6, to: start)
    }
}
