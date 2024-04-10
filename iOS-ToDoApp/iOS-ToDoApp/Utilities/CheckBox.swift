//
//  CheckBox.swift
//  iOS-ToDoApp
//
//  Created by Haley Kwiat on 4/9/24.
//

import Combine
import UIKit

class CheckBox: UIButton {

    var isSelectedUpdatedPublisher: AnyPublisher<Bool, Never> {
        return isSelectedUpdatedSubject.eraseToAnyPublisher()
    }
    private let isSelectedUpdatedSubject = PassthroughSubject<Bool, Never>()

    override var isSelected: Bool {
        didSet {
            setImage(checkBoxImage, for: .normal)
        }
    }

    var checkBoxImage: UIImage? {
        let emptyCheckBox = UIImage(systemName: "circle")?
            .withTintColor(
                .darkGray,
                renderingMode: .alwaysOriginal
            )
        let fullCheckBox = UIImage(systemName: "checkmark.circle.fill")?
            .withTintColor(
                .darkGray,
                renderingMode: .alwaysOriginal
            )

        return isSelected ? fullCheckBox : emptyCheckBox
    }

    // MARK: - Lifecycle
    
    init(isSelected: Bool) {
        super.init(frame: .zero)

        self.isSelected = isSelected

        addTarget(self, action: #selector(didTapCheck), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Actions

    @objc func didTapCheck() {
        isSelected = !isSelected
        isSelectedUpdatedSubject.send(isSelected)
    }
}
