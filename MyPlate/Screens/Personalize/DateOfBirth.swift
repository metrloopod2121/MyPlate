//
//  DateOfBirth.swift
//  MyPlate
//
//  Created by 𝕄𝕒𝕥𝕧𝕖𝕪 ℙ𝕠𝕕𝕘𝕠𝕣𝕟𝕚𝕪 on 01.07.2025.
//

import Foundation
import UIKit
import SnapKit

final class DateOfBirthViewController: UIViewController {

    var onNext: (() -> Void)?
    var onValueChanged: (() -> Void)?
    
    var selectedDate: Date {
        return datePicker.date
    }

    private let titleLabel = UILabel()
    private let captionLabel = UILabel()
    private let datePicker = UIDatePicker()
    private let nextButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = Colors.background

        titleLabel.text = "Date of Birth"
        titleLabel.font = Fonts.font(size: 32, weight: .bold)
        titleLabel.textAlignment = .left
        titleLabel.numberOfLines = 0

        captionLabel.text = "Specify your date of birth to calculate your age and personalize your recommendations."
        captionLabel.font = Fonts.font(size: 16, weight: .medium)
        captionLabel.textColor = Colors.gray
        captionLabel.textAlignment = .left
        captionLabel.numberOfLines = 0

        datePicker.datePickerMode = .date
        datePicker.maximumDate = Date()
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.tintColor = Colors.orange

        [titleLabel, captionLabel, datePicker].forEach { view.addSubview($0) }

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(32)
            $0.leading.trailing.equalToSuperview().inset(16)
        }

        captionLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(16)
        }

        datePicker.snp.makeConstraints {
            $0.top.equalTo(captionLabel.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(16)
        }

        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
    }

    @objc private func dateChanged(_ sender: UIDatePicker) {
        onValueChanged?()
    }
}
