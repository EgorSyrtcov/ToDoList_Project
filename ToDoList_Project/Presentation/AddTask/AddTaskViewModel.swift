import UIKit
import Combine

struct AddTaskRouting {
    let onDismissTapSubject = PassthroughSubject<Void, Never>()
}

protocol AddTaskInput {
    func saveTask(title: String, description: String)
    func setTaskForEditing(_ task: Todo?)
}

protocol AddTaskOutput {
    var errorPublisher: AnyPublisher<String, Never> { get }
    var successPublisher: AnyPublisher<Bool, Never> { get }
    var taskForEditing: Todo? { get }
    var isEditingMode: Bool { get }
}

typealias AddTaskVMInterface = AddTaskInput & AddTaskOutput


final class AddTaskViewModel: AddTaskVMInterface {
    
    // MARK: - Private Properties
    internal var routing: AddTaskRouting
    private var cancellables: Set<AnyCancellable> = []
    private let taskService = TaskService()
    private var editingTask: Todo?
    
    // MARK: - Output
    var taskForEditing: Todo? {
        editingTask
    }
    
    var isEditingMode: Bool {
        editingTask != nil
    }
    
    // MARK: - Output Publishers
    private let errorSubject = PassthroughSubject<String, Never>()
    private let successSubject = PassthroughSubject<Bool, Never>()
    private let taskForEditingSubject = CurrentValueSubject<Todo?, Never>(nil)
    
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
    
    func setTaskForEditing(_ task: Todo?) {
        editingTask = task
    }
    
    func saveTask(title: String, description: String) {
        // Валидация
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorSubject.send("Название задачи не может быть пустым")
            return
        }
        
        if let editingTask = editingTask {
            // Редактирование существующей задачи
            updateExistingTask(editingTask, newTitle: title, newDescription: description)
        } else {
            // Создание новой задачи
            createNewTask(title: title, description: description)
        }
        
        // Закрытие экрана с небольшой задержкой
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.routing.onDismissTapSubject.send()
        }
    }
    
    private func createNewTask(title: String, description: String) {
           let newTask = taskService.createNewTask(title: title, description: description)
           print("✅ Новая задача создана: \(newTask.todo)")
           successSubject.send(true)
       }
    
    private func updateExistingTask(_ task: Todo, newTitle: String, newDescription: String) {
            var updatedTask = task
            updatedTask.todo = newTitle
            updatedTask.description = newDescription
            
            taskService.updateTaskLocally(updatedTask)
            print("✏️ Задача обновлена: \(updatedTask.todo)")
            successSubject.send(true)
        }
}
