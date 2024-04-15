//
//  iOS_ToDoAppTests.swift
//  iOS-ToDoAppTests
//
//  Created by Haley Kwiat on 4/9/24.
//

import XCTest
@testable import iOS_ToDoApp

final class CoreDataManagerTests: XCTestCase {

    private var coreDataManager: CoreDataManagerMock!

    override func setUpWithError() throws {
        try super.setUpWithError()

        coreDataManager = CoreDataManagerMock()
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()

        coreDataManager = nil
    }

    func testCreateTask() throws {
        let task = coreDataManager.createTask()

        XCTAssertEqual(task?.title, "")
        XCTAssertEqual(task?.done, false)
    }

    func testFetchTasks() throws {
        _ = coreDataManager.createTask()
        _ = coreDataManager.createTask()

        let tasks = coreDataManager.loadSavedData()

        XCTAssert(tasks?.count == 2)
    }

    func testUpdateTask() throws {
        let task = coreDataManager.createTask()

        task?.title = "Test Title"
        task?.done = true

        let tasks = coreDataManager.loadSavedData()

        let updatedTask = tasks?.first

        XCTAssertEqual(updatedTask?.title, "Test Title")
        XCTAssertEqual(updatedTask?.done, true)
    }

    func testDeleteTask() {
        let task = coreDataManager.createTask()
        
        if let task {
            coreDataManager.deleteTask(task: task)
        }

        let tasks = coreDataManager.loadSavedData()

        XCTAssert(tasks?.count == 0)
    }
}
