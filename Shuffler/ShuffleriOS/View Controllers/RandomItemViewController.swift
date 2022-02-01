//
//  RandomItemViewController.swift
//  ShuffleriOS
//
//  Created by Suhayl Ahmed on 01/02/2022.
//

import UIKit
import Shuffler

public final class RandomItemViewController: UIViewController {
    
    public required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }
    
    private let itemNameLabel = UILabel()
    
    private let listsManager: ListsManager
    private let listId: UUID
    private var items: [Item]?
    
    public init(listId: UUID, listsManager: ListsManager) {
        self.listId = listId
        self.listsManager = listsManager
        
        super.init(nibName: nil, bundle: nil)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLabel()
        loadItems()
    }
    
    private func loadItems() {
        listsManager.load { [weak self] result in
            guard let self = self else { return }
            
            if case let .success(lists) = result {
                self.items = lists.filter({ $0.id == self.listId }).first?.items
            } else {
                self.items = []
            }
        }
    }
    
    public func displayRandomItem() {
        loadItems()
        itemNameLabel.text = items?.randomElement()?.text
    }
    
    private func setupLabel() {
        itemNameLabel.font = .preferredFont(forTextStyle: .largeTitle)
        itemNameLabel.adjustsFontForContentSizeCategory = true
        itemNameLabel.textColor = .systemBlue
        itemNameLabel.translatesAutoresizingMaskIntoConstraints = false
        displayRandomItem()
        
        view.addSubview(itemNameLabel)
        NSLayoutConstraint.activate([
            itemNameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            itemNameLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
}
