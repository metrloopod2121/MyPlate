//
//  WeightingView.swift
//  MyPlate
//
//  Created by 𝕄𝕒𝕥𝕧𝕖𝕪 ℙ𝕠𝕕𝕘𝕠𝕣𝕟𝕚𝕪 on 04.07.2025.
//

import Foundation
import UIKit
import SnapKit

protocol WeightAddViewControllerDelegate: AnyObject {
    func didAddNewWeight(_ weightStat: [Date: Double])
}

class WeightAddViewController: UIViewController {
    weak var delegate: WeightAddViewControllerDelegate?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Adding weight"
        label.textAlignment = .left
        label.font = Fonts.font(size: 20, weight: .medium)
        label.layer.masksToBounds = true
        return label
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "weight_man")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let instructionLabel: UILabel = {
        let label = UILabel()
        label.text = "Enter your current weight, kg"
        label.textAlignment = .left
        label.font = Fonts.font(size: 16, weight: .regular)
        label.layer.masksToBounds = true
        return label
    }()
    
    private let weightTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .white
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 16
        textField.keyboardType = .decimalPad
        textField.placeholder = ""
        textField.textAlignment = .left
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 44))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        return textField
    }()
    
    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add weight", for: .normal)
        button.backgroundColor = Colors.orange
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.background
        
        view.addSubview(titleLabel)
        view.addSubview(imageView)
        view.addSubview(instructionLabel)
        view.addSubview(weightTextField)
        view.addSubview(addButton)
        
        setupConstraints()
        addButton.addTarget(self, action: #selector(addWeightTapped), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.centerX.equalToSuperview()
        }
        
        imageView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.height.equalTo(197)
            make.width.equalTo(246)
        }
        
        instructionLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        weightTextField.snp.makeConstraints { make in
            make.top.equalTo(instructionLabel.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(44)
        }
        
        addButton.snp.makeConstraints { make in
            make.top.equalTo(weightTextField.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(50)
        }
    }
    
    @objc private func addWeightTapped() {
        guard let text = weightTextField.text, let weight = Double(text), !text.isEmpty else {
            return
        }

        // Simple button tap animation
        UIView.animate(withDuration: 0.1,
                       animations: {
            self.addButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }, completion: { _ in
            UIView.animate(withDuration: 0.1) {
                self.addButton.transform = CGAffineTransform.identity
            }
        })

        // Load user profile
        guard var profile = DataFlow().loadUserProfileFromFile() else {
            return
        }

        // Add new weight to weightStat array
        let now = Date()
        profile.weightStat[now] = weight

        // Save updated profile
        DataFlow().saveUserProfileToFile(profile: profile)

        // Optionally clear text field or provide feedback
        weightTextField.text = ""

        // Notify delegate
        if let updatedProfile = DataFlow().loadUserProfileFromFile() {
            delegate?.didAddNewWeight(updatedProfile.weightStat)
        }
        self.dismiss(animated: true)
    }
}
