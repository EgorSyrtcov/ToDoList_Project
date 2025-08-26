import XCTest
import Combine
@testable import ToDoList_Project

class AddTaskViewModelTests: XCTestCase {
    
    var viewModel: AddTaskViewModel!
    var mockTaskService: MockTaskService!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockTaskService = MockTaskService()
        let routing = AddTaskRouting()
        viewModel = AddTaskViewModel(routing: routing)
        // Inject mock service
        cancellables = []
    }
    
    override func tearDown() {
        viewModel = nil
        mockTaskService = nil
        cancellables = nil
        super.tearDown()
    }
    
    func testSaveNewTask() {
        // Given
        let expectation = XCTestExpectation(description: "Task should be saved successfully")
        var successReceived = false
        
        viewModel.successPublisher
            .sink { success in
                if success {
                    successReceived = true
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // When
        viewModel.saveTask(title: "New Task", description: "Test Description")
        
        // Then
        wait(for: [expectation], timeout: 2.0)
        XCTAssertTrue(successReceived)
        XCTAssertEqual(mockTaskService.tasks.count, 1)
        XCTAssertEqual(mockTaskService.tasks.first?.todo, "New Task")
    }
    
    func testSaveTaskWithEmptyTitle() {
        // Given
        let expectation = XCTestExpectation(description: "Error should be received for empty title")
        var errorReceived = false
        
        viewModel.errorPublisher
            .sink { error in
                errorReceived = true
                XCTAssertEqual(error, "Название задачи не может быть пустым")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        viewModel.saveTask(title: "", description: "Test Description")
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(errorReceived)
    }
    
    func testEditExistingTask() {
        // Given
        let existingTask = Todo(id: 1, todo: "Old Title", description: "Old Description", completed: false, userID: 1)
        mockTaskService.tasks = [existingTask]
        viewModel.setTaskForEditing(existingTask)
        
        let expectation = XCTestExpectation(description: "Task should be edited successfully")
        var successReceived = false
        
        viewModel.successPublisher
            .sink { success in
                if success {
                    successReceived = true
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // When
        viewModel.saveTask(title: "Updated Title", description: "Updated Description")
        
        // Then
        wait(for: [expectation], timeout: 2.0)
        XCTAssertTrue(successReceived)
        XCTAssertEqual(mockTaskService.tasks.first?.todo, "Updated Title")
    }
    
    func testIsEditingMode() {
        // Given
        let task = Todo(id: 1, todo: "Test Task", description: "Test Description", completed: false, userID: 1)
        
        // When
        viewModel.setTaskForEditing(task)
        
        // Then
        XCTAssertTrue(viewModel.isEditingMode)
        XCTAssertNotNil(viewModel.taskForEditing)
        XCTAssertEqual(viewModel.taskForEditing?.id, task.id)
    }
}
