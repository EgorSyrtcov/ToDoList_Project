import XCTest
@testable import ToDoList_Project

class TaskServiceTests: XCTestCase {
    
    var taskService: TaskService!
    var mockCoreDataManager: MockCoreDataManager!
    
    override func setUp() {
        super.setUp()
        mockCoreDataManager = MockCoreDataManager()
        taskService = TaskService()
        // Inject mock core data manager
    }
    
    override func tearDown() {
        taskService = nil
        mockCoreDataManager = nil
        super.tearDown()
    }
    
    func testCreateNewTask() {
        // Given
        mockCoreDataManager.tasks = []
        
        // When
        let newTask = taskService.createNewTask(title: "Test Task", description: "Test Description")
        
        // Then
        XCTAssertEqual(newTask.todo, "Test Task")
        XCTAssertEqual(newTask.description, "Test Description")
        XCTAssertFalse(newTask.completed)
        XCTAssertEqual(mockCoreDataManager.tasks.count, 1)
        XCTAssertEqual(mockCoreDataManager.tasks.first?.todo, "Test Task")
        XCTAssertEqual(mockCoreDataManager.tasks.first?.description, "Test Description")
    }
    
    func testGetLocalTasks() {
        // Given
        let testTasks = [
            Todo(id: 1, todo: "Task 1", description: "Description 1", completed: false, userID: 1),
            Todo(id: 2, todo: "Task 2", description: "Description 2", completed: true, userID: 1)
        ]
        mockCoreDataManager.tasks = testTasks
        
        // When
        let localTasks = taskService.getLocalTasks()
        
        // Then
        XCTAssertEqual(localTasks.count, 2)
        XCTAssertEqual(localTasks[0].todo, "Task 1")
        XCTAssertEqual(localTasks[1].todo, "Task 2")
    }
    
    func testUpdateTaskLocally() {
        // Given
        var task = Todo(id: 1, todo: "Original", description: "Original Description", completed: false, userID: 1)
        mockCoreDataManager.tasks = [task]
        
        // When
        task.completed = true
        task.todo = "Updated"
        task.description = "Updated Description"
        taskService.updateTaskLocally(task)
        
        // Then
        XCTAssertEqual(mockCoreDataManager.tasks.first?.completed, true)
        XCTAssertEqual(mockCoreDataManager.tasks.first?.todo, "Updated")
        XCTAssertEqual(mockCoreDataManager.tasks.first?.description, "Updated Description")
    }
    
    func testDeleteTaskLocally() {
        // Given
        let task = Todo(id: 1, todo: "To Delete", description: "Delete Description", completed: false, userID: 1)
        mockCoreDataManager.tasks = [task]
        
        // When
        taskService.deleteTaskLocally(task)
        
        // Then
        XCTAssertTrue(mockCoreDataManager.tasks.isEmpty)
    }
}
