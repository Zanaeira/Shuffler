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
    private let randomItemViewController: RandomItemViewController
    private let segmentedControl = UISegmentedControl(items: ["List", "Random"])
    
    init(list: List, listsManager: ListsManager) {
        randomItemViewController = RandomItemViewController(listId: list.id, listsManager: listsManager)
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
        
        add(randomItemViewController)
        randomItemViewController.view.frame = view.bounds
    }
    
    private func setupSegmentedControl() {
        navigationItem.titleView = segmentedControl
        segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        segmentedControl.selectedSegmentIndex = 0
        showSelectedViewController()
    }
    
    @objc private func segmentChanged() {
        showSelectedViewController()
        setupShuffleBarButtonItem()
    }
    
    private func showSelectedViewController() {
        if segmentedControl.selectedSegmentIndex == 0 {
            randomItemViewController.view.alpha = 0
            listItemsViewController.view.alpha = 1
        } else if segmentedControl.selectedSegmentIndex == 1 {
            listItemsViewController.view.alpha = 0
            randomItemViewController.view.alpha = 1
            randomItemViewController.reloadItems()
        }
    }
    
    private func setupShuffleBarButtonItem() {
				let alphabetiseBarButtonItem = UIBarButtonItem(
					image: UIImage(systemName: "textformat.characters.arrow.left.and.right"),
					style: .plain,
					target: self,
					action: #selector(alphabetise)
				)
				let shuffleBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "shuffle.circle"), style: .plain, target: self, action: #selector(shuffle))

        if listItemsViewController.canBeShuffled() && segmentedControl.selectedSegmentIndex == 0 {
						navigationItem.rightBarButtonItems = [shuffleBarButtonItem, alphabetiseBarButtonItem]
        } else {
            navigationItem.rightBarButtonItems = []
        }
    }
    
    @objc private func shuffle() {
        listItemsViewController.shuffle()
    }

		@objc private func alphabetise() {
				listItemsViewController.alphabetise()
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
