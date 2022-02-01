//
//  ListItemsSegmentedViewController.swift
//  ShufflerApp
//
//  Created by Suhayl Ahmed on 31/01/2022.
//

import UIKit
import Shuffler
import ShuffleriOS

final class ListItemsSegmentedViewController: UIViewController {
    
    required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }
    
    private let listItemsViewController: ListItemsViewController
    
    private let segmentedControl = UISegmentedControl(items: ["List", "Random Item"])
    
    init(list: List, listsManager: ListsManager) {
        listItemsViewController = ListItemsViewController(list: list, listsManager: listsManager)
        
        super.init(nibName: nil, bundle: nil)
        
        title = list.name
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSegmentedControl()
        setupListItemsViewController()
        setupShuffleBarButtonItem()
    }
    
    private func setupListItemsViewController() {
        add(listItemsViewController)
        listItemsViewController.view.frame = view.bounds
        listItemsViewController.onUpdated = setupShuffleBarButtonItem
    }
    
    private func setupSegmentedControl() {
        navigationItem.titleView = segmentedControl
        segmentedControl.selectedSegmentIndex = 0
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func setupShuffleBarButtonItem() {
        let shuffleBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "shuffle.circle"), style: .plain, target: self, action: #selector(shuffle))
        
        if listItemsViewController.canBeShuffled() {
            navigationItem.setRightBarButton(shuffleBarButtonItem, animated: true)
        } else {
            navigationItem.setRightBarButton(nil, animated: true)
        }
    }
    
    @objc private func shuffle() {
        listItemsViewController.shuffle()
    }
    
}

private extension UIViewController {
    func add(_ child: UIViewController) {
        addChild(child)
        view.addSubview(child.view)
        child.didMove(toParent: self)
    }
    
    func removeSelfFromParent() {
        guard parent != nil else { return }
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
}
