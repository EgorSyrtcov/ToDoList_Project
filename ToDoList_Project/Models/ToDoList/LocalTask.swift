import Foundation

// MARK: - LocalTask (для локального использования)
struct LocalTask: Codable, Identifiable {
    let id: UUID
    var title: String
    var description: String
    var createdAt: Date
    var isCompleted: Bool
    
    init(id: UUID = UUID(), title: String, description: String, createdAt: Date = Date(), isCompleted: Bool = false) {
        self.id = id
        self.title = title
        self.description = description
        self.createdAt = createdAt
        self.isCompleted = isCompleted
    }
    
    // Конвертер из API модели
    init(from todo: Todo) {
        self.id = UUID()
        self.title = todo.todo
        self.description = "Описание задачи"
        self.createdAt = Date()
        self.isCompleted = todo.completed
    }
}
