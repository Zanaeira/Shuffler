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
    private let listUpdater: ListUpdater
    
    init(listLoader: ListLoader, listUpdater: ListUpdater) {
        listsViewController = ListsViewController(listLoader: listLoader)
        self.navigationController = UINavigationController(rootViewController: listsViewController)
        self.listUpdater = listUpdater
        
        listsViewController.onListSelected = listSelected
    }
    
    private func listSelected(_ list: List) {
        let viewController = ListItemsViewController(list: list, onListUpdated: updateList)
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
    private func updateList(_ list: List, newItems: [Item]) {
        listUpdater.update(list: list, newItems: newItems)
    }
    
}
