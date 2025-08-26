import UIKit
import Combine

struct ToDoListRouting {
    let addTaskButtonDidTapSubject = PassthroughSubject<Void, Never>()
}

protocol ToDoListInput {
    var addTaskDidTapSubject: PassthroughSubject<Void, Never> { get }
    func toggleTaskCompletion(_ task: Todo)
    func deleteTaskCompletion(_ task: Todo)
    func updateSearchQuery(_ query: String)
    func updateFilteredTodos()
    func reloadTableView()
}

protocol ToDoListOutput {
    var toDoListPublisher: AnyPublisher<ToDoList?, Never> { get }
    var errorPublisher: AnyPublisher<String, Never> { get }
    var isLoadingPublisher: AnyPublisher<Bool, Never> { get }
    var filteredTodosPublisher: AnyPublisher<[Todo], Never> { get }
}

typealias ToDoListVMInterface = ToDoListInput & ToDoListOutput


final class ToDoListViewModel: ToDoListVMInterface {
    
    // MARK: - Private Properties
    
    private var routing: ToDoListRouting
    private var cancellables: Set<AnyCancellable> = []
    private let taskService = TaskService()
    private var searchQuery: String = ""
    private var filteredTodos: [Todo] = []
    
    // MARK: - Data
    private var currentToDoList: ToDoList?
    
    // MARK: - Input
    var addTaskDidTapSubject = PassthroughSubject<Void, Never>()
    
    // MARK: - Output Publishers
    private let toDoListSubject = PassthroughSubject<ToDoList?, Never>()
    private let errorSubject = PassthroughSubject<String, Never>()
    private let isLoadingSubject = CurrentValueSubject<Bool, Never>(false)
    private let filteredTodosSubject = PassthroughSubject<[Todo], Never>()
    
    
    var toDoListPublisher: AnyPublisher<ToDoList?, Never> {
        toDoListSubject.eraseToAnyPublisher()
    }
    
    var errorPublisher: AnyPublisher<String, Never> {
        errorSubject.eraseToAnyPublisher()
    }
    
    var isLoadingPublisher: AnyPublisher<Bool, Never> {
        isLoadingSubject.eraseToAnyPublisher()
    }
    
    var filteredTodosPublisher: AnyPublisher<[Todo], Never> {
        filteredTodosSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Initialization
    
    init(routing: ToDoListRouting) {
        self.routing = routing
        configureBindings()
    }
    
    private func configureBindings() {
        Task { await requestToDoLists() }
        
        addTaskDidTapSubject
            .sink { [weak self] _ in
                self?.routing.addTaskButtonDidTapSubject.send()
            }
            .store(in: &cancellables)
    }
    
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
                self.updateFilteredTodos()
            }
            
            print("🔄 Статус задачи изменен: \(toDoList.todos[index].todo) - \(toDoList.todos[index].completed ? "выполнена" : "не выполнена")")
        } else {
            print("❌ Задача с ID \(task.id) не найдена в списке")
        }
    }
    
    func deleteTaskCompletion(_ task: Todo) {
        taskService.deleteTaskLocally(task)
        
        let updatedTasks = taskService.getLocalTasks()
        let updatedToDoList = ToDoList(todos: updatedTasks,
                                       total: updatedTasks.count,
                                       skip: 0,
                                       limit: updatedTasks.count)
        currentToDoList = updatedToDoList
        
        DispatchQueue.main.async {
            self.toDoListSubject.send(updatedToDoList)
            self.updateFilteredTodos()
        }
    }
    
    func updateSearchQuery(_ query: String) {
        searchQuery = query
        updateFilteredTodos()
    }
    
    func reloadTableView() {
        Task { await requestToDoLists() }
    }
    
    func updateFilteredTodos() {
        guard let toDoList = currentToDoList else {
            filteredTodos = []
            filteredTodosSubject.send(filteredTodos)
            return
        }
        
        if searchQuery.isEmpty {
            filteredTodos = toDoList.todos
        } else {
            filteredTodos = toDoList.todos.filter { todo in
                todo.todo.localizedCaseInsensitiveContains(searchQuery)
            }
        }
        filteredTodosSubject.send(filteredTodos)
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
                
                let toDoList = ToDoList(todos: apiTasks,
                                        total: apiTasks.count,
                                        skip: 0,
                                        limit: apiTasks.count)
                currentToDoList = toDoList
                DispatchQueue.main.async {
                    self.toDoListSubject.send(toDoList)
                    self.updateFilteredTodos()
                }
            } else {
                // Если есть локальные данные, используем их
                print("📱 Загружены локальные данные: \(localTasks.count) задач")
                let toDoList = ToDoList(todos: localTasks,
                                        total: localTasks.count,
                                        skip: 0,
                                        limit: localTasks.count)
                currentToDoList = toDoList
                
                DispatchQueue.main.async {
                    self.toDoListSubject.send(toDoList)
                    self.updateFilteredTodos()
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
