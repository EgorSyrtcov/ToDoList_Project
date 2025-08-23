import UIKit
import Combine

final class ToDoListViewController: UIViewController {
    
    lazy private var activityIndicator: UIActivityIndicatorView = {
        var activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .red
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        return activityIndicator
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .white
        return tableView
    }()
    
    // MARK: Public
    var viewModel: ToDoListVMInterface!
    
    // MARK: Private
    private var cancellables: Set<AnyCancellable> = []
    private var toDoList: ToDoList?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        viewModelBinding()
        setupUI()
    }
    
    private func setup() {
        view.backgroundColor = .white
        title = "Список задач"
    }
    
    private func setupUI() {
        view.addSubviews(tableView, activityIndicator)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func viewModelBinding() {
        // Подписываемся на загрузку данных
        viewModel.toDoListPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] toDoList in
                self?.toDoList = toDoList
                self?.tableView.reloadData()
                print("📱 Данные получены в ViewController: \(toDoList?.todos.count ?? 0) задач")
            }
            .store(in: &cancellables)
        
        // Подписываемся на индикатор загрузки
        viewModel.isLoadingPublisher
            .sink { [weak self] in self?.update(isShown: $0) }
            .store(in: &cancellables)
        
        // Подписываемся на ошибки
        viewModel.errorPublisher
            .sink { [weak self] error in
                guard let self = self else { return }
                self.showAlert(title: error, subtitle: "") }
            .store(in: &cancellables)
    }
}

// MARK: - UITableViewDataSource
extension ToDoListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toDoList?.todos.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        if let todo = toDoList?.todos[indexPath.row] {
            cell.textLabel?.text = todo.todo
            cell.accessoryType = todo.completed ? .checkmark : .none
            cell.textLabel?.numberOfLines = 0
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ToDoListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
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
