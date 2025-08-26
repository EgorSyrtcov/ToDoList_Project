import CoreData
import Foundation

final class CoreDataManager {
    
    // MARK: - Singleton
    static let shared = CoreDataManager()
    
    // MARK: - Core Data stack
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TaskEntity")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // MARK: - Core Data Saving support
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
                print("✅ CoreData контекст сохранен успешно")
            } catch {
                let nsError = error as NSError
                print("❌ Ошибка сохранения CoreData: \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    // MARK: - Task Operations
    
    func saveTasks(_ tasks: [Todo]) {
        // Очищаем существующие задачи
        deleteAllTasks()
        
        // Сохраняем новые задачи
        for task in tasks {
            let taskEntity = TaskEntity(context: context)
            taskEntity.taskId = Int32(task.id)
            taskEntity.title = task.todo
            taskEntity.taskDescription = task.description
            taskEntity.completed = task.completed
            taskEntity.userId = Int32(task.userID)
            taskEntity.createdAt = Date()
        }
        
        saveContext()
        print("💾 Сохранено \(tasks.count) задач в CoreData")
    }
    
    func fetchTasks() -> [Todo] {
        let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        do {
            let taskEntities = try context.fetch(request)
            let todos = taskEntities.map { entity in
                Todo(
                    id: Int(entity.taskId),
                    todo: entity.title ?? "",
                    description: entity.taskDescription ?? "",
                    completed: entity.completed,
                    userID: Int(entity.userId)
                )
            }
            print("📖 Загружено \(todos.count) задач из CoreData")
            return todos
        } catch {
            print("❌ Ошибка загрузки из CoreData: \(error)")
            return []
        }
    }
    
    func updateTask(_ task: Todo) {
        let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        request.predicate = NSPredicate(format: "taskId == %d", task.id)
        
        do {
            let taskEntities = try context.fetch(request)
            if let taskEntity = taskEntities.first {
                taskEntity.completed = task.completed
                taskEntity.title = task.todo
                taskEntity.taskDescription = task.description
                saveContext()
                print("🔄 Задача обновлена в CoreData: \(task.todo)")
            }
        } catch {
            print("❌ Ошибка обновления задачи в CoreData: \(error)")
        }
    }
    
    func addTask(_ task: Todo) {
        let taskEntity = TaskEntity(context: context)
        taskEntity.taskId = Int32(task.id)
        taskEntity.title = task.todo
        taskEntity.taskDescription = task.description
        taskEntity.completed = task.completed
        taskEntity.userId = Int32(task.userID)
        taskEntity.createdAt = Date()
        
        saveContext()
        print("➕ Добавлена новая задача в CoreData: \(task.todo)")
    }
    
    func deleteTask(_ task: Todo) {
        let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        request.predicate = NSPredicate(format: "taskId == %d", task.id)
        
        do {
            let taskEntities = try context.fetch(request)
            if let taskEntity = taskEntities.first {
                context.delete(taskEntity)
                saveContext()
                print("��️ Задача удалена из CoreData: \(task.todo)")
            }
        } catch {
            print("❌ Ошибка удаления задачи из CoreData: \(error)")
        }
    }
    
    private func deleteAllTasks() {
        let request: NSFetchRequest<NSFetchRequestResult> = TaskEntity.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        
        do {
            try context.execute(deleteRequest)
            print("🗑️ Все задачи удалены из CoreData")
        } catch {
            print("❌ Ошибка удаления всех задач из CoreData: \(error)")
        }
    }
    
    func getMaxTaskId() -> Int {
        let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "taskId", ascending: false)]
        request.fetchLimit = 1
        
        do {
            let taskEntities = try context.fetch(request)
            return Int(taskEntities.first?.taskId ?? 0)
        } catch {
            print("❌ Ошибка получения максимального ID: \(error)")
            return 0
        }
    }
}
