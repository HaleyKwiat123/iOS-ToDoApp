//
//  ToDoItemCellViewModel.swift
//  iOS-ToDoApp
//
//  Created by Haley Kwiat on 4/10/24.
//

class ToDoItemCellViewModel: ReusableViewModelType {
    var task: TodoTask

    init(task: TodoTask) {
        self.task = task
    }
}
