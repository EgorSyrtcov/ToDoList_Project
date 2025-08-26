import Foundation
import Combine
@testable import ToDoList_Project  // Замените на имя вашего приложения

// MARK: - Mock TaskService
class MockTaskService: TaskServiceProtocol {
    
    var tasks: [Todo] = []
    var shouldThrowError = false
    
    func fetchTasksFromAPI() async throws -> [Todo] {
        if shouldThrowError {
            throw NSError(domain: "TestError", code: 1, userInfo: nil)
        }
        return tasks
    }
    
    func getLocalTasks() -> [Todo] {
        return tasks
    }
    
    func saveTasksLocally(_ tasks: [Todo]) {
        self.tasks = tasks
    }
    
    func updateTaskLocally(_ task: Todo) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
        }
    }
    
    func addTaskLocally(_ task: Todo) {
        tasks.append(task)
    }
    
    func deleteTaskLocally(_ task: Todo) {
        tasks.removeAll { $0.id == task.id }
    }
    
    func createNewTask(title: String, description: String) -> Todo {
        let newTask = Todo(
            id: (tasks.map { $0.id }.max() ?? 0) + 1,
            todo: title,
            completed: false,
            userID: 1
        )
        tasks.append(newTask)
        return newTask
    }
}

// MARK: - Mock CoreDataManager
class MockCoreDataManager: CoreDataManagerProtocol {
    
    var tasks: [Todo] = []
    
    func fetchTasks() -> [Todo] {
        return tasks
    }
    
    func saveTasks(_ tasks: [Todo]) {
        self.tasks = tasks
    }
    
    func updateTask(_ task: Todo) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
        }
    }
    
    func addTask(_ task: Todo) {
        tasks.append(task)
    }
    
    func deleteTask(_ task: Todo) {
        tasks.removeAll { $0.id == task.id }
    }
    
    func getMaxTaskId() -> Int {
        return tasks.map { $0.id }.max() ?? 0
    }
}

// MARK: - Protocols for Dependency Injection
protocol TaskServiceProtocol {
    func fetchTasksFromAPI() async throws -> [Todo]
    func getLocalTasks() -> [Todo]
    func saveTasksLocally(_ tasks: [Todo])
    func updateTaskLocally(_ task: Todo)
    func addTaskLocally(_ task: Todo)
    func deleteTaskLocally(_ task: Todo)
    func createNewTask(title: String, description: String) -> Todo
}

protocol CoreDataManagerProtocol {
    func fetchTasks() -> [Todo]
    func saveTasks(_ tasks: [Todo])
    func updateTask(_ task: Todo)
    func addTask(_ task: Todo)
    func deleteTask(_ task: Todo)
    func getMaxTaskId() -> Int
}

// MARK: - Extend real classes to conform to protocols
extension TaskService: TaskServiceProtocol {}
extension CoreDataManager: CoreDataManagerProtocol {}
