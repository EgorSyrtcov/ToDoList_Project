import UIKit
import Combine

final class ToDoListCoordinator: Coordinator {
    
    var navigationController = UINavigationController()
    
    private var cancellables: Set<AnyCancellable> = []
    
    func start() {
        showToDoListController()
    }
    
    private func showToDoListController() {
        let routing = ToDoListRouting()
        let toDoListViewModel = ToDoListViewModel(routing: routing)
        
        let toDoListViewController = ToDoListViewController()
        toDoListViewController.viewModel = toDoListViewModel
        navigationController.setViewControllers([toDoListViewController], animated: false)
        
        routing.addTaskButtonDidTapSubject
            .sink { [weak self] movie in
                self?.showAddTaskViewController()
            }.store(in: &cancellables)
    }
    
    private func showAddTaskViewController() {
        let addTaskRouting = AddTaskRouting()
        addTaskRouting.onDismissTapSubject
            .sink { [weak self] _ in
                if let toDoListVC = self?.navigationController.viewControllers.first as? ToDoListViewController {
                    toDoListVC.viewModel.reloadTableView()
                }
                self?.navigationController.popViewController(animated: true)
            }.store(in: &cancellables)
        
        let addTaskViewModel = AddTaskViewModel(routing: addTaskRouting)
        let addTaskViewController = AddTaskViewController()
        addTaskViewController.viewModel = addTaskViewModel
        navigationController.pushViewController(addTaskViewController, animated: true)
    }
}

