//
//  CardsSelect.swift
//  MyPlate
//
//  Created by 𝕄𝕒𝕥𝕧𝕖𝕪 ℙ𝕠𝕕𝕘𝕠𝕣𝕟𝕚𝕪 on 01.07.2025.
//

import UIKit
import SnapKit

final class CardsSelectViewController: UIViewController {

    private let titleText: String
    private let captionText: String
    private let options: [String]
    private let descriptions: [String]?

    private let titleLabel = UILabel()
    private let captionLabel = UILabel()
    private let headerStack = UIStackView()
    private let stackView = UIStackView()

    private var selectedIndex: Int?

    var onNext: (() -> Void)?
    var onSelect: ((Int) -> Void)?

    init(title: String, caption: String, options: [String], descriptions: [String]? = nil) {
        self.titleText = title
        self.captionText = caption
        self.options = options
        self.descriptions = descriptions
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
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

        headerStack.axis = .vertical
        headerStack.spacing = 8
        view.addSubview(headerStack)
        headerStack.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(32)
            $0.leading.trailing.equalToSuperview().inset(16)
        }

        headerStack.addArrangedSubview(titleLabel)
        headerStack.addArrangedSubview(captionLabel)

        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        view.addSubview(stackView)

        stackView.snp.remakeConstraints {
            $0.top.equalTo(headerStack.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.lessThanOrEqualToSuperview().inset(16)
        }

        for (index, option) in options.enumerated() {
            let container = UIView()
            container.layer.cornerRadius = 16
            container.backgroundColor = .white
            container.layer.borderWidth = 0

            let titleLabel = UILabel()
            titleLabel.text = option
            titleLabel.font = Fonts.font(size: 16, weight: .regular)
            titleLabel.textColor = .black

            container.addSubview(titleLabel)
            titleLabel.snp.makeConstraints {
                $0.top.equalToSuperview().inset(12)
                $0.leading.trailing.equalToSuperview().inset(16)
            }

            if let descriptions = descriptions, index < descriptions.count {
                let descriptionLabel = UILabel()
                descriptionLabel.text = descriptions[index]
                descriptionLabel.font = Fonts.font(size: 14, weight: .regular)
                descriptionLabel.textColor = Colors.gray
                descriptionLabel.numberOfLines = 0
                container.addSubview(descriptionLabel)
                descriptionLabel.snp.makeConstraints {
                    $0.top.equalTo(titleLabel.snp.bottom).offset(4)
                    $0.leading.trailing.bottom.equalToSuperview().inset(16)
                }
            } else {
                titleLabel.snp.makeConstraints {
                    $0.bottom.equalToSuperview().inset(12)
                }
            }

            container.isUserInteractionEnabled = true
            container.tag = index
            container.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(optionTappedView(_:))))
            container.snp.makeConstraints {
                $0.height.greaterThanOrEqualTo(73)
            }

            stackView.addArrangedSubview(container)
        }

    }

    @objc private func optionTappedView(_ sender: UITapGestureRecognizer) {
        guard let view = sender.view else { return }
        for card in stackView.arrangedSubviews {
            let isSelected = card == view
            card.backgroundColor = isSelected ? Colors.orange : .white
            for case let label as UILabel in card.subviews {
                if label.font.pointSize == 16 {
                    label.textColor = isSelected ? .white : .black
                } else if label.font.pointSize == 14 {
                    label.textColor = isSelected ? .white : Colors.gray
                }
            }
            card.layer.borderWidth = 0
        }
        selectedIndex = view.tag
        onSelect?(view.tag)
    }

    @objc private func nextTapped() {
        onNext?()
    }
}
