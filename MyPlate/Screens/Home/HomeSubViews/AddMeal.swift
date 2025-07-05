//
//  AddMealViewController.swift
//  MyPlate
//
//  Created by 𝕄𝕒𝕥𝕧𝕖𝕪 ℙ𝕠𝕕𝕘𝕠𝕣𝕟𝕚𝕪 on 03.07.2025.
//

import Foundation
import UIKit
import SnapKit

// MARK: - AddMealViewControllerDelegate
protocol AddMealViewControllerDelegate: AnyObject {
    func didAddMeal()
}




final class IngredientsHeaderCell: UICollectionViewCell {
    static let identifier = "IngredientsHeaderCell"
    private let label: UILabel = {
        let label = UILabel()
        label.text = "Ingredients"
        label.font = Fonts.font(size: 24, weight: .medium)
        label.textColor = .black
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(label)
        label.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().offset(-8)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        contentView.backgroundColor = Colors.background
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class AddMealViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    weak var delegate: AddMealViewControllerDelegate?
    private let mealImage: UIImage?
    private var meal: Meal
    private var mealItems: [FoodItem]

    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = Colors.background
        cv.alwaysBounceVertical = true
        cv.showsVerticalScrollIndicator = true
        cv.dataSource = self
        cv.delegate = self
        cv.register(MealInfoCell.self, forCellWithReuseIdentifier: MealInfoCell.identifier)
        cv.register(IngredientCell.self, forCellWithReuseIdentifier: IngredientCell.identifier)
        cv.register(IngredientsHeaderCell.self, forCellWithReuseIdentifier: IngredientsHeaderCell.identifier)
        return cv
    }()

    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add", for: .normal)
        button.backgroundColor = Colors.orange
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = Fonts.font(size: 18, weight: .regular)
        button.layer.cornerRadius = 12
        button.clipsToBounds = true
        return button
    }()

    init(image: UIImage, meal: Meal) {
        self.mealImage = image
        self.meal = meal
        self.mealItems = meal.items
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.background

        view.addSubview(collectionView)
        view.addSubview(addButton)

        addButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(16)
            make.height.equalTo(50)
        }

        collectionView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(addButton.snp.top).offset(-12)
        }

        // Подписываемся на событие нажатия кнопки addButton
        addButton.addTarget(self, action: #selector(handleAddButtonTapped), for: .touchUpInside)
    }

    @objc func handleAddButtonTapped() {
        let dataFlow = DataFlow()
        var histories = dataFlow.loadHistoryArrFromFile() ?? []

        print("UserHistory before adding meal:")
        for history in histories {
            print("Date: \(history.day), meals count: \(history.history.count)")
        }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        meal.image = mealImage

        if let index = histories.firstIndex(where: { calendar.isDate($0.day, inSameDayAs: today) }) {
            histories[index].history.append(meal)
        } else {
            let newHistory = UserHistory(day: today, history: [meal])
            histories.append(newHistory)
        }

        dataFlow.saveArr(arr: histories)

        print("UserHistory after adding meal:")
        for history in histories {
            print("Date: \(history.day), meals count: \(history.history.count)")
        }

        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .mealAdded, object: self.meal)
            self.delegate?.didAddMeal()
            self.dismiss(animated: true)
        }
    }
}

extension AddMealViewController {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mealItems.count + 2
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.item {
        case 0:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MealInfoCell.identifier, for: indexPath) as? MealInfoCell else {
                return UICollectionViewCell()
            }
            cell.configure(image: mealImage ?? UIImage(named: "meal_ph")!, meal: meal)
            return cell
        case 1:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IngredientsHeaderCell.identifier, for: indexPath) as? IngredientsHeaderCell else {
                return UICollectionViewCell()
            }
            return cell
        default:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IngredientCell.identifier, for: indexPath) as? IngredientCell else {
                return UICollectionViewCell()
            }
            let ingredient = mealItems[indexPath.item - 2]
            let calories = Int((ingredient.kilocaloriesPer100g / 100) * ingredient.weight)
            cell.configure(
                title: ingredient.title,
                weight: Int(ingredient.weight),
                calories: calories,
                carbs: ingredient.carbohydratesPer100g,
                protein: ingredient.proteinsPer100g,
                fat: ingredient.fatsPer100g
            )
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, trailingSwipeActionsConfigurationForItemAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        print("Swipe action requested for item at \(indexPath.item)")
        guard indexPath.item >= 2 else { return nil }
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completionHandler in
            guard let self = self else { return }
            self.mealItems.remove(at: indexPath.item - 2)
            self.meal = Meal(items: self.mealItems, total: self.meal.total)
            collectionView.performBatchUpdates({
                collectionView.deleteItems(at: [indexPath])
            }, completion: { _ in
                collectionView.reloadData()
            })
            completionHandler(true)
        }
        let config = UISwipeActionsConfiguration(actions: [deleteAction])
        config.performsFirstActionWithFullSwipe = true
        return config
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        switch indexPath.item {
        case 0:
            return CGSize(width: width, height: 560) // высота для MealInfoCell
        case 1:
            return CGSize(width: width, height: 60) // увеличена высота для IngredientsHeaderCell
        default:
            return CGSize(width: width, height: 150) // высота для IngredientCell
        }
    }
}
//
//extension Notification.Name {
//    static let mealAdded = Notification.Name("mealAdded")
//}
