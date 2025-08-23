import UIKit
import Combine

struct ToDoListRouting {}

protocol ToDoListInput {}

protocol ToDoListOutput {
    var toDoListPublisher: AnyPublisher<ToDoList?, Never> { get }
    var errorPublisher: AnyPublisher<String, Never> { get }
    var isLoadingPublisher: AnyPublisher<Bool, Never> { get }
}

typealias ToDoListVMInterface = ToDoListInput & ToDoListOutput


final class ToDoListViewModel: ToDoListVMInterface {
    
    // MARK: - Private Properties
    
    private var routing: ToDoListRouting
    private var cancellables: Set<AnyCancellable> = []
    private let service = Service()
    
    // MARK: - Input
    
    // MARK: - Output Publishers
    private let toDoListSubject = PassthroughSubject<ToDoList?, Never>()
    private let errorSubject = PassthroughSubject<String, Never>()
    private let isLoadingSubject = CurrentValueSubject<Bool, Never>(false)
    
    
    var toDoListPublisher: AnyPublisher<ToDoList?, Never> {
        toDoListSubject.eraseToAnyPublisher()
    }
    
    var errorPublisher: AnyPublisher<String, Never> {
        errorSubject.eraseToAnyPublisher()
    }
    
    var isLoadingPublisher: AnyPublisher<Bool, Never> {
        isLoadingSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Initialization
    
    init(routing: ToDoListRouting) {
        self.routing = routing
        configureBindings()
        
        Task { await requestToDoLists() }
    }
    
    private func configureBindings() {}
    
    private func requestToDoLists() async {
        // Показываем индикатор загрузки
        isLoadingSubject.send(true)
        
        defer { isLoadingSubject.send(false) }
        
        do {
            let toDoData = try await service.execute(.getToDoListRequest(), expecting: ToDoList.self)
            
            if let toDoData = toDoData {
                print("✅ Данные успешно получены:")
                print("📋 Всего задач: \(toDoData.total)")
                print("📝 Первые 3 задачи:")
                for (index, todo) in toDoData.todos.prefix(3).enumerated() {
                    print("   \(index + 1). \(todo.todo) (завершена: \(todo.completed))")
                }
                
                // Скрываем индикатор загрузки и отправляем данные
                DispatchQueue.main.async {
                    self.toDoListSubject.send(toDoData)
                }
            } else {
                print("❌ Данные не получены или пустые")
                DispatchQueue.main.async {
                    self.errorSubject.send("Не удалось получить данные")
                }
            }
            
        } catch {
            print("❌ Ошибка при получении данных: \(error)")
            DispatchQueue.main.async {
                self.errorSubject.send("Ошибка сети: \(error.localizedDescription)")
            }
        }
    }
}
