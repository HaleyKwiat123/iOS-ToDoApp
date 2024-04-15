//
//  iOS_ToDoAppTests.swift
//  iOS-ToDoAppTests
//
//  Created by Haley Kwiat on 4/9/24.
//

import Combine
import XCTest
@testable import iOS_ToDoApp

final class CoreDataManagerTests: XCTestCase {

    private var coreDataManager: CoreDataManagerMock!

    private var cancellabes = Set<AnyCancellable>()

    // MARK: - Setup

    override func setUpWithError() throws {
        try super.setUpWithError()

        coreDataManager = CoreDataManagerMock()
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()

        coreDataManager = nil
    }

    // MARK: - Tests

    func testCreateTask() throws {
        let task = coreDataManager.createTask()

        XCTAssertEqual(task?.title, "")
        XCTAssertEqual(task?.done, false)
    }

    func testFetchTasks() throws {
        _ = coreDataManager.createTask()
        _ = coreDataManager.createTask()

        let expectation = expectation(description: "task fetch")

        loadSavedData { tasks in
            XCTAssert(tasks.count == 2)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0)
    }

    func testUpdateTask() throws {
        let task = coreDataManager.createTask()

        task?.title = "Test Title"
        task?.done = true

        let expectation = expectation(description: "update task")

        loadSavedData { tasks in
            let updatedTask = tasks.first

            XCTAssertEqual(updatedTask?.title, "Test Title")
            XCTAssertEqual(updatedTask?.done, true)

            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0)
    }

    func testDeleteTask() {
        let task = coreDataManager.createTask()
        
        if let task {
            coreDataManager.deleteTask(task: task)
        }

        let expectation = expectation(description: "delete task")

        loadSavedData { tasks in
            XCTAssert(tasks.count == 0)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0)
    }

    // MARK: - Helpers

    func loadSavedData(completion: @escaping ([TodoTask]) -> Void) {
        coreDataManager.taskPublisher.sink { tasks in
            completion(tasks)
        }.store(in: &cancellabes)

        Task {
            await coreDataManager.loadSavedData()
        }
    }
}
