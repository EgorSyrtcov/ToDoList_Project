import UIKit
import Combine

struct AddTaskRouting {
    let onDismissTapSubject = PassthroughSubject<Void, Never>()
}

protocol AddTaskInput {
    func saveTask(title: String, description: String)
}

protocol AddTaskOutput {
    var errorPublisher: AnyPublisher<String, Never> { get }
    var successPublisher: AnyPublisher<Bool, Never> { get }
}

typealias AddTaskVMInterface = AddTaskInput & AddTaskOutput


final class AddTaskViewModel: AddTaskVMInterface {
    
    // MARK: - Private Properties
    private var routing: AddTaskRouting
    private var cancellables: Set<AnyCancellable> = []
    private let taskService = TaskService()
    
    // MARK: - Input
    
    // MARK: - Output Publishers
    private let errorSubject = PassthroughSubject<String, Never>()
    private let successSubject = PassthroughSubject<Bool, Never>()
    
    var errorPublisher: AnyPublisher<String, Never> {
        errorSubject.eraseToAnyPublisher()
    }
    
    var successPublisher: AnyPublisher<Bool, Never> {
        successSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Initialization
    
    init(routing: AddTaskRouting) {
        self.routing = routing
        configureBindings()
    }
    
    private func configureBindings() {
        
    }
    
    // MARK: - Input Methods
    func saveTask(title: String, description: String) {
        // Валидация
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorSubject.send("Название задачи не может быть пустым")
            return
        }
        
        // Создание и сохранение новой задачи через сервис
        let newTask = taskService.createNewTask(title: title, description: description)
        
        print("✅ Новая задача создана: \(newTask.todo)")
        
        // Уведомление об успехе
        successSubject.send(true)
        
        // Закрытие экрана с небольшой задержкой
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.routing.onDismissTapSubject.send()
        }
    }
}
