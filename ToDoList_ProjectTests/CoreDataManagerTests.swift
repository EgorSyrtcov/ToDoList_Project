import XCTest
import CoreData
@testable import ToDoList_Project

class CoreDataManagerTests: XCTestCase {
    
    var coreDataManager: MockCoreDataManager!
    
    override func setUp() {
        super.setUp()
        coreDataManager = MockCoreDataManager()
    }
    
    override func tearDown() {
        coreDataManager = nil
        super.tearDown()
    }
    
    func testAddTask() {
        // Given
        let task = Todo(id: 1, todo: "Test Task", completed: false, userID: 1)
        
        // When
        coreDataManager.addTask(task)
        
        // Then
        XCTAssertEqual(coreDataManager.tasks.count, 1)
        XCTAssertEqual(coreDataManager.tasks.first?.todo, "Test Task")
    }
    
    func testFetchTasks() {
        // Given
        let tasks = [
            Todo(id: 1, todo: "Task 1", completed: false, userID: 1),
            Todo(id: 2, todo: "Task 2", completed: true, userID: 1)
        ]
        coreDataManager.tasks = tasks
        
        // When
        let fetchedTasks = coreDataManager.fetchTasks()
        
        // Then
        XCTAssertEqual(fetchedTasks.count, 2)
        XCTAssertEqual(fetchedTasks[0].id, 1)
        XCTAssertEqual(fetchedTasks[1].id, 2)
    }
    
    func testUpdateTask() {
        // Given
        var task = Todo(id: 1, todo: "Original", completed: false, userID: 1)
        coreDataManager.tasks = [task]
        
        // When
        task.todo = "Updated"
        task.completed = true
        coreDataManager.updateTask(task)
        
        // Then
        XCTAssertEqual(coreDataManager.tasks.first?.todo, "Updated")
        XCTAssertTrue(coreDataManager.tasks.first?.completed ?? false)
    }
    
    func testDeleteTask() {
        // Given
        let task = Todo(id: 1, todo: "To Delete", completed: false, userID: 1)
        coreDataManager.tasks = [task]
        
        // When
        coreDataManager.deleteTask(task)
        
        // Then
        XCTAssertTrue(coreDataManager.tasks.isEmpty)
    }
    
    func testGetMaxTaskId() {
        // Given
        let tasks = [
            Todo(id: 5, todo: "Task 1", completed: false, userID: 1),
            Todo(id: 10, todo: "Task 2", completed: true, userID: 1)
        ]
        coreDataManager.tasks = tasks
        
        // When
        let maxId = coreDataManager.getMaxTaskId()
        
        // Then
        XCTAssertEqual(maxId, 10)
    }
}
