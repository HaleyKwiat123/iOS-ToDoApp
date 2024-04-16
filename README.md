# Welcome to the iOS-ToDoApp! 

A to-do list application that allows users to add, edit, and delete tasks, as well as, mark tasks as completed or to-do.

## UI

In order to create the UI for this application I used UIKit with a frame based layout, which uses superviews and CGRects to create its own frames. This approach can be cumbersome with keyboard interactions, so please take a moment to appreciate the beauty of the keyboard interaction in this application. :) 

## Architecture

This application uses MVVM to organize and architect its different classes and methods. The ToDoListViewController is the main view controller that you will open the app to. This view controller uses a ToDoListViewModel that helps manage the collection view details and the flow of data to and from the CoreDataManager. There are also a custom collection view cell and view model, the ToDoItemCell and ToDoItemCellViewModel, that handle the individual todo item tasks. Another key component is the CoreDataManager, responsible for managing the flow of data within CoreData. 

You'll notice the code creating sections, viewTypes, viewModels, etc. inside the ToDoListViewModel is a little heavy for just the single section we are using it for. But the beauty of this is how it translates seamlessly to creating additional sections, even headers/footers or supplementary views. Say we were to add seperate sections for Todo and Completed tasks... we would be able to add a new case to the Section enum, a few extra case statements in the helper functions, and perhaps, a new custom cell style depending on the requirements and you would be ready to go. 

## Patterns

You will see a variety of patterns used throughout this app. The delegate pattern is used to communicate from the cells back to the parent collection view. Combine events are used to communicate from the Checkbox class back to the parent ToDoItemCell, to pass data from the CoreDataManager to the ToDoListViewModel, and to send reload events from the ToDoListViewModel to the ToDoListViewController. You will also see closures and async/await throughout the app. 

## Data Persistance

This application uses Core Data to persist TodoTask items and a simple implementation of background context to keep the heavier methods off of the main thread as to not block the UI if the data set were to get large enough. This was my first experience using Core Data! 

## Accessibility

You will see some basic accessibility labels to increase the usability for voiceover and all users.

## Dark Mode / Light Mode

This application makes use of a few global variables in the Theme file and listens to the traitCollectionDidChange property to support both light and dark mode. 

## Testing

I have included a few tests in the CoreDataManagerTests class and a CoreDataManagerMock class to test the basic create, update and delete methods of the core data implementation. Ideally we would have a few more test classes testing the viewController/viewModel, the cells, and perhaps even the checkbox implementation. 
