//
//  Calendar.swift
//  MyPlate
//
//  Created by 𝕄𝕒𝕥𝕧𝕖𝕪 ℙ𝕠𝕕𝕘𝕠𝕣𝕟𝕚𝕪 on 04.07.2025.
//

import UIKit

class CalendarViewController: UIViewController {

    // Callback when date is selected
    var onDateSelected: ((Date) -> Void)?

    private let dataFlow = DataFlow()
    private var userHistory: [UserHistory] = []

    // Pro label for unsubscribed users
    private let proLabelImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "pro_label"))
        iv.contentMode = .scaleAspectFit
        iv.isHidden = true
        return iv
    }()

    // MARK: - UI Elements
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Calendar"
        label.font = Fonts.font(size: 34, weight: .bold)
        return label
    }()

    private let buttonsContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 18
        view.layer.masksToBounds = true
        return view
    }()

    private let streakIcon: UIImageView = {
        let imageView = UIImageView()
        if let star = UIImage(named: "star") {
            imageView.image = star
        }
        imageView.tintColor = UIColor.systemYellow
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let streakCountLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .black
        return label
    }()

    private lazy var seriesButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .clear
        // Stack inside button
        let stack = UIStackView(arrangedSubviews: [streakIcon, streakCountLabel])
        stack.axis = .horizontal
        stack.spacing = 4
        stack.alignment = .center
        button.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().offset(-8)
            make.top.equalToSuperview().offset(4)
            make.bottom.equalToSuperview().offset(-4)
        }
        streakIcon.snp.makeConstraints { make in
            make.width.height.equalTo(20)
        }
        return button
    }()

   
    private let monthYearLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        return label
    }()

    private let chevronsContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16

        let leftChevron = UIImageView(image: UIImage(systemName: "chevron.left"))
        leftChevron.tintColor = .black
        leftChevron.contentMode = .scaleAspectFit
        leftChevron.isUserInteractionEnabled = true

        let rightChevron = UIImageView(image: UIImage(systemName: "chevron.right"))
        rightChevron.tintColor = .black
        rightChevron.contentMode = .scaleAspectFit
        rightChevron.isUserInteractionEnabled = true

        view.addSubview(leftChevron)
        view.addSubview(rightChevron)

        leftChevron.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(16)
        }

        rightChevron.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(16)
        }

        return view
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

    private let daysOfWeekStack: UIStackView = {
        let labels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"].map { day -> UILabel in
            let label = UILabel()
            label.text = day
            label.textAlignment = .center
            label.font = Fonts.font(size: 12, weight: .medium)
            label.textColor = Colors.gray
            return label
        }
        let stack = UIStackView(arrangedSubviews: labels)
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        return stack
    }()

    private let calendarGridView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 2
        return stack
    }()

    private var currentDate = Date()
    private var calendar = Calendar.current

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.background
        setupLayout()

        // Add pro label image view and constraints
        view.addSubview(proLabelImageView)
        proLabelImageView.snp.makeConstraints { make in
            make.center.equalTo(buttonsContainer)
            make.width.equalTo(70)
            make.height.equalTo(32)
        }

        loadUserHistoryAndUpdateStreak()
        updateCalendar()

        userButton.addTarget(self, action: #selector(userButtonTapped), for: .touchUpInside)
        seriesButton.addTarget(self, action: #selector(streakButtonTapped), for: .touchUpInside)
    }

    private func loadUserHistoryAndUpdateStreak() {
        let subscribed = SubscriptionHandler.shared.hasActiveSubscription

        if subscribed {
            proLabelImageView.isHidden = true
            buttonsContainer.isHidden = false
            proLabelImageView.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(proLabelTapped))
            proLabelImageView.addGestureRecognizer(tap)

            if let history = dataFlow.loadHistoryArrFromFile() {
                self.userHistory = history
                let streak = dataFlow.currentWeekStreak(from: history)
                DispatchQueue.main.async {
                    self.streakCountLabel.text = "\(streak)"
                }
            } else {
                DispatchQueue.main.async {
                    self.streakCountLabel.text = "0"
                }
            }
        } else {
            proLabelImageView.isHidden = false
            buttonsContainer.isHidden = true
            proLabelImageView.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(proLabelTapped))
            proLabelImageView.addGestureRecognizer(tap)
        }
    }

    private func setupLayout() {
        view.addSubview(titleLabel)
        view.addSubview(buttonsContainer)
        view.addSubview(userButton)
        view.addSubview(monthYearLabel)
        view.addSubview(chevronsContainer)
        view.addSubview(daysOfWeekStack)
        view.addSubview(calendarGridView)

        buttonsContainer.addSubview(seriesButton)

        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
            make.height.greaterThanOrEqualTo(40)
        }

        buttonsContainer.snp.makeConstraints { make in
            make.trailing.equalTo(userButton.snp.leading).offset(-12)
            make.centerY.equalTo(titleLabel.snp.centerY)
            make.height.equalTo(36)
            make.width.greaterThanOrEqualTo(56)
        }

        seriesButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        userButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalTo(titleLabel.snp.centerY)
            make.width.height.equalTo(36)
        }

        monthYearLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalTo(titleLabel.snp.bottom).offset(24)
        }

        chevronsContainer.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalTo(monthYearLabel.snp.centerY)
            make.width.equalTo(72)
            make.height.equalTo(36)
        }

        daysOfWeekStack.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalTo(monthYearLabel.snp.bottom).offset(16)
            make.height.equalTo(20)
        }

        calendarGridView.snp.makeConstraints { make in
            make.top.equalTo(daysOfWeekStack.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.lessThanOrEqualTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
        }

        chevronsContainer.isUserInteractionEnabled = true
        // Add tap gestures for left and right chevrons
        if let leftChevron = chevronsContainer.subviews.first(where: { ($0 as? UIImageView)?.image == UIImage(systemName: "chevron.left") }) {
            let tapLeft = UITapGestureRecognizer(target: self, action: #selector(prevMonthTapped))
            leftChevron.addGestureRecognizer(tapLeft)
            leftChevron.isUserInteractionEnabled = true
        }
        if let rightChevron = chevronsContainer.subviews.first(where: { ($0 as? UIImageView)?.image == UIImage(systemName: "chevron.right") }) {
            let tapRight = UITapGestureRecognizer(target: self, action: #selector(nextMonthTapped))
            rightChevron.addGestureRecognizer(tapRight)
            rightChevron.isUserInteractionEnabled = true
        }
    }

    @objc private func prevMonthTapped() {
        guard let newDate = calendar.date(byAdding: .month, value: -1, to: currentDate) else { return }
        currentDate = newDate
        updateCalendar()
    }

    @objc private func nextMonthTapped() {
        guard let newDate = calendar.date(byAdding: .month, value: 1, to: currentDate) else { return }
        currentDate = newDate
        updateCalendar()
    }

    private func updateCalendar() {
        // Update month/year label
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "LLLL yyyy"
        dateFormatter.locale = Locale(identifier: "en_US")
        monthYearLabel.text = dateFormatter.string(from: currentDate).capitalized

        // Clear previous day buttons
        calendarGridView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        guard let range = calendar.range(of: .day, in: .month, for: currentDate),
              let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentDate)) else {
            return
        }

        let firstWeekday = calendar.component(.weekday, from: firstOfMonth)
        // Adjust Sunday=1 to Monday=1 for convenience
        let weekdayOffset = (firstWeekday + 5) % 7

        let today = Date()
        let todayComponents = calendar.dateComponents([.year, .month, .day], from: today)

        var day = 1
        let totalDays = range.count

        for row in 0..<6 {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.distribution = .fillEqually
            rowStack.spacing = 2

            for col in 0..<7 {
                let button = UIButton(type: .system)
                button.titleLabel?.font = Fonts.font(size: 17, weight: .medium)
                button.layer.cornerRadius = 8
                button.clipsToBounds = true

                let index = row * 7 + col

                if index >= weekdayOffset && day <= totalDays {
                    button.setTitle("\(day)", for: .normal)
                    button.setTitleColor(.black, for: .normal)
                    button.tintColor = .black
                    button.setTitleColor(.black, for: .highlighted)
                    button.setTitleColor(.black, for: .selected)
                    button.tag = day
                    button.addTarget(self, action: #selector(dayButtonTapped(_:)), for: .touchUpInside)

                    // Check if this day is today
                    var buttonDateComponents = calendar.dateComponents([.year, .month, .day], from: currentDate)
                    buttonDateComponents.day = day

                    if buttonDateComponents.year == todayComponents.year &&
                       buttonDateComponents.month == todayComponents.month &&
                       buttonDateComponents.day == todayComponents.day {
                        // This is today, highlight it
                        button.backgroundColor = Colors.orange
                        button.setTitleColor(.white, for: .normal)
                        button.layer.cornerRadius = 22 // Assuming button height = 44
                        button.clipsToBounds = true
                    } else {
                        button.backgroundColor = .clear
                    }

                    day += 1
                } else {
                    button.setTitle("", for: .normal)
                    button.isEnabled = false
                    button.backgroundColor = .clear
                }

                button.snp.makeConstraints { make in
                    make.height.equalTo(44)
                }

                rowStack.addArrangedSubview(button)
            }

            calendarGridView.addArrangedSubview(rowStack)
        }
    }
    
    @objc private func proLabelTapped() {
        let paywall = PaywallViewController()
        let nav = UINavigationController(rootViewController: paywall)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }


    @objc private func dayButtonTapped(_ sender: UIButton) {
        let day = sender.tag
        var components = calendar.dateComponents([.year, .month, .day], from: currentDate)
        components.day = day
        if let selectedDate = calendar.date(from: components) {
            onDateSelected?(selectedDate)
            navigationController?.popViewController(animated: true)
        }
    }
    @objc private func userButtonTapped() {
        let accountVC = AccountSettingsViewController()
        navigationController?.pushViewController(accountVC, animated: true)
    }

    @objc private func streakButtonTapped() {
        let streakVC = TrackingViewController()
        navigationController?.pushViewController(streakVC, animated: true)
    }
}

