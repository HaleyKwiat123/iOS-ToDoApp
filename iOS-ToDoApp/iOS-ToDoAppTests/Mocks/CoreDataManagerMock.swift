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
        let description = NSPersistentStoreDescription()
        description.url = URL(fileURLWithPath: "/dev/null")
        container = NSPersistentContainer(name: "iOS-ToDoApp")
        container?.persistentStoreDescriptions = [description]
        container?.loadPersistentStores { storeDescription, error in
            if let error = error {
                Self.logger.error("Unresolved error \(error)")
            }
        }
    }
}
