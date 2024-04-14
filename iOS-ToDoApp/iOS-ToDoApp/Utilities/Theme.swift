//
//  Theme.swift
//  iOS-ToDoApp
//
//  Created by Haley Kwiat on 4/14/24.
//

import UIKit

var isDarkMode: Bool {
    return UIScreen.main.traitCollection.userInterfaceStyle == .dark
}

var whiteColor: UIColor {
    return isDarkMode ? .darkGray : .white
}
var grayColor: UIColor {
    return isDarkMode ? .white : .darkGray
}
