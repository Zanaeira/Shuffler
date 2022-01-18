//
//  ListsCoordinator.swift
//  Shuffler
//
//  Created by Suhayl Ahmed on 18/01/2022.
//

import UIKit

final class ListsCoordinator {
    
    let navigationController: UINavigationController
    private let listsViewController: ListsViewController
    
    init(listLoader: ListLoader) {
        listsViewController = ListsViewController(listLoader: listLoader)
        self.navigationController = UINavigationController(rootViewController: listsViewController)
        
        listsViewController.onListSelected = listSelected
    }
    
    private func listSelected(_ list: List) {
        let viewController = ListItemsViewController(list: list)
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
}
