import Foundation
import Combine

final class TaskService {
    
    private let apiService = Service()
    private let coreDataManager = CoreDataManager.shared
    
    // MARK: - API Operations
    
    func fetchTasksFromAPI() async throws -> [Todo] {
        let toDoData = try await apiService.execute(.getToDoListRequest(), expecting: ToDoList.self)
        
        if let toDoData = toDoData {
            print("🌐 Получено \(toDoData.todos.count) задач с API")
            return toDoData.todos
        } else {
            throw Service.ServiceError.failedToGetData
        }
    }
    
    // MARK: - Local Operations
    
    func getLocalTasks() -> [Todo] {
        return coreDataManager.fetchTasks()
    }
    
    func saveTasksLocally(_ tasks: [Todo]) {
        coreDataManager.saveTasks(tasks)
    }
    
    func updateTaskLocally(_ task: Todo) {
        coreDataManager.updateTask(task)
    }
    
    func addTaskLocally(_ task: Todo) {
        coreDataManager.addTask(task)
    }
    
    func deleteTaskLocally(_ task: Todo) {
        coreDataManager.deleteTask(task)
    }
    
    func createNewTask(title: String, description: String) -> Todo {
        let maxId = coreDataManager.getMaxTaskId()
        let newTask = Todo(
            id: maxId + 1,
            todo: title,
            completed: false,
            userID: 1
        )
        
        addTaskLocally(newTask)
        return newTask
    }
}
