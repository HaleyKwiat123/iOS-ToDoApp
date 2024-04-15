//
//  ToDoListViewModel.swift
//  iOS-ToDoApp
//
//  Created by Haley Kwiat on 4/9/24.
//

import Combine
import CoreData

protocol ReusableViewType: AnyObject {
    static var reuseID: String { get }
    var viewModel: ReusableViewModelType? { get set }
}

protocol ReusableViewModelType {
    // Place Holder to be able to refer to a general VM cell Type
}

class ToDoListViewModel {
    
    // MARK: - Events

    var cellUpdatedPublisher: AnyPublisher<Void, Never> {
        return cellUpdatedSubject.eraseToAnyPublisher()
    }
    private let cellUpdatedSubject = PassthroughSubject<Void, Never>()

    // MARK: - Sections

    struct SectionVM {
        var tasks: [TodoTask]
    }

    enum Section {
        case TodoSection(SectionVM)

        var itemCount: Int {
            switch self {
            case .TodoSection(let vm):
                return vm.tasks.count
            }
        }
    }

    private var sections: [Section] = []

    private var dataManager: CoreDataManager

    // MARK: - Lifecycle

    init() {
        dataManager = CoreDataManager()
        loadSavedData()
    }

    private func loadSavedData() {
        if let tasks = dataManager.loadSavedData() {
            let section = Section.TodoSection(SectionVM(tasks: tasks))
            sections.append(section)
            cellUpdatedSubject.send()
        }
    }

    // MARK: - Section Helpers

    func numberOfSections() -> Int {
        return sections.count
    }

    func numberOfItemsIn(section index: Int) -> Int {
        return section(at: index)?.itemCount ?? 0
    }

    private func section(at index: Int) -> Section? {
        guard
            !sections.isEmpty,
            sections.count >= index
        else { return nil }

        return sections[index]
    }

    private func regenerateSection(
        at index: Int,
        updatedVM: SectionVM?,
        completion: (() -> Void)? = nil
    ) {
        guard let updatedVM else { return }

        let updatedSection = Section.TodoSection(updatedVM)

        sections.remove(at: index)
        sections.insert(updatedSection, at: index)

        completion?()
    }

    // MARK: - Cell Helpers

    var cellTypes: [ReusableViewType.Type] {
        [ToDoItemCell.self]
    }

    func reuseId(at indexPath: IndexPath) -> String? {
        return cellType(indexPath: indexPath)?.reuseID
    }

    func cellType(indexPath: IndexPath) -> ReusableViewType.Type? {
        guard let section = section(at: indexPath.section) else { return nil }

        switch section {
        case .TodoSection:
            return ToDoItemCell.self
        }
    }

    func cellViewModel(indexPath: IndexPath) -> ReusableViewModelType? {
        guard let section = section(at: indexPath.section) else { return nil }

        switch section {
        case .TodoSection(let sectionVM):
            return ToDoItemCellViewModel(task: sectionVM.tasks[indexPath.item])
        }
    }

    // MARK: - Task Helpers

    func addTask() {
        var updatedVM: SectionVM?
        guard let index = sections.firstIndex(where: {
            if case .TodoSection(let todoVM) = $0 {
                updatedVM = todoVM
                return true
            }
            return false
        }) else { return }


        if let newTask = dataManager.createTask() {
            updatedVM?.tasks.insert(newTask, at: 0)
            
            regenerateSection(
                at: index,
                updatedVM: updatedVM
            ) { [weak self] in
                self?.cellUpdatedSubject.send()
            }
        }
    }

    func deleteTask(indexPath: IndexPath?) {
        guard
            let indexPath,
            let section = section(at: indexPath.section)
        else { return }

        var updatedVM: SectionVM?
        switch section {
        case .TodoSection(let vm):
            updatedVM = vm
            if let task = updatedVM?.tasks[indexPath.item] {
                updatedVM?.tasks.remove(at: indexPath.item)
                dataManager.deleteTask(task: task)
            }
        }

        regenerateSection(
            at: indexPath.section,
            updatedVM: updatedVM
        ) { [weak self] in
            self?.cellUpdatedSubject.send()
        }
    }

    func updateTask(task: TodoTask, indexPath: IndexPath?) {
        guard
            let indexPath,
            let section = section(at: indexPath.section)
        else { return }

        var updatedVM: SectionVM?
        switch section {
        case .TodoSection(let vm):
            updatedVM = vm
            updatedVM?.tasks[indexPath.item] = task
            dataManager.saveContext()
        }

        regenerateSection(
            at: indexPath.section,
            updatedVM: updatedVM
        )
    }
}
