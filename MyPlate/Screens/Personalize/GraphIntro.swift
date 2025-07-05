//
//  GraphIntro.swift
//  MyPlate
//
//  Created by 𝕄𝕒𝕥𝕧𝕖𝕪 ℙ𝕠𝕕𝕘𝕠𝕣𝕟𝕚𝕪 on 01.07.2025.
//

import Foundation
import UIKit
import SnapKit

final class GraphIntroViewController: UIViewController {

    var onNext: (() -> Void)?

    private let titleLabel = UILabel()
    private let captionLabel = UILabel()
    private let imageView = UIImageView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = Colors.background

        titleLabel.text = "Lose weight smarter not tougher."
        titleLabel.font = Fonts.font(size: 32, weight: .bold)
        titleLabel.textAlignment = .left
        titleLabel.numberOfLines = 0

        captionLabel.text = "Personal approach, nutrition for your goals and no unnecessary restrictions."
        captionLabel.font = Fonts.font(size: 16, weight: .medium)
        captionLabel.textColor = Colors.gray
        captionLabel.textAlignment = .left
        captionLabel.numberOfLines = 0

        imageView.image = UIImage(named: "weight_graph")
        imageView.contentMode = .scaleAspectFill

        [titleLabel, captionLabel, imageView].forEach { view.addSubview($0) }

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(32)
            $0.leading.trailing.equalToSuperview().inset(16)
        }

        captionLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(16)
        }

        imageView.snp.makeConstraints {
            $0.top.equalTo(captionLabel.snp.bottom).offset(32)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(250)
        }
    }
}
