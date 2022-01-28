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
    
    private let textField = UITextField()
    private let textFieldStackView = UIStackView()
    private let button = UIButton()
    
    private var normalConstraints: [NSLayoutConstraint] = []
    private var accessibilityConstraints: [NSLayoutConstraint] = []
    
    public init(list: List, listsManager: ListsManager) {
        self.originalList = list
        self.list = list
        self.listsManager = listsManager
        
        super.init(nibName: nil, bundle: nil)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemGroupedBackground
        title = list.name
        setupKeyboardDismissTapGestureRecognizer()
        setupConstraints()
        setupTextFieldAndButton()
        configureHierarchy()
        updateSnapshot()
    }
    
    private func setupKeyboardDismissTapGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: textField, action: #selector(resignFirstResponder))
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    private func setupConstraints() {
        normalConstraints = [
            button.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            textFieldStackView.trailingAnchor.constraint(equalTo: button.leadingAnchor, constant: -24),
            textFieldStackView.topAnchor.constraint(equalTo: button.topAnchor),
            textFieldStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            button.centerYAnchor.constraint(equalTo: textFieldStackView.centerYAnchor)
        ]
        
        accessibilityConstraints = [
            textFieldStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            textFieldStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            textFieldStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            
            button.topAnchor.constraint(equalTo: textFieldStackView.bottomAnchor, constant: 10),
            button.centerXAnchor.constraint(equalTo: textFieldStackView.centerXAnchor)
        ]
    }
    
    private func setupTextFieldAndButton() {
        setupTextField()
        setupButton()
        addTextFieldAndButton()
    }
    
    private func setupTextField() {
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        textField.placeholder = "New Item"
        textField.font = .preferredFont(forTextStyle: .body)
        textField.adjustsFontForContentSizeCategory = true
        textField.clearButtonMode = .whileEditing
        textField.delegate = self
        
        textFieldStackView.translatesAutoresizingMaskIntoConstraints = false
        textFieldStackView.addArrangedSubview(textField)
        textFieldStackView.layoutMargins = .init(top: 10, left: 10, bottom: 10, right: 10)
        textFieldStackView.isLayoutMarginsRelativeArrangement = true
        
        setupTextFieldStackViewBorder()
    }
    
    private func setupTextFieldStackViewBorder() {
        textFieldStackView.layer.borderColor = UIColor.label.cgColor
        textFieldStackView.layer.borderWidth = 1
        textFieldStackView.layer.cornerRadius = 8
    }
    
    private func setupButton() {
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        button.setTitle("Add", for: .normal)
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.titleLabel?.font = .preferredFont(forTextStyle: .body)
        button.setTitleColor(.systemBlue, for: .normal)
        button.addTarget(self, action: #selector(addItem), for: .touchUpInside)
    }
    
    @objc private func addItem() {
        guard let itemText = textField.text,
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
        setupShuffleBarButtonItem()
        
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
    
    private func setupShuffleBarButtonItem() {
        let shuffleBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "shuffle.circle"), style: .plain, target: self, action: #selector(shuffle))
        
        if items.count > 1 {
            navigationItem.setRightBarButton(shuffleBarButtonItem, animated: true)
        } else {
            navigationItem.setRightBarButton(nil, animated: true)
        }
    }
    
    @objc private func shuffle() {
        list = List(id: list.id, name: list.name, items: list.items.shuffled())
        updateSnapshot()
    }
    
    private func addTextFieldAndButton() {
        view.addSubview(textFieldStackView)
        view.addSubview(button)
        
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
        
        setupTextFieldStackViewBorder()
        
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
        collectionView.delegate = self
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.topAnchor.constraint(equalTo: button.bottomAnchor, constant: 16),
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
                
                let delete = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (_, _, completion) in
                    guard let self = self else { return }
                    
                    let item = self.items[indexPath.item-1]
                    self.delete(item)
                    
                    completion(true)
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
