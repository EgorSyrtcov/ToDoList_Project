import Foundation

// MARK: - ToDoModel
struct ToDoList: Codable {
    var todos: [Todo]
    let total, skip, limit: Int
}

// MARK: - Todo
struct Todo: Codable {
    let id: Int
    var todo: String
    var description: String
    var completed: Bool
    let userID: Int

    enum CodingKeys: String, CodingKey {
        case id, todo, description, completed
        case userID = "userId"
    }
    
    // Инициализатор для создания задач из API (где нет description)
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        todo = try container.decode(String.self, forKey: .todo)
        description = try container.decodeIfPresent(String.self, forKey: .description) ?? ""
        completed = try container.decode(Bool.self, forKey: .completed)
        userID = try container.decode(Int.self, forKey: .userID)
    }
    
    // Обычный инициализатор для создания задач вручную
    init(id: Int, todo: String, description: String = "", completed: Bool, userID: Int) {
        self.id = id
        self.todo = todo
        self.description = description
        self.completed = completed
        self.userID = userID
    }
}
