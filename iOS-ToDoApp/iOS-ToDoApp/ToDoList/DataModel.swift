//
//  DataModel.swift
//  iOS-ToDoApp
//
//  Created by Haley Kwiat on 4/10/24.
//

enum Status {
    case Todo
    case Done
}

struct Task {
    var title: String
    var status: Status
}
