//
//  ListsViewController.swift
//  Shuffler
//
//  Created by Suhayl Ahmed on 17/01/2022.
//

import UIKit

final class ListsViewController: UIViewController {
    
    private let addAListLabel = UILabel()
    private lazy var collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: makeCollectionViewLayout())
    private lazy var dataSource = makeDataSource()
    
    private var lists: [Item] = [Item(text: "My lists")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        addNavigationBarButtonToAddList()
        configureHierarchy()
        configureAddAListLabel()
        updateSnapshot()
    }
    
    private func updateSnapshot() {
        configureAddAListLabelVisibility()
        
        guard lists.count > 1 else {
            dataSource.apply(.init())
            return
        }
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.main])
        snapshot.appendItems(lists, toSection: .main)
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func addNavigationBarButtonToAddList() {
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
        lists.append(Item(text: listName))
        
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
        view.addSubview(collectionView)
    }
    
    private func makeDataSource() -> UICollectionViewDiffableDataSource<Section, Item> {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Item> { (cell, indexPath, item) in
            cell.configure(with: item)
        }
        
        return .init(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
        }
    }
    
}

private extension UICollectionViewListCell {
    
    func configure(with item: Item) {
        var config = defaultContentConfiguration()
        config.text = item.text
        
        contentConfiguration = config
    }
    
}

private enum Section {
    case main
}

private struct Item: Hashable {
    private let id = UUID()
    let text: String
}
