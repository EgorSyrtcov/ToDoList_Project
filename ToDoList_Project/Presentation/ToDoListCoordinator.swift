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
    }
}

