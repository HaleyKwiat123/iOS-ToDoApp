//
//  ToDoItemCell.swift
//  iOS-ToDoApp
//
//  Created by Haley Kwiat on 4/9/24.
//

import Combine
import UIKit

protocol CellDelegate: AnyObject {
    func updateTask(task: Task, indexPath: IndexPath?)
    func deleteTask(indexPath: IndexPath?)
    func animateKeyboard(up: Bool, indexPath: IndexPath?)
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

    private var checkImage: CheckBox?

    private let itemContent = UITextView()

    private let deleteButton = UIButton()

    // MARK: - Lifecycle

    private func viewModelDidChange() {
        guard let todoItemCellViewModel else { return }

        layer.cornerRadius = 16.0
        backgroundColor = .white

        let deleteImage = UIImage(systemName: "trash")?
            .withTintColor(
                .lightGray,
                renderingMode: .alwaysOriginal
            )
        deleteButton.setImage(deleteImage, for: .normal)
        deleteButton.addTarget(
            self,
            action: #selector(didTapDelete),
            for: .touchUpInside
        )
        contentView.addSubview(deleteButton)

        let isSelected = todoItemCellViewModel.task.status == .Todo ? false : true

        itemContent.delegate = self
        itemContent.isScrollEnabled = true
        itemContent.backgroundColor = .clear
        itemContent.text = todoItemCellViewModel.task.title
        contentView.addSubview(itemContent)
        updateTextColor(isSelected: isSelected)

        checkImage = CheckBox(isSelected: isSelected)
        if let checkImage {
            contentView.addSubview(checkImage)
        }

        setupSubscriptions()
    }

    private func setupSubscriptions() {
        checkImage?.isSelectedUpdatedPublisher.sink { [weak self] isSelected in
            guard let self else { return }

            self.updateTextColor(isSelected: isSelected)

            self.todoItemCellViewModel?.task.status = isSelected ? .Done : .Todo

            DispatchQueue.main.async {
                if let task = self.todoItemCellViewModel?.task {
                    self.delegate?.updateTask(
                        task: task,
                        indexPath: self.indexPath
                    )
                }
            }

        }.store(in: &cancellables)
    }

    private func updateTextColor(isSelected: Bool) {
        itemContent.textColor = isSelected ? .red : .black
    }

    private func cleanUp() {
        checkImage?.isSelected = false
        checkImage = nil
        itemContent.text = nil
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
        let estimatedHeight = itemContent
            .sizeThatFits(
                CGSize(width: itemContentWidth,
                       height: size.height)
            ).height

        itemContentFrame.size.width = itemContentWidth
        itemContentFrame.size.height = max(Constants.minimumHeight, estimatedHeight)
        itemContent.frame = itemContentFrame

        return CGSize(
            width: size.width,
            height: itemContentFrame.maxY + extraSmallPadding
        )
    }

    // MARK: - Actions

    @objc private func didTapDelete() {
        delegate?.deleteTask(indexPath: indexPath)
    }

    // MARK: - UITextViewDelegate

    func textViewDidChange(_ textView: UITextView) {
        delegate?.reloadCollectionView()

        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            if let todoItemCellViewModel = self.todoItemCellViewModel {
                todoItemCellViewModel.task.title = self.itemContent.text
                delegate?.updateTask(task: todoItemCellViewModel.task, indexPath: indexPath)
            }
        }
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        guard let indexPath else { return }

        delegate?.animateKeyboard(up: true, indexPath: indexPath)
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        guard let indexPath else { return }

        delegate?.animateKeyboard(up: false, indexPath: nil)
    }
}
