//
//  ToDoListViewController.swift
//  iOS-ToDoApp
//
//  Created by Haley Kwiat on 4/9/24.
//

import Combine
import UIKit

class ToDoListViewController: UIViewController,
                              CellDelegate,
                              UICollectionViewDataSource,
                              UICollectionViewDelegateFlowLayout
{
    private var collectionView: UICollectionView

    private let viewModel = ToDoListViewModel()

    private var cancellables = Set<AnyCancellable>()

    private var keyboardOffset: CGFloat = 0

    // MARK: - UI Elements

    private let titleLabel = UILabel()

    private let createButton = UIButton()

    // MARK: - Lifecycle

    init() {
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.scrollDirection = .vertical
        self.collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )
        collectionView.showsVerticalScrollIndicator = false

        super.init(nibName: nil, bundle: nil)

        collectionView.dataSource = self
        collectionView.delegate = self

        for cellType in viewModel.cellTypes {
            collectionView.register(
                cellType,
                forCellWithReuseIdentifier: cellType.reuseID
            )
        }

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .darkGray

        titleLabel.font = .boldSystemFont(ofSize: 24)
        titleLabel.textColor = .white
        titleLabel.text = "Todo List"
        view.addSubview(titleLabel)

        let createImage = UIImage(
            systemName: "plus",
            withConfiguration: UIImage.SymbolConfiguration(
                weight: .semibold
            )
        )?.withTintColor(
                .white,
                renderingMode: .alwaysOriginal
            )
        createButton.setImage(
            createImage,
            for: .normal
        )
        createButton.addTarget(self, action: #selector(didTapCreate), for: .touchUpInside)
        view.addSubview(createButton)

        view.addSubview(collectionView)
        collectionView.backgroundColor = .darkGray

        setupSubscriptions()
    }

    private func setupSubscriptions() {
        viewModel.cellUpdatedPublisher.sink { [weak self] _ in
            self?.collectionView.reloadData()
        }.store(in: &cancellables)
    }

    // MARK: - Layout

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let smallPadding: CGFloat = 12
        let mediumPadding: CGFloat = 24

        var titleLabelFrame = CGRect.zero
        titleLabelFrame.size = titleLabel.intrinsicContentSize
        titleLabelFrame.origin.x = mediumPadding
        titleLabelFrame.origin.y = view.safeAreaInsets.top
        titleLabel.frame = titleLabelFrame

        var createButtonFrame = CGRect.zero
        createButtonFrame.size = createButton.intrinsicContentSize
        createButtonFrame.origin.x = view.bounds.width - mediumPadding - createButtonFrame.width
        createButtonFrame.origin.y = titleLabelFrame.origin.y
        createButton.frame = createButtonFrame

        var collectionViewFrame = CGRect.zero
        collectionViewFrame.size.width = view.bounds.width - (2 * mediumPadding)
        collectionViewFrame.size.height = view.bounds.height - view.safeAreaInsets.top - view.safeAreaInsets.bottom - titleLabelFrame.height - keyboardOffset
        collectionViewFrame.origin.x = titleLabelFrame.origin.x
        collectionViewFrame.origin.y = titleLabelFrame.maxY + smallPadding
        collectionView.frame = collectionViewFrame
    }

    func animateKeyboard(up: Bool, indexPath: IndexPath?) {
        keyboardOffset = up ? 315 : 0
        UIView.animate(
            withDuration: 0.3,
            delay: 0.0,
            options: .curveEaseOut,
            animations: {
                self.view.setNeedsLayout()
            }
        ){ didFinish in
            guard didFinish else { return }

            if let indexPath {
                self.collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
            }
        }
    }

    // MARK: - UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.numberOfItemsIn(section: section)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let vm = viewModel.cellViewModel(indexPath: indexPath)

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: viewModel.reuseId(at: indexPath) ?? "",
            for: indexPath
        )

        (cell as? ReusableViewType)?.viewModel = vm
        (cell as? ToDoItemCell)?.delegate = self
        (cell as? ToDoItemCell)?.indexPath = indexPath

        return cell
    }

    // MARK: - UICollectionViewDelegateFlowLayout

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = ToDoItemCell().sizeThatFits(
            CGSize(
                width: collectionView.bounds.width,
                height: .greatestFiniteMagnitude
            )
        )
        return size
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2.0
    }

    // MARK: - CellDelegate

    func updateTask(task: Task, indexPath: IndexPath?) {
        viewModel.updateTask(task: task, indexPath: indexPath)
    }

    func deleteTask(indexPath: IndexPath?) {
       viewModel.deleteTask(indexPath: indexPath)
    }

    func reloadCollectionView() {
        collectionView.collectionViewLayout.invalidateLayout()
    }

    // MARK: - Actions

    @objc private func didTapCreate() {
        viewModel.addTask()
    }
}
