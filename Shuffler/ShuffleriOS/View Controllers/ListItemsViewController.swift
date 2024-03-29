//
//  ListItemsViewController.swift
//  ShuffleriOS
//
//  Created by Suhayl Ahmed on 26/01/2022.
//

import UIKit
import Shuffler

public final class ListItemsViewController: UIViewController {
    
    required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeCollectionViewLayout())
    private lazy var dataSource = makeDataSource()
    
    private let listsManager: ListsManager
    
    private let headerItem = Item(id: UUID(), text: "Items")
    private var originalList: List
    private var list: List
    private var items: [Item] {
        list.items
    }
    
    private let titleLabel = UILabel()
    private let textField = UITextField()
    private let addItemButton = UIButton()
    
    private var normalConstraints: [NSLayoutConstraint] = []
    private var accessibilityConstraints: [NSLayoutConstraint] = []
    
    public var onUpdated: (() -> Void)?
    
    public init(list: List, listsManager: ListsManager) {
        self.originalList = list
        self.list = list
        self.listsManager = listsManager
        
        super.init(nibName: nil, bundle: nil)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemGroupedBackground
        
        setupKeyboardDismissTapGestureRecognizer()
        setupConstraints()
        setupSubviews()
        configureHierarchy()
        updateSnapshot()
    }
    
    private func setupKeyboardDismissTapGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: textField, action: #selector(resignFirstResponder))
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    private func setupConstraints() {
        normalConstraints = [
            titleLabel.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor, constant: 10),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor, constant: -10),
            addItemButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            addItemButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            textField.trailingAnchor.constraint(equalTo: addItemButton.leadingAnchor, constant: -24),
            textField.topAnchor.constraint(equalTo: addItemButton.topAnchor),
            textField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            addItemButton.centerYAnchor.constraint(equalTo: textField.centerYAnchor)
        ]
        
        accessibilityConstraints = [
            titleLabel.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor, constant: 10),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor, constant: -10),
            textField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            textField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            addItemButton.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 10),
            addItemButton.centerXAnchor.constraint(equalTo: textField.centerXAnchor)
        ]
    }
    
    private func setupSubviews() {
        setupTitleLabel()
        setupTextField()
        setupAddItemButton()
        
        addSubviews()
    }
    
    private func setupTitleLabel() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = list.name
        titleLabel.font = .preferredFont(forTextStyle: .title1)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .natural
    }
    
    private func setupTextField() {
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        textField.placeholder = "New Item"
        textField.font = .preferredFont(forTextStyle: .body)
        textField.adjustsFontForContentSizeCategory = true
        textField.clearButtonMode = .whileEditing
        textField.backgroundColor = .secondarySystemGroupedBackground
        textField.borderStyle = .roundedRect
        textField.delegate = self
    }
    
    private func setupAddItemButton() {
        addItemButton.translatesAutoresizingMaskIntoConstraints = false
        addItemButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        addItemButton.setTitle("Add", for: .normal)
        addItemButton.titleLabel?.adjustsFontForContentSizeCategory = true
        addItemButton.titleLabel?.font = .preferredFont(forTextStyle: .body)
        addItemButton.setTitleColor(.systemBlue, for: .normal)
        addItemButton.addTarget(self, action: #selector(addItem), for: .touchUpInside)
    }
    
    @objc private func addItem() {
        guard let itemText = textField.text?.trimmingCharacters(in: .whitespaces),
              !itemText.isEmpty else { return }
        
        textField.resignFirstResponder()
        textField.text = ""
        
        let newItem = Item(id: UUID(), text: itemText)
        listsManager.addItem(newItem, to: originalList, completion: handleResult)
    }
    
    private func delete(_ item: Item) {
        listsManager.deleteItem(item, from: originalList, completion: handleResult)
    }
    
    private func handleResult(_ result: ListsUpdater.Result) {
        switch result {
        case let .success(lists):
            guard let updatedList = lists.first(where: { $0.id == self.list.id } ) else {
                return
            }
            
            self.originalList = updatedList
            self.list = updatedList
            self.updateSnapshot()
        case .failure:
            return
        }
    }
    
    private func updateSnapshot() {
        onUpdated?()
        
        guard !items.isEmpty else {
            dataSource.apply(.init())
            return
        }
        
        let itemsToAppend = [headerItem] + items
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.main])
        snapshot.appendItems(itemsToAppend, toSection: .main)
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    public func canBeShuffled() -> Bool {
        items.count > 1
    }
    
    @objc public func shuffle() {
        list = List(id: list.id, name: list.name, items: list.items.shuffled())
        updateSnapshot()
    }
    
    private func addSubviews() {
        view.addSubview(titleLabel)
        view.addSubview(textField)
        view.addSubview(addItemButton)
        
        updateConstraints()
    }
    
    private func updateConstraints() {
        let isAccessibilityCategory = traitCollection.preferredContentSizeCategory.isAccessibilityCategory
        if isAccessibilityCategory {
            NSLayoutConstraint.deactivate(normalConstraints)
            NSLayoutConstraint.activate(accessibilityConstraints)
        } else {
            NSLayoutConstraint.deactivate(accessibilityConstraints)
            NSLayoutConstraint.activate(normalConstraints)
        }
    }
    
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        let isAccessibilityCategory = traitCollection.preferredContentSizeCategory.isAccessibilityCategory
        if isAccessibilityCategory != previousTraitCollection?.preferredContentSizeCategory.isAccessibilityCategory {
            updateConstraints()
        }
    }
    
}

// MARK: - UICollectionView Helpers
private extension ListItemsViewController {
    
    private func configureHierarchy() {
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemGroupedBackground
        collectionView.delegate = self
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.topAnchor.constraint(equalTo: addItemButton.bottomAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        ])
    }
    
    private func makeCollectionViewLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { section, layoutEnvironment in
            var config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
            config.headerMode = .firstItemInSection
            
            config.trailingSwipeActionsConfigurationProvider = { indexPath in
                guard indexPath.item != 0 else { return UISwipeActionsConfiguration() }
                
                let delete = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (_, _, _) in
                    guard let self = self else { return }
                    
                    let item = self.items[indexPath.item-1]
                    self.delete(item)
                }
                
                return UISwipeActionsConfiguration(actions: [delete])
            }
            
            return NSCollectionLayoutSection.list(using: config, layoutEnvironment: layoutEnvironment)
        }
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

extension ListItemsViewController: UITextFieldDelegate {
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        addItem()
        return true
    }
    
}

// MARK: - UICollectionViewDelegate
extension ListItemsViewController: UICollectionViewDelegate {
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
}

private extension UICollectionViewListCell {
    
    func configure(with item: Item) {
        var config = defaultContentConfiguration()
        config.text = item.text
        
        contentConfiguration = config
    }
    
}
