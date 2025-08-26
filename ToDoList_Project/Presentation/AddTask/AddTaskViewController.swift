import UIKit
import Combine

final class AddTaskViewController: UIViewController {
    
    // MARK: - UI Components
    private lazy var titleTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Название задачи"
        textField.textColor = .white
        textField.backgroundColor = .black
        textField.font = UIFont.systemFont(ofSize: 34)
        textField.returnKeyType = .next
        textField.delegate = self
        textField.autocapitalizationType = .sentences
        return textField
    }()
    
    private lazy var descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.textColor = .white
        textView.backgroundColor = .black
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.layer.cornerRadius = 6
        textView.layer.masksToBounds = true
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        textView.autocapitalizationType = .sentences
        return textView
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 12)
        label.text = formattedCurrentDate()
        return label
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Сохранить", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .yellow
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: Private
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: Public
    var viewModel: AddTaskVMInterface!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        viewModelBinding()
        setupUI()
    }
    
    private func setup() {
        view.backgroundColor = .black
        setupNavigationBar()
        setupKeyboardObservers()
        populateDataIfEditing()
    }
    
    private func setupNavigationBar() {
        // Устанавливаем заголовок в зависимости от режима
        title = viewModel.isEditingMode ? "Редактировать задачу" : "Новая задача"
        
        let backButton = UIBarButtonItem()
        backButton.title = "Назад"
        backButton.tintColor = .yellow
        navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func viewModelBinding() {
        
        viewModel.errorPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                self?.showErrorAlert(message: errorMessage)
            }
            .store(in: &cancellables)
        
        viewModel.successPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] success in
                if success {
                    let message = self?.viewModel.isEditingMode == true ?
                    "Задача обновлена" : "Задача добавлена"
                    self?.showSuccessAlert(message: message)
                }
            }
            .store(in: &cancellables)
    }
    
    private func setupUI() {
        view.addSubview(scrollView)
        view.addSubview(saveButton)
        scrollView.addSubview(contentView)
        
        contentView.addSubviews(titleTextField, dateLabel, descriptionTextView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: saveButton.topAnchor, constant: -20),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // TitleTextField вверху
            titleTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            titleTextField.heightAnchor.constraint(equalToConstant: 44),
            
            // DateLabel под TitleTextField
            dateLabel.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 8),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // DescriptionTextView под DateLabel
            descriptionTextView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 16),
            descriptionTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            descriptionTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            descriptionTextView.heightAnchor.constraint(equalToConstant: 120),
            descriptionTextView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            // SaveButton прижимаем к низу экрана
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            saveButton.heightAnchor.constraint(equalToConstant: 50),
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
        
        // Настройка placeholder для TextView только если не в режиме редактирования
        if !viewModel.isEditingMode {
            descriptionTextView.delegate = self
            descriptionTextView.text = "Описание задачи (необязательно)"
            descriptionTextView.textColor = .lightGray
        }
        
        dateLabel.text = formattedCurrentDate()
    }
    
    // MARK: - Actions
    @objc private func saveButtonTapped() {
        guard let title = titleTextField.text, !title.trimmingCharacters(in: .whitespaces).isEmpty else {
            showErrorAlert(message: "Введите название задачи")
            return
        }
        
        let description = descriptionTextView.textColor == .lightGray ? "" : descriptionTextView.text
        viewModel.saveTask(
            title: title,
            description: description ?? ""
        )
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        
        let keyboardHeight = keyboardFrame.height
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
        
        // Также поднимаем кнопку если нужно
        UIView.animate(withDuration: 0.3) {
            self.saveButton.transform = CGAffineTransform(translationX: 0, y: -keyboardHeight)
        }
    }
    
    @objc private func keyboardWillHide() {
        scrollView.contentInset = .zero
        
        // Возвращаем кнопку на место
        UIView.animate(withDuration: 0.3) {
            self.saveButton.transform = .identity
        }
    }
    
    // MARK: - Alert Methods
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showSuccessAlert(message: String) {
        let alert = UIAlertController(title: "Успешно", message: message, preferredStyle: .alert)
        present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            alert.dismiss(animated: true)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

// MARK: - UITextFieldDelegate
extension AddTaskViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == titleTextField {
            descriptionTextView.becomeFirstResponder()
        }
        return true
    }
}

// MARK: - UITextViewDelegate
extension AddTaskViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .lightGray {
            textView.text = nil
            textView.textColor = .white
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Описание задачи (необязательно)"
            textView.textColor = .lightGray
        }
    }
}

extension AddTaskViewController {
    
    private func populateDataIfEditing() {
        guard let task = viewModel.taskForEditing else { return }
        
        // Заполняем поля данными задачи
        titleTextField.text = task.todo
        
        // Заполняем описание, если оно есть
        if !task.description.isEmpty {
            descriptionTextView.text = task.description
            descriptionTextView.textColor = .white
        } else {
            descriptionTextView.text = "Описание задачи (необязательно)"
            descriptionTextView.textColor = .lightGray
        }
        descriptionTextView.delegate = self
        
        // Обновляем дату если нужно
        dateLabel.text = formattedCurrentDate()
        
        // Меняем текст кнопки для режима редактирования
        saveButton.setTitle("Сохранить изменения", for: .normal)
    }
    
    private func formattedCurrentDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yy"
        return dateFormatter.string(from: Date())
    }
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
}
