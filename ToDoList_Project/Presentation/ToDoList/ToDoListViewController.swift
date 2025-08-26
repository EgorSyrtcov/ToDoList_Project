import UIKit
import Combine

final class ToDoListViewController: UIViewController {
    
    lazy private var activityIndicator: UIActivityIndicatorView = {
        var activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .white
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        return activityIndicator
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.registerClassForCell(TaskTableViewCell.self)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .black
        tableView.separatorColor = .darkGray
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 52, bottom: 0, right: 0)
        return tableView
    }()
    
    private lazy var searchContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(white: 0.12, alpha: 1.0)
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        return view
    }()
    
    private lazy var searchIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "magnifyingglass")
        imageView.tintColor = .lightGray
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var searchTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Search"
        textField.textColor = .white
        textField.backgroundColor = .clear
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.returnKeyType = .search
        textField.clearButtonMode = .whileEditing
        textField.attributedPlaceholder = NSAttributedString(
            string: "Search",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
        )
        textField.addTarget(self, action: #selector(searchTextDidChange), for: .editingChanged)
        textField.delegate = self
        return textField
    }()
    
    private lazy var microphoneButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "mic.fill"), for: .normal)
        button.tintColor = .lightGray
        button.addTarget(self, action: #selector(microphoneButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var bottomBarView: BottomBarView = {
        let v = BottomBarView()
        v.onAddTapped = { [weak self] in self?.addButtonTapped() }
        return v
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Задачи"
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var blurView: UIVisualEffectView?
    private var previewContainer: UIView?
    private var actionsContainer: UIView?
    
    // MARK: Public
    var viewModel: ToDoListVMInterface!
    
    // MARK: Private
    private var cancellables: Set<AnyCancellable> = []
    private var toDoList: ToDoList?
    private var filteredTodos: [Todo] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        viewModelBinding()
        setupUI()
    }
    
    private func setup() {
        view.backgroundColor = .black
        updateCountLabel()
    }
    
    private func setupUI() {
        view.addSubviews(searchContainerView, tableView, activityIndicator, titleLabel, bottomBarView)
        searchContainerView.addSubviews(searchIconImageView, searchTextField, microphoneButton)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -16),
            
            // Search container
            searchContainerView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            searchContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchContainerView.heightAnchor.constraint(equalToConstant: 40),
            
            // Search icon
            searchIconImageView.leadingAnchor.constraint(equalTo: searchContainerView.leadingAnchor, constant: 12),
            searchIconImageView.centerYAnchor.constraint(equalTo: searchContainerView.centerYAnchor),
            searchIconImageView.widthAnchor.constraint(equalToConstant: 20),
            searchIconImageView.heightAnchor.constraint(equalToConstant: 20),
            
            // Search text field
            searchTextField.leadingAnchor.constraint(equalTo: searchIconImageView.trailingAnchor, constant: 8),
            searchTextField.trailingAnchor.constraint(equalTo: microphoneButton.leadingAnchor, constant: -8),
            searchTextField.centerYAnchor.constraint(equalTo: searchContainerView.centerYAnchor),
            
            // Microphone button
            microphoneButton.trailingAnchor.constraint(equalTo: searchContainerView.trailingAnchor, constant: -12),
            microphoneButton.centerYAnchor.constraint(equalTo: searchContainerView.centerYAnchor),
            microphoneButton.widthAnchor.constraint(equalToConstant: 20),
            microphoneButton.heightAnchor.constraint(equalToConstant: 20),
            
            tableView.topAnchor.constraint(equalTo: searchContainerView.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomBarView.topAnchor),
            
            bottomBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomBarView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func viewModelBinding() {
        
        viewModel.filteredTodosPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] filteredTodos in
                self?.filteredTodos = filteredTodos
                self?.tableView.reloadData()
                self?.updateCountLabel()
            }
            .store(in: &cancellables)
        
        viewModel.toDoListPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] toDoList in
                self?.toDoList = toDoList
                self?.tableView.reloadData()
                self?.updateCountLabel()
            }
            .store(in: &cancellables)
        
        viewModel.isLoadingPublisher
            .sink { [weak self] in self?.update(isShown: $0) }
            .store(in: &cancellables)
        
        viewModel.errorPublisher
            .sink { [weak self] error in
                guard let self = self else { return }
                self.showAlert(title: error, subtitle: "")
            }
            .store(in: &cancellables)
    }
    
    private func updateCountLabel() {
        let remaining = toDoList?.todos.filter { !$0.completed }.count ?? 0
        bottomBarView.updateCount(remaining)
    }
    
    @objc private func addButtonTapped() {
        viewModel.addTaskDidTapSubject.send()
    }
}

