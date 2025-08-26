import XCTest
import UIKit
@testable import ToDoList_Project

class ToDoListCoordinatorTests: XCTestCase {
    
    var coordinator: ToDoListCoordinator!
    
    override func setUp() {
        super.setUp()
        coordinator = ToDoListCoordinator()
    }
    
    override func tearDown() {
        coordinator = nil
        super.tearDown()
    }
    
    func testStart() {
        // When
        coordinator.start()
        
        // Then
        XCTAssertNotNil(coordinator.navigationController.viewControllers.first)
        XCTAssertTrue(coordinator.navigationController.viewControllers.first is ToDoListViewController)
    }
    
    func testShowAddTaskViewController() {
        // Given
        coordinator.start()
        
        // When
       // coordinator.showAddTaskViewController(task: nil)
        
        // Then
        XCTAssertEqual(coordinator.navigationController.viewControllers.count, 2)
        XCTAssertTrue(coordinator.navigationController.viewControllers.last is AddTaskViewController)
    }
}
