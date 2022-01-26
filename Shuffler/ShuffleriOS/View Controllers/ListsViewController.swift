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
    private let headerList = List(id: UUID(), name: "My Lists", items: [])
    private var lists = [List]()
    
    public init(listsManager: ListsManager) {
        self.listsManager = listsManager
        
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
        updateSnapshot()
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
        let alertController = UIAlertController(title: "Add list", message: "Enter the name of your new list", preferredStyle: .alert)
        alertController.addTextField()
        alertController.textFields?.first?.autocapitalizationType = .words
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { _ in
            guard let newListName = alertController.textFields?.first?.text,
                  !newListName.isEmpty else { return }
            
            self.addNewList(newListName)
        }
        
        alertController.addAction(submitAction)
        alertController.addAction(.init(title: "Cancel", style: .cancel))
        
        present(alertController, animated: true)
    }
    
    private func addNewList(_ listName: String) {
        let newList = List(id: UUID(), name: listName, items: [])
        listsManager.add([newList]) { result in
            switch result {
            case let .success(lists):
                self.lists = lists
                self.updateSnapshot()
            case .failure:
                return
            }
        }
    }
    
    private func delete(_ list: List) {
        listsManager.delete([list]) { result in
            switch result {
            case let .success(lists):
                self.lists = lists
            case .failure:
                return
            }
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
        listsManager.load { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let lists):
                self.lists = lists
            case .failure:
                return
            }
        }
    }
    
    private func updateSnapshot() {
        configureNoListsLabelVisibility()
        setupEditButton()
        
        guard !lists.isEmpty else {
            dataSource.apply(.init())
            return
        }
        
        let listsForSnapshot = [headerList] + lists
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, List>()
        snapshot.appendSections([.main])
        snapshot.appendItems(listsForSnapshot, toSection: .main)
        
        dataSource.apply(snapshot, animatingDifferences: true)
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
            config.headerMode = .firstItemInSection
            
            config.trailingSwipeActionsConfigurationProvider = { indexPath in
                guard indexPath.item != 0 else { return UISwipeActionsConfiguration() }
                
                let delete = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (_, _, completion) in
                    guard let self = self else { return }
                    
                    let list = self.lists[indexPath.item-1]
                    self.delete(list)
                    self.updateSnapshot()
                    
                    completion(true)
                }
                
                return UISwipeActionsConfiguration(actions: [delete])
            }
            
            return NSCollectionLayoutSection.list(using: config, layoutEnvironment: layoutEnvironment)
        }
    }
    
    private func makeDataSource() -> UICollectionViewDiffableDataSource<Section, List> {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, List> { (cell, indexPath, item) in
            cell.configure(with: item)
        }
        
        let dataSource: UICollectionViewDiffableDataSource<Section, List> = .init(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
        }
        
        return dataSource
    }
    
}

// MARK: - UICollectionViewDelegate
extension ListsViewController: UICollectionViewDelegate {
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
}

private extension UICollectionViewListCell {
    
    func configure(with list: List) {
        var config = defaultContentConfiguration()
        config.text = list.name
        
        contentConfiguration = config
    }
    
}
