//
//  ToDoItemCell.swift
//  iOS-ToDoApp
//
//  Created by Haley Kwiat on 4/9/24.
//

import Combine
import UIKit

protocol CellDelegate: AnyObject {
    func updateTask(task: TodoTask, indexPath: IndexPath?)
    func deleteTask(indexPath: IndexPath?)
    func updateIsEditing(indexPath: IndexPath?)
    func reloadCollectionView()
}

class ToDoItemCell: UICollectionViewCell,
                    ReusableViewType,
                    UITextViewDelegate
{
    // MARK: - ReusableViewType

    static var reuseID: String = "ToDoItemCell"

    var viewModel: ReusableViewModelType? {
        willSet {
            cleanUp()
        }
        didSet {
            viewModelDidChange()
        }
    }

    private var todoItemCellViewModel: ToDoItemCellViewModel? {
        return viewModel as? ToDoItemCellViewModel
    }

    private var cancellables = Set<AnyCancellable>()

    // MARK: - VC Properties

    var indexPath: IndexPath?

    weak var delegate: CellDelegate?

    // MARK: - UI Elements

    let taskTitle = UITextView()

    private var checkImage: CheckBox?

    private let deleteButton = UIButton()

    // MARK: - Lifecycle

    private func viewModelDidChange() {
        guard let todoItemCellViewModel else { return }

        // Cell setup
        layer.cornerRadius = 16.0
        layer.borderWidth = 1.0

        // Check Box Setup
        checkImage = CheckBox(isSelected: todoItemCellViewModel.task.done)
        if let checkImage {
            updateTextColor(isSelected: todoItemCellViewModel.task.done)
            contentView.addSubview(checkImage)
        }

        // Task Title Setup
        taskTitle.delegate = self
        taskTitle.isScrollEnabled = true
        taskTitle.text = todoItemCellViewModel.task.title
        taskTitle.accessibilityLabel = "To do text"
        contentView.addSubview(taskTitle)

        // Delete Button Setup
        deleteButton.addTarget(
            self,
            action: #selector(didTapDelete),
            for: .touchUpInside
        )
        contentView.addSubview(deleteButton)

        themeDidChange()

        setupSubscriptions()
    }

    private func setupSubscriptions() {
        checkImage?.isSelectedUpdatedPublisher.sink { [weak self] isSelected in
            guard 
                let self,
                let task = self.todoItemCellViewModel?.task
            else { return }

            task.done = isSelected

            self.updateTextColor(isSelected: isSelected)

            self.delegate?.updateTask(
                task: task,
                indexPath: self.indexPath
            )
        }.store(in: &cancellables)
    }

    private func updateTextColor(isSelected: Bool) {
        taskTitle.textColor = isSelected ? .red : .black
    }

    private func cleanUp() {
        checkImage?.isSelected = false
        checkImage = nil
        taskTitle.text = nil
        for item in cancellables {
            item.cancel()
        }
        cancellables.removeAll()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        cleanUp()
    }

    // MARK: - Layout

    struct Constants {
        static let minimumHeight: CGFloat = 30.0
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        _ = sizeThatFits(bounds.size)
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let extraSmallPadding: CGFloat = 8

        var checkImageFrame = CGRect.zero
        checkImageFrame.size = checkImage?.intrinsicContentSize ?? .zero
        let totalHeight = Constants.minimumHeight + (2 * extraSmallPadding)
        checkImageFrame.origin.y = (totalHeight / 2) - (checkImageFrame.size.height / 2)
        checkImageFrame.origin.x = extraSmallPadding
        checkImage?.frame = checkImageFrame

        var deleteButtonFrame = CGRect.zero
        deleteButtonFrame.size = deleteButton.intrinsicContentSize
        deleteButtonFrame.origin.y = checkImageFrame.origin.y
        deleteButtonFrame.origin.x = size.width - deleteButtonFrame.width - extraSmallPadding
        deleteButton.frame = deleteButtonFrame

        var itemContentFrame = CGRect.zero
        itemContentFrame.origin.x = checkImageFrame.maxX
        itemContentFrame.origin.y = extraSmallPadding

        let itemContentWidth = size.width - checkImageFrame.width - deleteButtonFrame.width - (2 * extraSmallPadding)
        let estimatedHeight = taskTitle
            .sizeThatFits(
                CGSize(width: itemContentWidth,
                       height: size.height)
            ).height

        itemContentFrame.size.width = itemContentWidth
        itemContentFrame.size.height = max(Constants.minimumHeight, estimatedHeight)
        taskTitle.frame = itemContentFrame

        return CGSize(
            width: size.width,
            height: itemContentFrame.maxY + extraSmallPadding
        )
    }

    // MARK: - Themable

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        themeDidChange()
    }

    private func themeDidChange() {
        backgroundColor = .white
        layer.borderColor = grayColor.cgColor

        taskTitle.backgroundColor = .clear

        let deleteImage = UIImage(systemName: "trash")?
            .withTintColor(
                .lightGray,
                renderingMode: .alwaysOriginal
            )
        deleteButton.setImage(deleteImage, for: .normal)
    }


    // MARK: - Actions

    @objc private func didTapDelete() {
        delegate?.deleteTask(indexPath: indexPath)
    }

    // MARK: - UITextViewDelegate

    func textViewDidChange(_ textView: UITextView) {
        delegate?.reloadCollectionView()

        if let task = self.todoItemCellViewModel?.task {
            task.title = self.taskTitle.text
            delegate?.updateTask(task: task, indexPath: indexPath)
        }
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        guard let indexPath else { return }

        delegate?.updateIsEditing(indexPath: indexPath)
    }
}
