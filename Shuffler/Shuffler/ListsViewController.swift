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
    
    private let lists: [Item] = [
        Item(text: "My List"),
        Item(text: "Manārah Y2"),
        Item(text: "Madkhal Y1"),
        Item(text: "Hifz Students"),
        Item(text: "Dinner options")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        addNavigationBarButtonToAddList()
        configureHierarchy()
        configureAddAListLabel()
        updateSnapshot()
    }
    
    private func updateSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.main])
        snapshot.appendItems(lists, toSection: .main)
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func addNavigationBarButtonToAddList() {
        navigationItem.setRightBarButton(.init(barButtonSystemItem: .add, target: self, action: #selector(addList)), animated: true)
    }
    
    @objc private func addList() {
        
    }
    
    private func configureAddAListLabel() {
        guard lists.count == 0 else { return }
        
        addAListLabel.text = "Tap the + button to add a list"
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
    
}

// MARK: - UICollectionView helpers
extension ListsViewController {
    
    private func makeCollectionViewLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { section, layoutEnvironment in
            var config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
            config.headerMode = .firstItemInSection
            
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
