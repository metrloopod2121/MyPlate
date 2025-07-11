//
//  ManuallyAddMeal.swift
//  MyPlate
//
//  Created by 𝕄𝕒𝕥𝕧𝕖𝕪 ℙ𝕠𝕕𝕘𝕠𝕣𝕟𝕚𝕪 on 04.07.2025.
//

import Foundation
import UIKit
import SnapKit

class ManuallyAddMealViewController: UIViewController, UITextViewDelegate {
    
    private let apiService = APIService.shared
    
    private let textView: UITextView = {
        let tv = UITextView()
        tv.font = Fonts.font(size: 16, weight: .regular)
        tv.isScrollEnabled = true
        tv.layer.borderColor = Colors.lightGray.cgColor
        tv.layer.borderWidth = 0.5
        tv.layer.cornerRadius = 16
        tv.textColor = UIColor.lightGray
        tv.text = "Describe in as much detail as possible what you ate"
        tv.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        return tv
    }()
    
    private let placeholderText = "Describe in as much detail as possible what you ate"
    
    private let infoView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.lightGray
        view.layer.cornerRadius = 16
        return view
    }()
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.text = "Provide a detailed description of the dish, including ingredients, portion size, and any other details to help us calculate the values more accurately."
        label.numberOfLines = 0
        label.font = Fonts.font(size: 14, weight: .regular)
        label.textColor = Colors.gray
        return label
    }()
    
    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add", for: .normal)
        button.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1.0)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.titleLabel?.textColor = .black
        button.isEnabled = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.background
        
        view.addSubview(textView)
        view.addSubview(infoView)
        infoView.addSubview(infoLabel)
        view.addSubview(addButton)
        
        textView.delegate = self
        
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        
        textView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.greaterThanOrEqualTo(182)
        }
        
        infoView.snp.makeConstraints { make in
            make.top.equalTo(textView.snp.bottom).offset(12)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }
        
        infoLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(12)
        }
        
        addButton.snp.makeConstraints { make in
            make.top.equalTo(infoView.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(50)
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray && textView.text == placeholderText {
            textView.text = ""
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = placeholderText
            textView.textColor = UIColor.lightGray
            updateAddButtonState()
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        // Ensure text color is black if user starts typing
        if textView.textColor == UIColor.lightGray {
            textView.textColor = UIColor.black
        }
        if textView.text.isEmpty {
            addButton.isEnabled = false
            addButton.backgroundColor = UIColor.gray
        } else if textView.textColor == UIColor.lightGray && textView.text == placeholderText {
            addButton.isEnabled = false
            addButton.backgroundColor = UIColor.gray
        } else {
            updateAddButtonState()
        }
    }
    
    private func updateAddButtonState() {
        let text = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if !text.isEmpty && text != placeholderText {
            addButton.isEnabled = true
            addButton.backgroundColor = Colors.orange
        } else {
            addButton.isEnabled = false
            addButton.backgroundColor = UIColor.gray
        }
    }
    
    @objc private func addButtonTapped() {
        let description = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !description.isEmpty, description != placeholderText else { return }

        addButton.isEnabled = false
        addButton.setTitle("Loading...", for: .normal)

        Task {
            do {
                let meal = try await apiService.analyzeMealText(description: description)

                await MainActor.run {
                    let addMealVC = AddMealViewController(image: UIImage(named: "meal_ph")!, meal: meal)
                    self.navigationController?.pushViewController(addMealVC, animated: true)
                    self.addButton.isEnabled = true
                    self.addButton.setTitle("Add", for: .normal)
                }
            } catch {
                await MainActor.run {
                    self.addButton.isEnabled = true
                    self.addButton.setTitle("Add", for: .normal)
                    let alert = UIAlertController(title: "Error", message: "Failed to analyze meal: \(error.localizedDescription)", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                }
            }
        }
    }
}
