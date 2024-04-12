//
//  TodoTask+CoreDataProperties.swift
//  iOS-ToDoApp
//
//  Created by Haley Kwiat on 4/11/24.
//
//

import Foundation
import CoreData


extension TodoTask {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<TodoTask> {
        return NSFetchRequest<TodoTask>(entityName: "TodoTask")
    }

    @NSManaged public var title: String
    @NSManaged public var done: Bool
    @NSManaged public var date: Date

}

extension TodoTask : Identifiable {

}
