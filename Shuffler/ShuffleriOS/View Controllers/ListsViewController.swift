//
//  ListsViewController.swift
//  ShuffleriOS
//
//  Created by Suhayl Ahmed on 26/01/2022.
//

import UIKit
import Shuffler

public final class ListsViewController: UIViewController {
    
    required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }
    
    private let noListsLabel = UILabel()
    private lazy var collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: makeCollectionViewLayout())
    private lazy var dataSource = makeDataSource()
    
    private let listsManager: ListsManager
    private let onListSelected: (List) -> Void
    private let headerList = List(id: UUID(), name: "My Lists", items: [])
    private var lists = [List]() {
        didSet {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    public init(listsManager: ListsManager, onListSelected: @escaping (List) -> Void) {
        self.listsManager = listsManager
        self.onListSelected = onListSelected
        
        super.init(nibName: nil, bundle: nil)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        setupEditButton()
        setupAddListBarButtonItem()
        configureHierarchy()
        configureAddAListLabel()
        loadLists()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadLists()
    }
    
    private func setupEditButton() {
        if !lists.isEmpty {
            navigationItem.leftBarButtonItem = editButtonItem
        } else {
            setEditing(false, animated: true)
            navigationItem.leftBarButtonItem = nil
        }
    }
    
    public override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        collectionView.isEditing = editing
    }
    
    private func setupAddListBarButtonItem() {
        navigationItem.setRightBarButton(.init(barButtonSystemItem: .add, target: self, action: #selector(addList)), animated: true)
    }
    
    @objc private func addList() {
        requestListName(alertTitle: "Add list", alertMessage: "Enter the name of your new list") { newListName in
            self.addNewList(newListName)
        }
    }
    
    private func editListName(_ list: List) {
        requestListName(alertTitle: "Edit \(list.name) name", alertMessage: "Enter the new name for list") { newListName in
            self.changeListName(for: list, toNewName: newListName)
        }
    }
    
    private func requestListName(alertTitle: String, alertMessage: String, action: @escaping (String) -> Void) {
        let alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        alertController.addTextField()
        alertController.textFields?.first?.autocapitalizationType = .words
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { _ in
            guard let newListName = alertController.textFields?.first?.text,
                  !newListName.isEmpty else { return }
            
            action(newListName)
        }
        
        alertController.addAction(submitAction)
        alertController.addAction(.init(title: "Cancel", style: .cancel))
        
        present(alertController, animated: true)
    }
    
    private func addNewList(_ listName: String) {
        let newList = List(id: UUID(), name: listName, items: [])
        listsManager.add([newList], completion: handleResult)
    }
    
    private func changeListName(for list: List, toNewName newListName: String) {
        listsManager.editName(list, newName: newListName, completion: handleResult)
    }
    
    private func delete(_ list: List) {
        listsManager.delete([list], completion: handleResult)
    }
    
    private func updateListOrder(_ listsInNewOrder: [List]) {
        listsManager.insert(listsInNewOrder, completion: handleResult)
    }
    
    private func handleResult(_ result: ListsUpdater.Result) {
        switch result {
        case let .success(lists):
            self.lists = lists
            self.updateSnapshot()
        case .failure:
            return
        }
    }
    
    private func configureAddAListLabel() {
        let text = "Tap the + button to add a list"
        let attributedText = NSMutableAttributedString(string: text, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .title1)])
        attributedText.addAttribute(.foregroundColor, value: UIColor.systemBlue, range: .init(location: 8, length: 1))
        
        noListsLabel.attributedText = attributedText
        noListsLabel.translatesAutoresizingMaskIntoConstraints = false
        noListsLabel.font = .preferredFont(forTextStyle: .title1)
        noListsLabel.textAlignment = .center
        noListsLabel.adjustsFontForContentSizeCategory = true
        noListsLabel.numberOfLines = 0
        
        let horizontalSpacing: CGFloat = 24
        
        collectionView.addSubview(noListsLabel)
        NSLayoutConstraint.activate([
            noListsLabel.leadingAnchor.constraint(equalTo: collectionView.readableContentGuide.leadingAnchor, constant: horizontalSpacing),
            noListsLabel.trailingAnchor.constraint(equalTo: collectionView.readableContentGuide.trailingAnchor, constant: -horizontalSpacing),
            noListsLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func loadLists() {
        listsManager.load(completion: handleResult)
    }
    
    private func updateSnapshot() {
        configureNoListsLabelVisibility()
        setupEditButton()
        
        guard !lists.isEmpty else {
            dataSource.apply(.init())
            return
        }
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, List>()
        snapshot.appendSections([.main])
        snapshot.appendItems(lists, toSection: .main)
        
        DispatchQueue.main.async {
            self.dataSource.apply(snapshot, animatingDifferences: true)
        }
    }
    
    private func configureNoListsLabelVisibility() {
        noListsLabel.isHidden = !lists.isEmpty
    }
    
}

// MARK: - UICollectionViewController Helpers
extension ListsViewController {
    
    private func configureHierarchy() {
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.delegate = self
        view.addSubview(collectionView)
    }
    
    private func makeCollectionViewLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { section, layoutEnvironment in
            var config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
            config.headerMode = .supplementary
            
            config.leadingSwipeActionsConfigurationProvider = { indexPath in
                let list = self.lists[indexPath.item]
                let renameListActionHandler: UIContextualAction.Handler = { action, view, completion in
                    self.editListName(list)
                    completion(true)
                }
                
                let renameAction = UIContextualAction(style: .normal, title: "Rename \(list.name)", handler: renameListActionHandler)
                renameAction.image = UIImage(systemName: "pencil")
                renameAction.backgroundColor = .systemBlue
                
                return UISwipeActionsConfiguration(actions: [renameAction])
            }
            
            config.trailingSwipeActionsConfigurationProvider = { indexPath in
                let delete = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (_, _, _) in
                    guard let self = self else { return }
                    
                    let list = self.lists[indexPath.item]
                    self.delete(list)
                }
                
                return UISwipeActionsConfiguration(actions: [delete])
            }
            
            return NSCollectionLayoutSection.list(using: config, layoutEnvironment: layoutEnvironment)
        }
    }
    
    private func makeDataSource() -> UICollectionViewDiffableDataSource<Section, List> {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, List> { (cell, indexPath, item) in
            cell.configure(with: item, itemOrList: "Item", numberOfLists: item.items.count)
            
            let renameAction = UIAction(image: UIImage(systemName: "pencil")) { [weak self] _ in
                guard let self = self else { return }
                self.editListName(item)
            }
            let renameButton = UIButton(primaryAction: renameAction)
            let renameAccessoryConfiguration = UICellAccessory.CustomViewConfiguration(customView: renameButton, placement: .leading(displayed: .whenEditing))
            let renameAccessory = UICellAccessory.customView(configuration: renameAccessoryConfiguration)
            
            let deleteAccessory: UICellAccessory = .delete(displayed: .whenEditing) { [weak self] in
                self?.delete(item)
            }
            let reorderAccessory: UICellAccessory = .reorder(displayed: .whenEditing)
            
            cell.accessories = [renameAccessory, deleteAccessory, reorderAccessory]
        }
        
        let dataSource: UICollectionViewDiffableDataSource<Section, List> = .init(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
        }
        
        dataSource.reorderingHandlers.canReorderItem = { list -> Bool in
            return true
        }
        
        dataSource.reorderingHandlers.didReorder = { transaction in
            let listsInNewOrder = transaction.finalSnapshot.itemIdentifiers(inSection: .main)
            
            self.updateListOrder(listsInNewOrder)
        }
        
        let headerRegistration = UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(elementKind: UICollectionView.elementKindSectionHeader) { supplementaryView, elementKind, indexPath in
            let headerItem = self.headerList
            supplementaryView.configure(with: headerItem, itemOrList: "List", numberOfLists: self.lists.count)
        }
        
        dataSource.supplementaryViewProvider = { (collectionView, elementKind, indexPath) -> UICollectionReusableView? in
            return collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
        }
        
        return dataSource
    }
    
}

// MARK: - UICollectionViewDelegate
extension ListsViewController: UICollectionViewDelegate {
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let list = lists[indexPath.item]
        onListSelected(list)
        
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
}

private extension UICollectionViewListCell {
    
    func configure(with list: List, itemOrList: String, numberOfLists: Int) {
        var config = defaultContentConfiguration()
        config.text = list.name
        config.secondaryText = "\(numberOfLists) \(itemOrList)\(numberOfLists == 1 ? "" : "s")"
        config.prefersSideBySideTextAndSecondaryText = true
        
        contentConfiguration = config
    }
    
}
