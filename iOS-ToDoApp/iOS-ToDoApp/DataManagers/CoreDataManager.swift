//
//  CoreDataManager.swift
//  iOS-ToDoApp
//
//  Created by Haley Kwiat on 4/14/24.
//

import Combine
import CoreData
import os

class CoreDataManager {

    // MARK: - Logging

    static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: ToDoListViewModel.self)
    )

    // MARK: - Events

    var taskPublisher: AnyPublisher<[TodoTask], Never> {
        return taskSubject.eraseToAnyPublisher()
    }
    private let taskSubject = PassthroughSubject<[TodoTask], Never>()

    // MARK: - Core Data Properties

    var container: NSPersistentContainer?

    var backgroundContext: NSManagedObjectContext?

    // MARK: - Lifecycle

    init() {
        setupContainer()
    }

    func setupContainer() {
        // Create Container and Background Context
        container = NSPersistentContainer(name: "iOS-ToDoApp")
        backgroundContext = container?.newBackgroundContext()
        backgroundContext?.automaticallyMergesChangesFromParent = true

        container?.loadPersistentStores { storeDescription, error in
            if let error = error {
                Self.logger.error("Unresolved error \(error)")
            }
        }
    }

    // MARK: - Core Data Helpers

    func loadSavedData() async {
        await backgroundContext?.perform { [weak self] in
            guard let self else { return }

            do {
                // Create fetch request with date sorting
                let request = TodoTask.createFetchRequest()
                let sort = NSSortDescriptor(key: "date", ascending: false)
                request.sortDescriptors = [sort]

                // Perform fetch and send event
                if let tasks = try self.backgroundContext?.fetch(request) {
                    self.taskSubject.send(tasks)
                }
            } catch {
                Self.logger.error("Fetch to Core Data Failed: \(error)")
            }
        }
    }

    func save() {
        Task {
            await saveContext()
        }
    }

    private func saveContext() async {
        await backgroundContext?.perform { [weak self] in
            guard let self else { return }

            do {
                if self.backgroundContext?.hasChanges == true {
                    try self.backgroundContext?.save()
                }
            } catch {
                Self.logger.error("An error occurred while saving: \(error)")
            }
        }
    }

    func createTask() -> TodoTask? {
        guard let backgroundContext else { return nil }

        let newTask = TodoTask(context: backgroundContext)
        newTask.title = ""
        newTask.done = false
        newTask.date = Date()

        save()

        return newTask
    }

    func deleteTask(task: TodoTask) {
        backgroundContext?.delete(task)
        
        save()
    }
}
