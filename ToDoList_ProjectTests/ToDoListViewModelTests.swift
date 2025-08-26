import XCTest
import Combine
@testable import ToDoList_Project

class ToDoListViewModelTests: XCTestCase {
    
    var viewModel: ToDoListViewModel!
    var mockTaskService: MockTaskService!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockTaskService = MockTaskService()
        let routing = ToDoListRouting()
        viewModel = ToDoListViewModel(routing: routing)
        // Inject mock service (you'll need to modify ViewModel to accept service injection)
        cancellables = []
    }
    
    override func tearDown() {
        viewModel = nil
        mockTaskService = nil
        cancellables = nil
        super.tearDown()
    }
    
    func testToggleTaskCompletion() {
        // Given
        let initialTask = Todo(id: 1, todo: "Test Task", description: "Test Description", completed: false, userID: 1)
        mockTaskService.tasks = [initialTask]
        
        // When
        viewModel.toggleTaskCompletion(initialTask)
        
        // Then
        let updatedTask = mockTaskService.tasks.first!
        XCTAssertTrue(updatedTask.completed, "Task should be completed after toggle")
    }
    
    func testDeleteTask() {
        // Given
        let task = Todo(id: 1, todo: "Test Task", description: "Test Description", completed: false, userID: 1)
        mockTaskService.tasks = [task]
        
        // When
        viewModel.deleteTaskCompletion(task)
        
        // Then
        XCTAssertTrue(mockTaskService.tasks.isEmpty, "Tasks should be empty after deletion")
    }
    
    func testUpdateSearchQuery() {
        // Given
        let tasks = [
            Todo(id: 1, todo: "Buy groceries", description: "Buy milk and bread", completed: false, userID: 1),
            Todo(id: 2, todo: "Clean house", description: "Clean all rooms", completed: false, userID: 1)
        ]
        mockTaskService.tasks = tasks
        
        // When
        viewModel.updateSearchQuery("Buy")
        
        // Then
        let expectation = XCTestExpectation(description: "Filtered tasks should contain only matching items")
        
        viewModel.filteredTodosPublisher
            .sink { filteredTodos in
                XCTAssertEqual(filteredTodos.count, 1)
                XCTAssertEqual(filteredTodos.first?.todo, "Buy groceries")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testAddTaskSubject() {
        // Given
        let expectation = XCTestExpectation(description: "Add task subject should trigger")
        var receivedValue = false
        
        viewModel.routing.addTaskButtonDidTapSubject
            .sink {
                receivedValue = true
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        viewModel.addTaskDidTapSubject.send()
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(receivedValue)
    }
}
