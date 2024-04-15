//
//  CoreDataManager.swift
//  iOS-ToDoApp
//
//  Created by Haley Kwiat on 4/14/24.
//

import CoreData
import os

class CoreDataManager {

    // A note on Core Data: This implementation of Core Data is currently all running on the main thread. This works because these operations are simple and core data is very fast.
    // In any other scenario we would want to have most of these operations on background thread as to not block the UI. Core data is finicky with multithreaded implementations, and as this is my first core data implementation and the operations are simple I stuck to one thread.
    // Core data in order to be multi threaded requires us to manage multiple contexts for each thread, merge these contexts when necesary and is complicated to manage and implement correctly.
    // However, I wanted to point out that had I been communicating with an external API, which is usually the case for fetching, updating and persisting data we would certainly want to run these fetch, load and update operations on a background thread. Probably using async/await as that's my current favorite implementation with background threads!
    // An example of what that might look like:  
    //    func fetchTasks() async {
    //      do {
    //        if let url {
    //            let (data, _) = try await URLSession.shared.data(from: url)
    //            if let decodedResponse = try? JSONDecoder().decode(TodoTask.self, from: data) {
    //                dataSubject.send(decodedResponse)
    //            }
    //        }
    //    } catch {
    //        Self.logger.error(error)
    //    }
    //  }


    // MARK: - Logging

    static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: ToDoListViewModel.self)
    )

    var container: NSPersistentContainer?

    init() {
        setupContainer()
    }

    func setupContainer() {
        container = NSPersistentContainer(name: "iOS-ToDoApp")
        container?.loadPersistentStores { storeDescription, error in
            if let error = error {
                Self.logger.error("Unresolved error \(error)")
            }
        }
    }

    // MARK: - Core Data Helpers

    func loadSavedData() -> [TodoTask]? {
        let request = TodoTask.createFetchRequest()
        let sort = NSSortDescriptor(key: "date", ascending: false)
        request.sortDescriptors = [sort]

        do {
            let tasks = try container?.viewContext.fetch(request)
            return tasks
        } catch {
            Self.logger.error("Fetch to Core Data Failed: \(error)")
        }

        return nil
    }

    func saveContext() {
        if container?.viewContext.hasChanges == true {
            do {
                try container?.viewContext.save()
            } catch {
                Self.logger.error("An error occurred while saving: \(error)")
            }
        }
    }

    func createTask() -> TodoTask? {
        guard let context = container?.viewContext else { return nil }
        let newTask = TodoTask(context: context)
        newTask.title = ""
        newTask.done = false
        newTask.date = Date()

        saveContext()

        return newTask
    }

    func deleteTask(task: TodoTask) {
        container?.viewContext.delete(task)
        saveContext()
    }
}
