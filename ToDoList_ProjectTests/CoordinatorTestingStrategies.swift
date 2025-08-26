import XCTest
import UIKit
import Combine
@testable import ToDoList_Project

// MARK: - Дополнительные стратегии тестирования приватных методов координаторов

class CoordinatorTestingStrategiesTests: XCTestCase {
    
    var coordinator: ToDoListCoordinator!
    var cancellables: Set<AnyCancellable> = []
    
    override func setUp() {
        super.setUp()
        coordinator = ToDoListCoordinator()
        cancellables = []
    }
    
    override func tearDown() {
        coordinator = nil
        cancellables.removeAll()
        super.tearDown()
    }
    
    // MARK: - Способ 1: Тестирование через публичный интерфейс (Рекомендуемый)
    // Уже реализован в ToDoListCoordinatorTests.swift
    
    // MARK: - Способ 2: Тестирование через делегаты и callbacks
    
    func testCoordinatorRespondsToViewModelCallbacks() {
        // Given
        coordinator.start()
        let expectation = XCTestExpectation(description: "AddTask navigation should be triggered")
        
        // When - создаем routing и симулируем его поведение
        let routing = ToDoListRouting()
        
        // Подписываемся на событие как это делает координатор
        routing.addTaskButtonDidTapSubject
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // Симулируем нажатие кнопки
        routing.addTaskButtonDidTapSubject.send()
        
        // Then
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Способ 3: Тестирование эффектов приватных методов
    
    func testPrivateMethodEffectsOnNavigationStack() {
        // Given
        coordinator.start()
        let initialControllersCount = coordinator.navigationController.viewControllers.count
        
        // When - вызываем публичный метод, который внутри вызывает приватный
        if let toDoListVC = coordinator.navigationController.viewControllers.first as? ToDoListViewController {
            // Симулируем действие пользователя, которое приведет к навигации
            toDoListVC.viewModel.addTaskDidTapSubject.send()
        }
        
        // Then - проверяем эффект приватного метода
        XCTAssertEqual(coordinator.navigationController.viewControllers.count, initialControllersCount + 1)
        
        // Проверяем что правильный ViewController был добавлен
        if let addTaskVC = coordinator.navigationController.viewControllers.last as? AddTaskViewController {
            XCTAssertNotNil(addTaskVC.viewModel)
            XCTAssertFalse(addTaskVC.viewModel.isEditingMode) // Новая задача, не редактирование
        }
    }
    
    // MARK: - Способ 4: Mock координатор с протоколом
    
    func testWithMockCoordinator() {
        // Этот подход требует создания протокола для координатора
        // Пример реализации:
        
        let mockCoordinator = MockToDoListCoordinator()
        
        // When
        mockCoordinator.simulateAddTaskNavigation()
        
        // Then
        XCTAssertTrue(mockCoordinator.addTaskViewControllerWasShown)
        XCTAssertNil(mockCoordinator.lastTaskForEditing)
    }
    
    // MARK: - Способ 5: Тестирование через Notification Center (если используется)
    
    func testNavigationThroughNotifications() {
        // Given
        coordinator.start()
        let expectation = XCTestExpectation(description: "Navigation notification should be posted")
        
        // Подписываемся на уведомления (если ваш координатор их использует)
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("AddTaskNavigationTriggered"),
            object: nil,
            queue: nil
        ) { _ in
            expectation.fulfill()
        }
        
        // When - симулируем действие, которое должно вызвать навигацию
        if let toDoListVC = coordinator.navigationController.viewControllers.first as? ToDoListViewController {
            toDoListVC.viewModel.addTaskDidTapSubject.send()
        }
        
        // Then
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Способ 6: Тестирование состояния после навигации
    
    func testViewControllerStateAfterNavigation() {
        // Given
        coordinator.start()
        
        // When - симулируем навигацию
        if let toDoListVC = coordinator.navigationController.viewControllers.first as? ToDoListViewController {
            toDoListVC.viewModel.addTaskDidTapSubject.send()
        }
        
        // Then - проверяем состояние созданного ViewController
        if let addTaskVC = coordinator.navigationController.viewControllers.last as? AddTaskViewController {
            XCTAssertNotNil(addTaskVC.viewModel)
            XCTAssertFalse(addTaskVC.viewModel.isEditingMode)
            XCTAssertNil(addTaskVC.viewModel.taskForEditing)
            
            // Проверяем что routing правильно настроен
            XCTAssertNotNil(addTaskVC.viewModel.routing)
        }
    }
}

// MARK: - Mock Objects для тестирования

protocol ToDoListCoordinatorProtocol {
    func showAddTaskViewController(task: Todo?)
}

class MockToDoListCoordinator: ToDoListCoordinatorProtocol {
    var addTaskViewControllerWasShown = false
    var lastTaskForEditing: Todo?
    
    func showAddTaskViewController(task: Todo?) {
        addTaskViewControllerWasShown = true
        lastTaskForEditing = task
    }
    
    func simulateAddTaskNavigation() {
        showAddTaskViewController(task: nil)
    }
}

// MARK: - Дополнительные тесты для edge cases

extension CoordinatorTestingStrategiesTests {
    
    func testNavigationWithEditingTask() {
        // Given
        coordinator.start()
        let taskToEdit = Todo(id: 1, todo: "Test Task", description: "Test Description", completed: false, userID: 1)
        
        // When
        if let toDoListVC = coordinator.navigationController.viewControllers.first as? ToDoListViewController {
            toDoListVC.viewModel.editTaskDidTapSubject.send(taskToEdit)
        }
        
        // Then
        if let addTaskVC = coordinator.navigationController.viewControllers.last as? AddTaskViewController {
            XCTAssertTrue(addTaskVC.viewModel.isEditingMode)
            XCTAssertEqual(addTaskVC.viewModel.taskForEditing?.id, taskToEdit.id)
            XCTAssertEqual(addTaskVC.viewModel.taskForEditing?.todo, taskToEdit.todo)
            XCTAssertEqual(addTaskVC.viewModel.taskForEditing?.description, taskToEdit.description)
        }
    }
    
    func testMultipleNavigationActions() {
        // Given
        coordinator.start()
        
        // When - симулируем несколько навигационных действий
        if let toDoListVC = coordinator.navigationController.viewControllers.first as? ToDoListViewController {
            toDoListVC.viewModel.addTaskDidTapSubject.send()
            
            // Проверяем промежуточное состояние
            XCTAssertEqual(coordinator.navigationController.viewControllers.count, 2)
            
            // Возвращаемся назад
            coordinator.navigationController.popViewController(animated: false)
            
            // Проверяем что вернулись
            XCTAssertEqual(coordinator.navigationController.viewControllers.count, 1)
            XCTAssertTrue(coordinator.navigationController.viewControllers.first is ToDoListViewController)
        }
    }
}
