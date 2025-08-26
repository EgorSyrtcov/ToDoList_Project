import XCTest
@testable import ToDoList_Project

class ModelTests: XCTestCase {
    
    // MARK: - Todo Model Tests
    
    func testTodoInitialization() {
        // Given
        let id = 1
        let title = "Test Task"
        let description = "Test Description"
        let completed = false
        let userID = 1
        
        // When
        let todo = Todo(id: id, todo: title, description: description, completed: completed, userID: userID)
        
        // Then
        XCTAssertEqual(todo.id, id)
        XCTAssertEqual(todo.todo, title)
        XCTAssertEqual(todo.description, description)
        XCTAssertEqual(todo.completed, completed)
        XCTAssertEqual(todo.userID, userID)
    }
    
    func testTodoInitializationWithoutDescription() {
        // Given
        let id = 1
        let title = "Test Task"
        let completed = false
        let userID = 1
        
        // When
        let todo = Todo(id: id, todo: title, completed: completed, userID: userID)
        
        // Then
        XCTAssertEqual(todo.id, id)
        XCTAssertEqual(todo.todo, title)
        XCTAssertEqual(todo.description, "") // Should default to empty string
        XCTAssertEqual(todo.completed, completed)
        XCTAssertEqual(todo.userID, userID)
    }
    
    func testTodoCodableEncoding() {
        // Given
        let todo = Todo(id: 1, todo: "Test Task", description: "Test Description", completed: false, userID: 1)
        
        // When
        let data = try? JSONEncoder().encode(todo)
        
        // Then
        XCTAssertNotNil(data)
    }
    
    func testTodoCodableDecoding() {
        // Given
        let jsonString = """
        {
            "id": 1,
            "todo": "Test Task",
            "description": "Test Description",
            "completed": false,
            "userId": 1
        }
        """
        let data = jsonString.data(using: .utf8)!
        
        // When
        let todo = try? JSONDecoder().decode(Todo.self, from: data)
        
        // Then
        XCTAssertNotNil(todo)
        XCTAssertEqual(todo?.id, 1)
        XCTAssertEqual(todo?.todo, "Test Task")
        XCTAssertEqual(todo?.description, "Test Description")
        XCTAssertEqual(todo?.completed, false)
        XCTAssertEqual(todo?.userID, 1)
    }
    
    func testTodoCodableDecodingWithoutDescription() {
        // Given - JSON without description field (as from API)
        let jsonString = """
        {
            "id": 1,
            "todo": "Test Task",
            "completed": false,
            "userId": 1
        }
        """
        let data = jsonString.data(using: .utf8)!
        
        // When
        let todo = try? JSONDecoder().decode(Todo.self, from: data)
        
        // Then
        XCTAssertNotNil(todo)
        XCTAssertEqual(todo?.id, 1)
        XCTAssertEqual(todo?.todo, "Test Task")
        XCTAssertEqual(todo?.description, "") // Should default to empty string
        XCTAssertEqual(todo?.completed, false)
        XCTAssertEqual(todo?.userID, 1)
    }
    
    // MARK: - ToDoList Model Tests
    
    func testToDoListInitialization() {
        // Given
        let todos = [
            Todo(id: 1, todo: "Task 1", description: "Description 1", completed: false, userID: 1),
            Todo(id: 2, todo: "Task 2", description: "Description 2", completed: true, userID: 1)
        ]
        let total = 10
        let skip = 0
        let limit = 30
        
        // When
        let todoList = ToDoList(todos: todos, total: total, skip: skip, limit: limit)
        
        // Then
        XCTAssertEqual(todoList.todos.count, 2)
        XCTAssertEqual(todoList.total, total)
        XCTAssertEqual(todoList.skip, skip)
        XCTAssertEqual(todoList.limit, limit)
        XCTAssertEqual(todoList.todos.first?.todo, "Task 1")
        XCTAssertEqual(todoList.todos.first?.description, "Description 1")
    }
    
    func testToDoListCodableEncoding() {
        // Given
        let todos = [Todo(id: 1, todo: "Task 1", description: "Description 1", completed: false, userID: 1)]
        let todoList = ToDoList(todos: todos, total: 1, skip: 0, limit: 30)
        
        // When
        let data = try? JSONEncoder().encode(todoList)
        
        // Then
        XCTAssertNotNil(data)
    }
    
    func testToDoListCodableDecoding() {
        // Given
        let jsonString = """
        {
            "todos": [
                {
                    "id": 1,
                    "todo": "Task 1",
                    "description": "Description 1",
                    "completed": false,
                    "userId": 1
                }
            ],
            "total": 1,
            "skip": 0,
            "limit": 30
        }
        """
        let data = jsonString.data(using: .utf8)!
        
        // When
        let todoList = try? JSONDecoder().decode(ToDoList.self, from: data)
        
        // Then
        XCTAssertNotNil(todoList)
        XCTAssertEqual(todoList?.todos.count, 1)
        XCTAssertEqual(todoList?.todos.first?.todo, "Task 1")
        XCTAssertEqual(todoList?.todos.first?.description, "Description 1")
        XCTAssertEqual(todoList?.total, 1)
    }
}
