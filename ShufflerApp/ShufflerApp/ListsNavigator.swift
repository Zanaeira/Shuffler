//
//  ListsNavigator.swift
//  ShufflerApp
//
//  Created by Suhayl Ahmed on 26/01/2022.
//

import UIKit
import Shuffler
import ShuffleriOS

final class ListsNavigator {
    
    let navigationController: UINavigationController
    
    private let listsManager: ListsManager
    private let listsViewController: ListsViewController
    
    init(listsManager: ListsManager) {
        self.listsManager = listsManager
        
        navigationController = UINavigationController()
        let onListSelectedHandler = ListsNavigator.listSelectedHandler(listsManager: listsManager, navigationController: navigationController)
        listsViewController = ListsViewController(listsManager: listsManager, onListSelected: onListSelectedHandler)
        listsViewController.title = "Shuffler"
        
        navigationController.pushViewController(listsViewController, animated: true)
    }
    
    private static func listSelectedHandler(listsManager: ListsManager, navigationController: UINavigationController) -> ((List) -> Void) {
        let handler: (List) -> Void = { list in
            let listItemsSegmentedViewController = ListItemsSegmentedViewController(list: list, listsManager: listsManager)
            
            navigationController.pushViewController(listItemsSegmentedViewController, animated: true)
        }
        
        return handler
    }
    
}

