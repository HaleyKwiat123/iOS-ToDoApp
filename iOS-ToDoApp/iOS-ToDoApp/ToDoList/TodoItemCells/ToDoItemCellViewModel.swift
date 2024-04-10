//
//  ToDoItemCellViewModel.swift
//  iOS-ToDoApp
//
//  Created by Haley Kwiat on 4/10/24.
//

class ToDoItemCellViewModel: ReusableViewModelType {
    var task: Task

    init(task: Task) {
        self.task = task
    }
}
