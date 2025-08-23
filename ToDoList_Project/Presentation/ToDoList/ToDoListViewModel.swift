import UIKit
import Combine

struct ToDoListRouting {}

protocol ToDoListInput {
    func toggleTaskCompletion(_ task: Todo)
}

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
    private let taskService = TaskService()
    
    // MARK: - Data
    private var currentToDoList: ToDoList?
    
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
    
    // MARK: - Input
    
    func toggleTaskCompletion(_ task: Todo) {
            guard var toDoList = currentToDoList else {
                print("❌ currentToDoList is nil")
                return
            }
            
            if let index = toDoList.todos.firstIndex(where: { $0.id == task.id }) {
                toDoList.todos[index].completed.toggle()
                currentToDoList = toDoList
                
                // Сохраняем изменения в CoreData
                taskService.updateTaskLocally(toDoList.todos[index])
                
                DispatchQueue.main.async {
                    self.toDoListSubject.send(toDoList)
                }
                
                print("🔄 Статус задачи изменен: \(toDoList.todos[index].todo) - \(toDoList.todos[index].completed ? "выполнена" : "не выполнена")")
            } else {
                print("❌ Задача с ID \(task.id) не найдена в списке")
            }
        }
    
    private func requestToDoLists() async {
        isLoadingSubject.send(true)
        
        defer { isLoadingSubject.send(false) }
        
        do {
            // Сначала проверяем локальные данные
            let localTasks = taskService.getLocalTasks()
            
            if localTasks.isEmpty {
                // Если локальных данных нет, загружаем с API
                print("📱 Локальных данных нет, загружаем с API...")
                let apiTasks = try await taskService.fetchTasksFromAPI()
                taskService.saveTasksLocally(apiTasks)
                
                let toDoList = ToDoList(todos: apiTasks, total: apiTasks.count, skip: 0, limit: apiTasks.count)
                currentToDoList = toDoList
                DispatchQueue.main.async {
                    self.toDoListSubject.send(toDoList)
                }
            } else {
                // Если есть локальные данные, используем их
                print("📱 Загружены локальные данные: \(localTasks.count) задач")
                let toDoList = ToDoList(todos: localTasks, total: localTasks.count, skip: 0, limit: localTasks.count)
                currentToDoList = toDoList
                
                DispatchQueue.main.async {
                    self.toDoListSubject.send(toDoList)
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
