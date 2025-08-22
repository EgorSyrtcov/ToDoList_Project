import UIKit
import Combine

final class AppCoordinator: Coordinator {
    
    let window: UIWindow
    var childCoordinators: [Coordinator] = []
    
    init(window: UIWindow) {
        self.window = window
    }
    
    private var cancellables: Set<AnyCancellable> = []
    
    func start() {
            showToDoListCoordinator()
    }

    private func showToDoListCoordinator() {
        let toDoListCoordinator = ToDoListCoordinator()
        toDoListCoordinator.start()
        childCoordinators = [toDoListCoordinator]
        window.rootViewController = toDoListCoordinator.navigationController
    }
    
    private func removeChildCoordinator(_ coordinator: Coordinator) {
        if let index = childCoordinators.firstIndex(where: { $0 === coordinator }) {
            childCoordinators.remove(at: index)
        }
    }
}

