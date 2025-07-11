import UIKit

final class CustomTabbar: UITabBar {

    private let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.layer.cornerRadius = 32
        view.layer.masksToBounds = true
        return view
    }()

    private let backgroundCircle: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.layer.cornerRadius = 40 // круг побольше, радиус = половина размера
        view.layer.masksToBounds = true
        return view
    }()

    private let addButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = .white
        button.layer.cornerRadius = 30 // Кнопка 60x60
        button.layer.masksToBounds = true

        let plus = UIImage(systemName: "plus")?.withRenderingMode(.alwaysTemplate)
        button.setImage(plus, for: .normal)
        button.tintColor = Colors.orange

        // Убираем imageEdgeInsets, чтобы не сужать область клика
        button.imageEdgeInsets = .zero
        // Убираем contentEdgeInsets
        button.contentEdgeInsets = .zero

        // Для безопасности включаем пользовательское взаимодействие (обычно true по умолчанию)
        button.isUserInteractionEnabled = true

        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        backgroundImage = UIImage()
        shadowImage = UIImage()

        addSubview(backgroundView)
        addSubview(backgroundCircle)
        addSubview(addButton)

        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let bgHeight: CGFloat = 70
        let bgY = bounds.height - bgHeight - 25 // Поднимаем таббар выше на 25 пикселей
        backgroundView.frame = CGRect(x: 10, y: bgY, width: bounds.width - 20, height: bgHeight)

        // Размер большого круга под кнопкой "плюс"
        let circleSize: CGFloat = 80
        let circleX = (bounds.width - circleSize) / 2
        // Центр круга совпадает с центром кнопки, круг выступает из таббара на четверть
        let circleY = bgY - (circleSize * 1/4)
        backgroundCircle.frame = CGRect(x: circleX, y: circleY, width: circleSize, height: circleSize)

        // Размер кнопки "плюс"
        let buttonSize: CGFloat = 60
        let buttonX = (bounds.width - buttonSize) / 2
        let buttonY = circleY + (circleSize - buttonSize)/2 // центрируем кнопку по вертикали круга
        addButton.frame = CGRect(x: buttonX, y: buttonY, width: buttonSize, height: buttonSize)

        // Расположение табов - сдвигаем чтобы было место для кнопки
        let tabBarButtonWidth = (bounds.width - buttonSize) / 2
        var index = 0

        for subview in subviews {
            if let className = NSClassFromString("UITabBarButton"), subview.isKind(of: className) {
                var frame = subview.frame
                frame.origin.y = backgroundView.frame.midY - frame.height / 2
                if index == 0 {
                    frame.origin.x = 0
                    frame.size.width = tabBarButtonWidth
                } else if index == 1 {
                    frame.origin.x = tabBarButtonWidth + buttonSize
                    frame.size.width = tabBarButtonWidth
                }
                subview.frame = frame
                index += 1
            }
        }
    }

    @objc private func addButtonTapped() {
        // Проверка подписки перед переходом к добавлению
        if !SubscriptionHandler.shared.hasActiveSubscription {
            let paywall = PaywallViewController()
            UIApplication.shared.windows.first(where: \.isKeyWindow)?
                .rootViewController?
                .navigationController?
                .pushViewController(paywall, animated: true)
            return
        }
        guard let window = UIApplication.shared.windows.first(where: \.isKeyWindow) else { return }
        let addMealVC = AddMealSheetViewController()
        addMealVC.modalPresentationStyle = .pageSheet
        if let sheet = addMealVC.sheetPresentationController {
            sheet.detents = [.custom(resolver: { _ in 210 })]
        }
        window.rootViewController?.present(addMealVC, animated: true)
    }

}

