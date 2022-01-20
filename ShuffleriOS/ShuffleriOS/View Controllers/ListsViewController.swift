//
//  ListsViewController.swift
//  Shuffler
//
//  Created by Suhayl Ahmed on 17/01/2022.
//

import UIKit

final class ListsViewController: UIViewController {
    
    required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }
    
    private let addAListLabel = UILabel()
    private lazy var collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: makeCollectionViewLayout())
    private lazy var dataSource = makeDataSource()
    
    private let listLoader: ListLoader
    private let headerList = List(name: "My Lists", items: [])
    private var lists: [List] = []
    
    var onListSelected: ((List) -> Void)?
    
    init(listLoader: ListLoader) {
        self.listLoader = listLoader
        
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        setupEditButton()
        setupAddListBarButtonItem()
        configureHierarchy()
        configureAddAListLabel()
        loadLists()
        updateSnapshot()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadLists()
        updateSnapshot()
    }
    
    private func loadLists() {
        listLoader.load { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let lists):
                self.lists = [self.headerList] + lists
            case .failure:
                return
            }
        }
    }
    
    private func updateSnapshot() {
        configureAddAListLabelVisibility()
        setupEditButton()
        
        guard lists.count > 1 else {
            dataSource.apply(.init())
            return
        }
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, List>()
        snapshot.appendSections([.main])
        snapshot.appendItems(lists, toSection: .main)
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func delete(_ list: List) {
        guard let indexPath = dataSource.indexPath(for: list) else { return }
        
        lists.remove(at: indexPath.item)
        updateSnapshot()
    }
    
    private func setupEditButton() {
        if lists.count > 1 {
            navigationItem.leftBarButtonItem = editButtonItem
        } else {
            setEditing(false, animated: true)
            navigationItem.leftBarButtonItem = nil
        }
    }
    
    private func setupAddListBarButtonItem() {
        navigationItem.setRightBarButton(.init(barButtonSystemItem: .add, target: self, action: #selector(addList)), animated: true)
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        collectionView.isEditing = editing
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
        lists.append(List(name: listName, items: []))
        
        updateSnapshot()
    }
    
    private func configureAddAListLabel() {
        let text = "Tap the + button to add a list"
        let attributedText = NSMutableAttributedString(string: text, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .title1)])
        attributedText.addAttribute(.foregroundColor, value: UIColor.systemBlue, range: .init(location: 8, length: 1))
        
        addAListLabel.attributedText = attributedText
        addAListLabel.translatesAutoresizingMaskIntoConstraints = false
        addAListLabel.font = .preferredFont(forTextStyle: .title1)
        addAListLabel.textAlignment = .center
        addAListLabel.adjustsFontForContentSizeCategory = true
        addAListLabel.numberOfLines = 0
        
        let horizontalSpacing: CGFloat = 24
        
        collectionView.addSubview(addAListLabel)
        NSLayoutConstraint.activate([
            addAListLabel.leadingAnchor.constraint(equalTo: collectionView.readableContentGuide.leadingAnchor, constant: horizontalSpacing),
            addAListLabel.trailingAnchor.constraint(equalTo: collectionView.readableContentGuide.trailingAnchor, constant: -horizontalSpacing),
            addAListLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func configureAddAListLabelVisibility() {
        addAListLabel.isHidden = lists.count > 1
    }
    
}

// MARK: - UICollectionView helpers
extension ListsViewController {
    
    private func makeCollectionViewLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { section, layoutEnvironment in
            var config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
            config.headerMode = .firstItemInSection
            
            config.trailingSwipeActionsConfigurationProvider = { indexPath in
                guard indexPath.item != 0 else { return UISwipeActionsConfiguration() }
                
                let delete = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (_, _, completion) in
                    guard let self = self else { return }
                    
                    self.lists.remove(at: indexPath.item)
                    self.updateSnapshot()
                    completion(true)
                }
                
                return UISwipeActionsConfiguration(actions: [delete])
            }
            
            return NSCollectionLayoutSection.list(using: config, layoutEnvironment: layoutEnvironment)
        }
    }
    
    private func configureHierarchy() {
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.delegate = self
        view.addSubview(collectionView)
    }
    
    private func makeDataSource() -> UICollectionViewDiffableDataSource<Section, List> {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, List> { (cell, indexPath, item) in
            cell.configure(with: item)
            
            guard indexPath.item != 0 else { return }
            
            let deleteAccessory: UICellAccessory = .delete(displayed: .whenEditing) { [weak self] in
                self?.delete(item)
            }
            let reorderAccessory: UICellAccessory = .reorder(displayed: .whenEditing)
            
            cell.accessories = [deleteAccessory, reorderAccessory]
        }
        
        let dataSource: UICollectionViewDiffableDataSource<Section, List> = .init(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
        }
        
        dataSource.reorderingHandlers.canReorderItem = { list -> Bool in
            return true
        }
        
        dataSource.reorderingHandlers.didReorder = { transaction in
            self.lists = transaction.finalSnapshot.itemIdentifiers(inSection: .main)
        }
        
        return dataSource
    }
    
}

extension ListsViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.item != 0 else { return }
        
        let list = lists[indexPath.item]
        onListSelected?(list)
        
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