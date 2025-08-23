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
    
    private lazy var addButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addButtonTapped)
        )
        button.tintColor = .white
        return button
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Задачи"
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
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
        navigationItem.rightBarButtonItem = addButton
    }
    
    private func setupUI() {
        view.addSubviews(searchBar, tableView, activityIndicator, titleLabel)
        
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
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
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
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let todo = filteredTodos[indexPath.row]
            // Здесь будет логика удаления задачи
            print("🗑️ Удалить задачу: \(todo.todo)")
        }
    }
}

// MARK: - UISearchBarDelegate
extension ToDoListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchQuery = searchText
        updateFilteredTodos()
        tableView.reloadData()
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
}
