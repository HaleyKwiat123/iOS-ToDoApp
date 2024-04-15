//
//  CoreDataManagerMock.swift
//  iOS-ToDoAppTests
//
//  Created by Haley Kwiat on 4/14/24.
//

import CoreData
@testable import iOS_ToDoApp

class CoreDataManagerMock: CoreDataManager {

    override func setupContainer() {
        // Creating a container with descrption url "/dev/null"
        // allows Core Data to save to an in-memory store instead of disk.
        // That way unit testing will start with a fresh state for every test
        let description = NSPersistentStoreDescription()
        description.url = URL(fileURLWithPath: "/dev/null")

        container = NSPersistentContainer(name: "iOS-ToDoApp")
        container?.persistentStoreDescriptions = [description]

        backgroundContext = container?.newBackgroundContext()

        container?.loadPersistentStores { storeDescription, error in
            if let error = error {
                Self.logger.error("Unresolved error \(error)")
            }
        }
    }
}
