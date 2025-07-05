import UIKit
import SnapKit
import AVFoundation
import Photos

final class AddMealSheetViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    private let stackView = UIStackView()
    private var capturedImage: UIImage?
    private var photoPicker: UIImagePickerController? // ленивое хранение галереи
    private let activityIndicator = UIActivityIndicatorView(style: .large)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        preparePhotoPicker()  // добавлено
        setupActivityIndicator()
    }

    private func setupUI() {
        view.backgroundColor = .white

        let grabber = UIView()
        grabber.backgroundColor = UIColor(white: 0.85, alpha: 1)
        grabber.layer.cornerRadius = 3
        view.addSubview(grabber)
        grabber.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(40)
            $0.height.equalTo(6)
        }

        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .fill
        view.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.top.equalTo(grabber.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(24)
        }

        addOption(title: "Camera", iconName: "camera")
        addOption(title: "Gallery", iconName: "photo.on.rectangle")
        addOption(title: "Enter Manually", iconName: "pencil")
    }

    private func addOption(title: String, iconName: String) {
        let icon = UIImageView(image: UIImage(systemName: iconName))
        icon.contentMode = .scaleAspectFit
        icon.tintColor = .black
        icon.snp.makeConstraints { $0.width.height.equalTo(24) }

        let label = UILabel()
        label.text = title
        label.font = Fonts.font(size: 16, weight: .regular)
        label.textColor = .black

        let row = UIStackView(arrangedSubviews: [icon, label])
        row.axis = .horizontal
        row.spacing = 12
        row.alignment = .center

        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(row)
        row.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
        }

        container.tag = title.hash
        container.isUserInteractionEnabled = true
        container.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(optionTapped(_:))))

        let separator = UIView()
        separator.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        container.addSubview(separator)
        separator.snp.makeConstraints {
            $0.top.equalTo(row.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(1)
            $0.bottom.equalToSuperview()
        }

        stackView.addArrangedSubview(container)
    }

    @objc private func optionTapped(_ gesture: UITapGestureRecognizer) {
        guard let row = gesture.view else { return }

        if row.tag == "Camera".hash {
            requestCameraAccessAndPresent()
        } else if row.tag == "Gallery".hash {
            requestGalleryAccessAndPresent()
        } else if row.tag == "Enter Manually".hash {
            let manuallyAddMealVC = ManuallyAddMealViewController()
            let navController = UINavigationController(rootViewController: manuallyAddMealVC)
            navController.modalPresentationStyle = .fullScreen
            present(navController, animated: true)
        }
    }

    private func requestCameraAccessAndPresent() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            presentCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    if granted {
                        self?.presentCamera()
                    } else {
                        self?.showCameraAccessDeniedAlert()
                    }
                }
            }
        default:
            showCameraAccessDeniedAlert()
        }
    }

    private func presentCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            print("Камера недоступна")
            return
        }

        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        present(picker, animated: true)
    }

    private func showCameraAccessDeniedAlert() {
        let alert = UIAlertController(
            title: "Нет доступа к камере",
            message: "Разрешите доступ к камере в настройках",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }



    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            picker.dismiss(animated: true) {
                self.activityIndicator.startAnimating()
                Task {
                    do {
                        let meal = try await APIService.shared.analyzeMealPhoto(image: image)
                        DispatchQueue.main.async {
                            self.activityIndicator.stopAnimating()
                            let addMealVC = AddMealViewController(image: image, meal: meal)
                            addMealVC.modalPresentationStyle = .fullScreen
                            self.present(addMealVC, animated: true)
                        }
                    } catch {
                        DispatchQueue.main.async {
                            self.activityIndicator.stopAnimating()
                            let alert = UIAlertController(title: "Ошибка", message: "Не удалось получить данные блюда.", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default))
                            self.present(alert, animated: true)
                        }
                    }
                }
            }
            return
        }
        picker.dismiss(animated: true)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    private func requestGalleryAccessAndPresent() {
        let status = PHPhotoLibrary.authorizationStatus()
        if status == .authorized || status == .limited {
            presentPhotoPicker()
        } else if status == .notDetermined {
            PHPhotoLibrary.requestAuthorization { [weak self] newStatus in
                DispatchQueue.main.async {
                    if newStatus == .authorized || newStatus == .limited {
                        self?.presentPhotoPicker()
                    } else {
                        self?.showGalleryAccessDeniedAlert()
                    }
                }
            }
        } else {
            showGalleryAccessDeniedAlert()
        }
    }
    
    private func setupActivityIndicator() {
        view.addSubview(activityIndicator)
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
    }

    private func presentPhotoPicker() {
        guard let picker = photoPicker else {
            preparePhotoPicker()
            if let picker = photoPicker {
                present(picker, animated: true)
            }
            return
        }
        present(picker, animated: true)
    }

    private func preparePhotoPicker() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else { return }
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = false
        self.photoPicker = picker
    }

    private func showGalleryAccessDeniedAlert() {
        let alert = UIAlertController(
            title: "Нет доступа к фото",
            message: "Разрешите доступ к фото в настройках",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // Новый публичный метод для анализа текста и показа AddMealViewController
    public func analyzeTextAndShowAddMeal(text: String) {
        Task {
            do {
                let meal = try await APIService.shared.analyzeMealText(description: text)
                DispatchQueue.main.async {
                    let addMealVC = AddMealViewController(image: UIImage(named: "meal_ph")! , meal: meal)
                    addMealVC.modalPresentationStyle = .fullScreen
                    self.present(addMealVC, animated: true)
                }
            } catch {
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Ошибка", message: "Не удалось получить данные блюда.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                }
            }
        }
    }
}

   
