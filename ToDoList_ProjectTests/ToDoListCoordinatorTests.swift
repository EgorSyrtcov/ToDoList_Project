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
        let initialCount = coordinator.navigationController.viewControllers.count
        
        // When - напрямую тестируем метод координатора
        coordinator.showAddTaskViewController(task: nil)
        
        // Then - проверяем что AddTaskViewController был показан
        XCTAssertEqual(coordinator.navigationController.viewControllers.count, initialCount + 1)
        XCTAssertTrue(coordinator.navigationController.viewControllers.last is AddTaskViewController)
        
        // Проверяем что ViewModel настроен для создания новой задачи
        if let addTaskVC = coordinator.navigationController.viewControllers.last as? AddTaskViewController {
            XCTAssertFalse(addTaskVC.viewModel.isEditingMode)
            XCTAssertNil(addTaskVC.viewModel.taskForEditing)
        }
    }
    
    func testShowEditTaskViewController() {
        // Given
        coordinator.start()
        let taskToEdit = Todo(id: 1, todo: "Test Task", description: "Test Description", completed: false, userID: 1)
        let initialCount = coordinator.navigationController.viewControllers.count
        
        // When - напрямую тестируем метод координатора для редактирования
        coordinator.showAddTaskViewController(task: taskToEdit)
        
        // Then - проверяем что AddTaskViewController был показан для редактирования
        XCTAssertEqual(coordinator.navigationController.viewControllers.count, initialCount + 1)
        XCTAssertTrue(coordinator.navigationController.viewControllers.last is AddTaskViewController)
        
        // Проверяем что ViewModel настроен для редактирования
        if let addTaskVC = coordinator.navigationController.viewControllers.last as? AddTaskViewController {
            XCTAssertTrue(addTaskVC.viewModel.isEditingMode)
            XCTAssertEqual(addTaskVC.viewModel.taskForEditing?.id, taskToEdit.id)
            XCTAssertEqual(addTaskVC.viewModel.taskForEditing?.todo, taskToEdit.todo)
            XCTAssertEqual(addTaskVC.viewModel.taskForEditing?.description, taskToEdit.description)
        }
    }
    
    func testNavigationFlow() {
        // Given
        coordinator.start()
        
        // When - запускаем полный flow: показ списка -> добавление задачи
        XCTAssertEqual(coordinator.navigationController.viewControllers.count, 1)
        XCTAssertTrue(coordinator.navigationController.viewControllers.first is ToDoListViewController)
        
        // Симулируем добавление задачи
        coordinator.showAddTaskViewController(task: nil)
        
        // Then - проверяем что навигация работает корректно
        XCTAssertEqual(coordinator.navigationController.viewControllers.count, 2)
        XCTAssertTrue(coordinator.navigationController.viewControllers.last is AddTaskViewController)
        
        // Проверяем возврат назад
        coordinator.navigationController.popViewController(animated: false)
        XCTAssertEqual(coordinator.navigationController.viewControllers.count, 1)
        XCTAssertTrue(coordinator.navigationController.viewControllers.first is ToDoListViewController)
    }
}
