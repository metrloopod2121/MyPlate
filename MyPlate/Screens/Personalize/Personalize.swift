//
//  Personalize.swift
//  MyPlate
//
//  Created by 𝕄𝕒𝕥𝕧𝕖𝕪 ℙ𝕠𝕕𝕘𝕠𝕣𝕟𝕚𝕪 on 01.07.2025.
//


import UIKit
import SnapKit

final class PersonalizeViewController: UIViewController {

    enum SurveyMode {
        case full
        case short
    }

    private let mode: SurveyMode

    private var draftProfile: UserProfile

    private var embeddedController: UIViewController?

    private let nextButton = UIButton(type: .system)

    private let stackView = UIStackView()
    private var currentStep = 0

    var onFinish: (() -> Void)?

    private enum Step {
        case gender
        case height
        case weight
        case dob
        case goal
        case activityLevel
        case targetWeight
        case graphIntro
        case diet
    }

    private var steps: [Step] {
        switch mode {
        case .full:
            return [
                .gender,
                .height,
                .weight,
                .dob,
                .goal,
                .diet,
                .activityLevel,
                .targetWeight,
                .graphIntro
            ]
        case .short:
            return [
                .goal,
                .diet,
                .activityLevel,
                .targetWeight
            ]
        }
    }

    init(mode: SurveyMode = .full, existingProfile: UserProfile? = nil) {
        self.mode = mode
        if let profile = existingProfile {
            self.draftProfile = profile
            if mode == .short {
                // загружаем сохранённый профиль если есть
                if let savedProfile = DataFlow().loadUserProfileFromFile() {
                    self.draftProfile = savedProfile
                }
            }
        } else {
            self.draftProfile = UserProfile(
                gender: .male,
                age: 0,
                heightCm: 0,
                startWeight: 0,
                currentWeightKg: 0,
                targetWeightKg: 0,
                weightStat: [:],
                goal: .loseWeight,
                dietType: .balanced,
                activityLevel: .moderate,
                inputHeightUnit: .cm,
                inputWeightUnit: .kg
            )
        }
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateStep()
    }

    private func setupUI() {
        view.backgroundColor = Colors.background
        let backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(backTapped))
        backButton.tintColor = Colors.darkGray
        navigationItem.leftBarButtonItem = backButton

        nextButton.setTitle("Next", for: .normal)
        nextButton.setTitleColor(.white, for: .normal)
        nextButton.titleLabel?.font = Fonts.font(size: 16, weight: .regular)
        nextButton.backgroundColor = Colors.orange
        nextButton.layer.cornerRadius = 10
        nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        nextButton.isEnabled = false
        nextButton.backgroundColor = .gray

        stackView.axis = .vertical
        stackView.spacing = 8

        view.addSubview(nextButton)

        nextButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(50)
        }
    }

    private func setEmbeddedController(_ vc: UIViewController) {
        embeddedController?.willMove(toParent: nil)
        embeddedController?.view.removeFromSuperview()
        embeddedController?.removeFromParent()

        addChild(vc)
        view.addSubview(vc.view)
        vc.didMove(toParent: self)
        embeddedController = vc

        vc.view.snp.remakeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(nextButton.snp.top).offset(-16)
        }

        if vc is PlanGeneratingViewController {
            nextButton.isHidden = true
        } else if vc is PlanSummaryViewController {
            nextButton.isHidden = false
        } else {
            nextButton.isHidden = false
        }
    }

    private func updateStep() {
        navigationController?.popToViewController(self, animated: false)
        embeddedController?.willMove(toParent: nil)
        embeddedController?.view.removeFromSuperview()
        embeddedController?.removeFromParent()
        embeddedController = nil

        let step = steps[currentStep]
        var vc: UIViewController

        switch step {
        case .gender:
            nextButton.isEnabled = false
            nextButton.backgroundColor = .gray
            let cardsVC = CardsSelectViewController(
                title: "What is your gender?",
                caption: "Please specify your gender for statistics and personalization.",
                options: ["Male", "Female", "Other"]
            )
            cardsVC.onSelect = { [weak self] index in
                guard let self = self else { return }
                switch index {
                case 0:
                    self.draftProfile.gender = .male
                case 1:
                    self.draftProfile.gender = .female
                case 2:
                    self.draftProfile.gender = .other
                default:
                    break
                }
                print("Selected gender: \(self.draftProfile.gender)")
                self.nextButton.isEnabled = true
                self.nextButton.backgroundColor = Colors.orange
            }
            vc = cardsVC
        case .height:
            let unitVC = UnitSelectViewController(
                title: "Height",
                caption: "Please indicate your height for accurate and personalized calculations.",
                units: [
                    PickerUnit(name: "cm", symbol: "cm", range: 60...243),
                    PickerUnit(name: "ft/in", symbol: "", range: 0...0)
                ],
                secondUnits: [
                    PickerUnit(name: "ft", symbol: "′", range: 1...8),
                    PickerUnit(name: "in", symbol: "″", range: 0...11)
                ]
            )
            if draftProfile.heightCm > 0 {
                nextButton.isEnabled = true
                nextButton.backgroundColor = Colors.orange
            }
            unitVC.onValueChanged = { [weak self, weak unitVC] in
                guard let self = self, let unitVC = unitVC else { return }
                if unitVC.selectedUnitName == "cm" {
                    self.draftProfile.inputHeightUnit = .cm
                    self.draftProfile.heightCm = Double(unitVC.selectedValue1)
                } else {
                    self.draftProfile.inputHeightUnit = .ft_in
                    let ft = Double(unitVC.selectedValue1)
                    let inch = Double(unitVC.selectedValue2)
                    self.draftProfile.heightCm = ft * 30.48 + inch * 2.54
                }
                print("Updated height: \(self.draftProfile.heightCm) cm")
            }
            unitVC.onNext = { [weak self] in
                self?.nextTapped()
            }
            vc = unitVC
        case .weight:
            let unitVC = UnitSelectViewController(
                title: "Weight",
                caption: "Please indicate your weight for accurate and personalized calculations.",
                units: [
                    PickerUnit(name: "kg", symbol: "kg", range: 30...360),
                    PickerUnit(name: "lbs", symbol: "lbs", range: 110...700)
                ]
            )
            if draftProfile.currentWeightKg > 0 {
                nextButton.isEnabled = true
                nextButton.backgroundColor = Colors.orange
            }
            unitVC.onValueChanged = { [weak self, weak unitVC] in
                guard let self = self, let unitVC = unitVC else { return }
                if unitVC.selectedUnitName == "kg" {
                    self.draftProfile.inputWeightUnit = .kg
                    self.draftProfile.currentWeightKg = Double(unitVC.selectedValue1)
                    self.draftProfile.startWeight = Double(unitVC.selectedValue1)
                } else {
                    self.draftProfile.inputWeightUnit = .lbs
                    self.draftProfile.currentWeightKg = Double(unitVC.selectedValue1) * 0.453592
                    self.draftProfile.startWeight = Double(unitVC.selectedValue1) * 0.453592
                }
                print("Updated weight: \(self.draftProfile.currentWeightKg) kg (input unit: \(self.draftProfile.inputWeightUnit))")
            }
            unitVC.onNext = { [weak self] in
                self?.nextTapped()
            }
            vc = unitVC
        case .dob:
            let dobVC = DateOfBirthViewController()
            dobVC.onValueChanged = { [weak self, weak dobVC] in
                guard let self = self, let dobVC = dobVC else { return }
                let age = Calendar.current.dateComponents([.year], from: dobVC.selectedDate, to: Date()).year ?? 0
                self.draftProfile.age = age
                print("Updated age: \(self.draftProfile.age)")
            }
            dobVC.onNext = { [weak self] in
                self?.nextTapped()
            }
            vc = dobVC
        case .goal:
            nextButton.isEnabled = false
            nextButton.backgroundColor = .gray
            let cardsVC = CardsSelectViewController(
                title: "Goal",
                caption: "Choose your goal so that we can adapt the recommendations to suit you.",
                options: ["Losing weight", "Maintaining", "Weight gain"]
            )
            cardsVC.onSelect = { [weak self] index in
                guard let self = self else { return }
                switch index {
                case 0: self.draftProfile.goal = .loseWeight
                case 1: self.draftProfile.goal = .maintain
                case 2: self.draftProfile.goal = .gainWeight
                default: break
                }
                print("Selected goal: \(self.draftProfile.goal)")
                self.nextButton.isEnabled = true
                self.nextButton.backgroundColor = Colors.orange
            }
            vc = cardsVC
        case .activityLevel:
            nextButton.isEnabled = false
            nextButton.backgroundColor = .gray
            let cardsVC = CardsSelectViewController(
                title: "Activity Level",
                caption: "Please indicate your level of activity so that we can calculate your calorie needs more accurately.",
                options: ["Low", "Moderate", "High", "Very High"],
                descriptions: [
                    "Sedentary lifestyle: sedentary work, minimum physical activity during the day",
                    "Light workouts 1-3 times a week or everyday activities (walking, household chores)",
                    "Regular workouts 4-5 times a week, an active lifestyle, lots of movement throughout the day",
                    "Intense workouts almost every day, physically active work or sports training"
                ]
            )
            cardsVC.onSelect = { [weak self] index in
                guard let self = self else { return }
                let levels: [ActivityLevel] = [.light, .moderate, .active, .veryActive]
                if index < levels.count {
                    self.draftProfile.activityLevel = levels[index]
                    print("Selected activity level: \(self.draftProfile.activityLevel)")
                }
                self.nextButton.isEnabled = true
                self.nextButton.backgroundColor = Colors.orange
            }
            vc = cardsVC
        case .targetWeight:
            let unitVC = UnitSelectViewController(
                title: "Target weight",
                caption: "Specify the desired weight so that we can help you move towards your goal.",
                units: [
                    PickerUnit(name: "kg", symbol: "kg", range: 30...360),
                    PickerUnit(name: "lbs", symbol: "lbs", range: 110...700)
                ]
            )
            if draftProfile.targetWeightKg > 0 {
                nextButton.isEnabled = true
                nextButton.backgroundColor = Colors.orange
            }
            unitVC.onValueChanged = { [weak self, weak unitVC] in
                guard let self = self, let unitVC = unitVC else { return }
                if unitVC.selectedUnitName == "kg" {
                    self.draftProfile.inputWeightUnit = .kg
                    self.draftProfile.targetWeightKg = Double(unitVC.selectedValue1)
                } else {
                    self.draftProfile.inputWeightUnit = .lbs
                    self.draftProfile.targetWeightKg = Double(unitVC.selectedValue1) * 0.453592
                }
                print("Updated target weight: \(self.draftProfile.targetWeightKg) kg (input unit: \(self.draftProfile.inputWeightUnit))")
            }
            unitVC.onNext = { [weak self] in
                self?.nextTapped()
            }
            vc = unitVC
        case .graphIntro:
            let graphVC = GraphIntroViewController()
            graphVC.onNext = { [weak self] in self?.nextTapped() }
            vc = graphVC
        case .diet:
            nextButton.isEnabled = false
            nextButton.backgroundColor = .gray
            let cardsVC = CardsSelectViewController(
                title: "Type of diet",
                caption: "Choose the type of diet that you prefer or follow to take this into account in the recommendations.",
                options: ["Balanced", "Vegetarian", "Ketogenic", "Low-calorie"],
                descriptions: [
                    "Includes all food groups in moderation",
                    "Excludes meat, but may include dairy products and eggs",
                    "Carb, high-fat diet",
                    "Limited calorie intake for weight loss"
                ]
            )
            cardsVC.onSelect = { [weak self] index in
                guard let self = self else { return }
                let diets: [DietType] = [.balanced, .vegetarian, .ketogenic, .lowCalorie]
                if index < diets.count {
                    self.draftProfile.dietType = diets[index]
                    print("Selected diet type: \(self.draftProfile.dietType)")
                }
                self.nextButton.isEnabled = true
                self.nextButton.backgroundColor = Colors.orange
            }
            vc = cardsVC
        }

        setEmbeddedController(vc)
    }


    @objc private func nextTapped() {
        if embeddedController is PlanSummaryViewController {
            onFinish?()
            return
        }
        if currentStep < steps.count - 1 {
            currentStep += 1
            updateStep()
        } else {
            DataFlow().saveUserProfileToFile(profile: draftProfile)

            let plan = NutritionCalculator.calculate(for: draftProfile)
            print("User Profile:")
            print("Gender: \(draftProfile.gender)")
            print("Age: \(draftProfile.age)")
            print("Height (cm): \(draftProfile.heightCm)")
            print("Current Weight (kg): \(draftProfile.currentWeightKg)")
            print("Target Weight (kg): \(draftProfile.targetWeightKg)")
            print("Goal: \(draftProfile.goal)")
            print("Diet Type: \(draftProfile.dietType)")
            print("Activity Level: \(draftProfile.activityLevel)")

            print("Calculated Plan:")
            print("Calories: \(plan.calories)")
            print("Protein: \(plan.proteinGrams)g")
            print("Fat: \(plan.fatGrams)g")
            print("Carbs: \(plan.carbGrams)g")

            let vc = PlanGeneratingViewController()
            vc.onFinish = { [weak self] in
                let summaryVC = PlanSummaryViewController()
                self?.setEmbeddedController(summaryVC)
            }
            setEmbeddedController(vc)
        }
    }

    @objc private func backTapped() {
        if currentStep > 0 {
            currentStep -= 1
            updateStep()
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
}
