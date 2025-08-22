import UIKit
import Combine

struct ToDoListRouting {

}

protocol ToDoListInput {

}

protocol ToDoListOutput {

}

typealias ToDoListVMInterface = ToDoListInput & ToDoListOutput


final class ToDoListViewModel: ToDoListVMInterface {

    // MARK: - Private Properties

    private var routing: ToDoListRouting
    private var cancellables: Set<AnyCancellable> = []

    // MARK: - Input

    // MARK: - Output

    // MARK: - Initialization

    init(routing: ToDoListRouting) {
        self.routing = routing
        configureBindings()
    }

    private func configureBindings() {

    }

}
