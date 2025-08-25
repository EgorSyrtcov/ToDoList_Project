import UIKit
import Combine

struct AddTaskRouting {

}

protocol AddTaskInput {

}

protocol AddTaskOutput {

}

typealias AddTaskVMInterface = AddTaskInput & AddTaskOutput


final class AddTaskViewModel: AddTaskVMInterface {

    // MARK: - Private Properties

    private var routing: AddTaskRouting
    private var cancellables: Set<AnyCancellable> = []

    // MARK: - Input

    // MARK: - Output

    // MARK: - Initialization

    init(routing: AddTaskRouting) {
        self.routing = routing
        configureBindings()
    }

    private func configureBindings() {

    }

}
