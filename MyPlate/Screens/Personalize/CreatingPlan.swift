//
//  CreatingPlan.swift
//  MyPlate
//
//  Created by 𝕄𝕒𝕥𝕧𝕖𝕪 ℙ𝕠𝕕𝕘𝕠𝕣𝕟𝕚𝕪 on 01.07.2025.
//

import Foundation

//
//  PlanGeneratingViewController.swift
//  MyPlate
//
//  Created by 𝕄𝕒𝕥𝕧𝕖𝕪 ℙ𝕠𝕕𝕘𝕠𝕣𝕟𝕚𝕪 on 01.07.2025.
//

import UIKit
import SnapKit

final class PlanGeneratingViewController: UIViewController {

    var onFinish: (() -> Void)?

    private let progressLabel = UILabel()
    private let ringLayer = CAShapeLayer()
    private let backgroundRingLayer = CAShapeLayer()
    private var timer: Timer?
    private var progress: CGFloat = 0

    private let statusLabel = UILabel()
    private let communityLabel = UILabel()
    private let starsImageView = UIImageView(image: UIImage(named: "stars"))

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        startSimulatedProgress()
    }

    private func setupUI() {
        view.backgroundColor = Colors.background

        let ringView = UIView()
        view.addSubview(ringView)
        ringView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-60)
            $0.width.height.equalTo(271)
        }

        let center = CGPoint(x: 135.5, y: 135.5)
        let circularPath = UIBezierPath(arcCenter: center, radius: 135.5, startAngle: -.pi / 2, endAngle: 1.5 * .pi, clockwise: true)

        backgroundRingLayer.path = circularPath.cgPath
        backgroundRingLayer.strokeColor = UIColor(red: 237/255, green: 237/255, blue: 237/255, alpha: 1).cgColor
        backgroundRingLayer.lineWidth = 8
        backgroundRingLayer.fillColor = UIColor.clear.cgColor
        ringView.layer.addSublayer(backgroundRingLayer)

        ringLayer.path = circularPath.cgPath
        ringLayer.strokeColor = Colors.orange.cgColor
        ringLayer.lineWidth = 8
        ringLayer.fillColor = UIColor.clear.cgColor
        ringLayer.strokeEnd = 0
        ringView.layer.addSublayer(ringLayer)

        progressLabel.font = Fonts.font(size: 36, weight: .bold)
        progressLabel.textAlignment = .center
        progressLabel.text = "0%"
        ringView.addSubview(progressLabel)
        progressLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }

        statusLabel.text = "Creating your plan"
        statusLabel.font = Fonts.font(size: 32, weight: .bold)
        statusLabel.textColor = .black
        statusLabel.textAlignment = .center
        view.addSubview(statusLabel)
        statusLabel.snp.makeConstraints {
            $0.top.equalTo(ringView.snp.bottom).offset(32)
            $0.centerX.equalToSuperview()
        }

        communityLabel.text = "More than 500,000 people are already\n changing their lives"
        communityLabel.font = Fonts.font(size: 15, weight: .regular)
        communityLabel.textColor = .black
        communityLabel.textAlignment = .center
        communityLabel.numberOfLines = 2
        view.addSubview(communityLabel)
        communityLabel.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(56)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.width.lessThanOrEqualTo(300)
        }

        starsImageView.contentMode = .scaleAspectFit
        view.addSubview(starsImageView)
        starsImageView.snp.makeConstraints {
            $0.top.equalTo(communityLabel.snp.bottom).offset(8)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(24)
        }
    }

    private func startSimulatedProgress() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.progress += CGFloat.random(in: 0.3...1.2)
            if self.progress >= 100 {
                self.progress = 100
                self.timer?.invalidate()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.onFinish?()
                }
            }
            self.progressLabel.text = "\(Int(self.progress))%"
            self.ringLayer.strokeEnd = self.progress / 100
        }
    }

    deinit {
        timer?.invalidate()
    }
}
