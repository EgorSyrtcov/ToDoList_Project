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
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.placeholder = "Search"
        searchBar.searchBarStyle = .minimal
        searchBar.delegate = self
        searchBar.tintColor = .white
        if let textField = searchBar.value(forKey: "searchField") as? UITextField {
            textField.textColor = .white
            textField.attributedPlaceholder = NSAttributedString(
                string: "Search",
                attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
            )
        }
        return searchBar
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
    private var searchQuery: String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        viewModelBinding()
        setupUI()
    }
    
    private func setup() {
        view.backgroundColor = .black
        title = "Задачи"
        updateCountLabel()
    }
    
    private func setupUI() {
        view.addSubviews(searchBar, tableView, activityIndicator, titleLabel, bottomBarView)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -16),
            
            searchBar.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
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
        viewModel.toDoListPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] toDoList in
                self?.toDoList = toDoList
                self?.updateFilteredTodos()
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
    
    private func updateFilteredTodos() {
        guard let toDoList = toDoList else {
            filteredTodos = []
            return
        }
        
        if searchQuery.isEmpty {
            filteredTodos = toDoList.todos
        } else {
            filteredTodos = toDoList.todos.filter { todo in
                todo.todo.localizedCaseInsensitiveContains(searchQuery)
            }
        }
    }
    
    private func updateCountLabel() {
        let remaining = toDoList?.todos.filter { !$0.completed }.count ?? 0
        bottomBarView.updateCount(remaining)
    }
    
    @objc private func addButtonTapped() {
        // логика добавления новой задачи
        print("➕ Добавить новую задачу")
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
}

// MARK: - UISearchBarDelegate
extension ToDoListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchQuery = searchText
        updateFilteredTodos()
        tableView.reloadData()
        updateCountLabel()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
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
            onEdit: { [weak self] in self?.hideActionPopup(); print("Редактировать") },
            onShare: { [weak self] in self?.hideActionPopup(); self?.share(todo: todo) },
            onDelete: { [weak self] in self?.hideActionPopup(); print("Удалить") }
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
}