// MARK: - UITableViewDataSource
extension ToDoListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredTodos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath) as TaskTableViewCell
        
        let todo = filteredTodos[indexPath.row]
        cell.configure(with: todo)
        cell.onCheckboxTapped = { [weak self] updatedTodo in
            self?.viewModel.toggleTaskCompletion(updatedTodo)
            self?.updateCountLabel()
        }
        
        cell.onLongPress = { [weak self] longPressedTodo in
            self?.showActionPopup(for: longPressedTodo)
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ToDoListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let todo = filteredTodos[indexPath.row]
        
        // При нажатии на ячейку меняем статус задачи
        viewModel.toggleTaskCompletion(todo)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
}

// MARK: - UITextFieldDelegate
extension ToDoListViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - Search Actions
extension ToDoListViewController {
    @objc private func searchTextDidChange() {
        viewModel.updateSearchQuery(searchTextField.text ?? "")
    }
    
    @objc private func microphoneButtonTapped() {
        // Здесь можно добавить функциональность голосового поиска
        print("🎤 Microphone button tapped")
        // Пока просто покажем alert
        let alert = UIAlertController(title: "Voice Search", message: "Voice search functionality would be implemented here", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension ToDoListViewController {
    
    private func update(isShown: Bool) {
        DispatchQueue.main.async {
            if isShown {
                self.activityIndicator.startAnimating()
            }
            else {
                self.activityIndicator.stopAnimating()
            }
        }
    }
    
    private func showAlert(title: String?, subtitle: String?, completion: (() -> Void)? = nil) {
        if title == nil {
            return
        }
        
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: subtitle, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in completion?() }))
            self.present(alert, animated: true)
        }
    }
    
    private func showActionPopup(for todo: Todo) {
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blur.translatesAutoresizingMaskIntoConstraints = false
        blur.alpha = 0.0
        view.addSubview(blur)
        NSLayoutConstraint.activate([
            blur.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blur.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            blur.topAnchor.constraint(equalTo: view.topAnchor),
            blur.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        self.blurView = blur
        
        let preview = TaskPreviewView()
        preview.configure(with: todo)
        view.addSubview(preview)
        self.previewContainer = preview
        
        let actions = ActionsPopupView(
            onEdit: { [weak self] in self?.hideActionPopup(); self?.edit(todo: todo) },
            onShare: { [weak self] in self?.hideActionPopup(); self?.share(todo: todo) },
            onDelete: { [weak self] in self?.hideActionPopup(); self?.delete(todo: todo) }
        )
        view.addSubview(actions)
        self.actionsContainer = actions
        
        NSLayoutConstraint.activate([
            preview.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            preview.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            preview.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            
            actions.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            actions.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            actions.topAnchor.constraint(equalTo: preview.bottomAnchor, constant: 16)
        ])
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideActionPopup))
        blur.addGestureRecognizer(tap)
        UIView.animate(withDuration: 0.2) { blur.alpha = 1.0 }
    }
    
    // ToDoListViewController.swift — скрытие и share
    @objc private func hideActionPopup() {
        UIView.animate(withDuration: 0.2, animations: {
            self.blurView?.alpha = 0.0
        }, completion: { _ in
            self.blurView?.removeFromSuperview()
            self.previewContainer?.removeFromSuperview()
            self.actionsContainer?.removeFromSuperview()
            self.blurView = nil
            self.previewContainer = nil
            self.actionsContainer = nil
        })
    }
    
    private func share(todo: Todo) {
        let text = todo.todo
        let vc = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        present(vc, animated: true)
    }
    
    private func delete(todo: Todo) {
        viewModel.deleteTaskCompletion(todo)
    }
    
    private func edit(todo: Todo) {
        viewModel.editTaskDidTapSubject.send(todo)
    }
}
