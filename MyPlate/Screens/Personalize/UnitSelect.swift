//
//  UnitSelect.swift
//  MyPlate
//
//  Created by 𝕄𝕒𝕥𝕧𝕖𝕪 ℙ𝕠𝕕𝕘𝕠𝕣𝕟𝕚𝕪 on 01.07.2025.
//


import UIKit
import SnapKit

struct PickerUnit {
    let name: String
    let symbol: String
    let range: ClosedRange<Int>
}

final class UnitSelectViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    var onNext: (() -> Void)?
    var onSelect: (() -> Void)?
    var onValueChanged: (() -> Void)?

    private let titleText: String
    private let captionText: String
    private let units: [PickerUnit]
    private let secondUnits: [PickerUnit]?

    private let titleLabel = UILabel()
    private let captionLabel = UILabel()
    private let unitSegment = UIStackView()
    private let pickerContainer = UIView()
    private let pickerView1 = UIPickerView()
    private let pickerView2 = UIPickerView()

    private var selectedUnitIndex = 0
    
    var selectedUnitName: String {
        units[selectedUnitIndex].name
    }

    var selectedValue1: Int {
        let row = pickerView1.selectedRow(inComponent: 0)
        let unit = (secondUnits != nil && selectedUnitName.contains("/")) ? secondUnits![0] : units[selectedUnitIndex]
        return unit.range.lowerBound + row
    }

    var selectedValue2: Int {
        let row = pickerView2.selectedRow(inComponent: 0)
        guard let secondUnits = secondUnits else { return 0 }
        let unit = secondUnits[1]
        return unit.range.lowerBound + row
    }


    init(title: String, caption: String, units: [PickerUnit], secondUnits: [PickerUnit]? = nil) {
        self.titleText = title
        self.captionText = caption
        self.units = units
        self.secondUnits = secondUnits
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        selectUnit(index: 0)
    }

    private func setupUI() {
        view.backgroundColor = Colors.background

        titleLabel.text = titleText
        titleLabel.font = Fonts.font(size: 32, weight: .bold)
        titleLabel.textAlignment = .left
        titleLabel.numberOfLines = 0

        captionLabel.text = captionText
        captionLabel.font = Fonts.font(size: 16, weight: .regular)
        captionLabel.textColor = Colors.gray
        captionLabel.textAlignment = .left
        captionLabel.numberOfLines = 0

        unitSegment.axis = .horizontal
        unitSegment.spacing = 10
        unitSegment.distribution = .equalSpacing
        unitSegment.alignment = .center

        for (index, unit) in units.enumerated() {
            let button = UIButton(type: .system)
            button.setTitle(unit.name, for: .normal)
            button.setTitleColor(Colors.orange, for: .normal)
            button.titleLabel?.font = Fonts.font(size: 14, weight: .medium)
            button.layer.cornerRadius = 16
            button.layer.borderWidth = 1
            button.layer.borderColor = Colors.orange.cgColor
            button.snp.makeConstraints {
                $0.width.equalTo(121)
                $0.height.equalTo(32)
            }
            button.tag = index
            button.addTarget(self, action: #selector(unitTapped(_:)), for: .touchUpInside)
            unitSegment.addArrangedSubview(button)
        }

        pickerView1.delegate = self
        pickerView1.dataSource = self
        pickerView2.delegate = self
        pickerView2.dataSource = self

        [titleLabel, captionLabel, unitSegment, pickerContainer].forEach { view.addSubview($0) }
        [pickerView1, pickerView2].forEach { pickerContainer.addSubview($0) }


        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(32)
            $0.leading.trailing.equalToSuperview().inset(16)
        }

        captionLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(16)
        }

        unitSegment.snp.makeConstraints {
            $0.top.equalTo(captionLabel.snp.bottom).offset(24)
            $0.centerX.equalToSuperview()
        }

        pickerContainer.snp.makeConstraints {
            $0.top.equalTo(unitSegment.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(180)
        }

        pickerView1.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(0.5)
            $0.leading.equalToSuperview()
        }

        pickerView2.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(0.5)
            $0.trailing.equalToSuperview()
        }

    }

    @objc private func unitTapped(_ sender: UIButton) {
        selectUnit(index: sender.tag)
    }

    private func selectUnit(index: Int) {
        selectedUnitIndex = index
        for case let button as UIButton in unitSegment.arrangedSubviews {
            let selected = button.tag == index
            button.backgroundColor = selected ? Colors.orange : .white
            button.setTitleColor(selected ? .white : Colors.orange, for: .normal)
        }

        // Показываем оба пикера только если выбрана комбинированная единица (например, "ft/in")
        if secondUnits != nil && units[selectedUnitIndex].name.contains("/") {
            pickerView1.isHidden = false
            pickerView2.isHidden = false
        } else {
            pickerView1.isHidden = false
            pickerView2.isHidden = true
        }

        if pickerView2.isHidden {
            pickerView1.snp.remakeConstraints {
                $0.top.bottom.equalToSuperview()
                $0.leading.trailing.equalToSuperview()
            }
        } else {
            pickerView1.snp.remakeConstraints {
                $0.top.bottom.equalToSuperview()
                $0.width.equalToSuperview().multipliedBy(0.5)
                $0.leading.equalToSuperview()
            }
            pickerView2.snp.remakeConstraints {
                $0.top.bottom.equalToSuperview()
                $0.width.equalToSuperview().multipliedBy(0.5)
                $0.trailing.equalToSuperview()
            }
        }

        pickerView1.reloadAllComponents()
        pickerView2.reloadAllComponents()
        onSelect?()
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        onValueChanged?()
    }


    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        let unit: PickerUnit
        if pickerView == pickerView1 {
            if secondUnits != nil && units[selectedUnitIndex].name.contains("/") {
                unit = secondUnits![0]
            } else {
                unit = units[selectedUnitIndex]
            }
        } else {
            unit = secondUnits?[1] ?? units[selectedUnitIndex]
        }
        return unit.range.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let unit: PickerUnit
        if pickerView == pickerView1 {
            if secondUnits != nil && units[selectedUnitIndex].name.contains("/") {
                unit = secondUnits![0]
            } else {
                unit = units[selectedUnitIndex]
            }
        } else {
            unit = secondUnits?[1] ?? units[selectedUnitIndex]
        }
        let value = unit.range.lowerBound + row
        return "\(value) \(unit.symbol)"
    }

}
