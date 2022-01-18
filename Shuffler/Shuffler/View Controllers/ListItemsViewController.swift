//
//  ListItemsViewController.swift
//  Shuffler
//
//  Created by Suhayl Ahmed on 18/01/2022.
//

import UIKit

final class ListItemsViewController: UIViewController {
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeCollectionViewLayout())
    private lazy var dataSource = makeDataSource()
    
    private var items: [Item] = [Item(text: "Items")]
    
    private let textField = UITextField()
    private let textFieldStackView = UIStackView()
    private let button = UIButton()
    
    private var normalConstraints: [NSLayoutConstraint] = []
    private var accessibilityConstraints: [NSLayoutConstraint] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        setupKeyboardDismissTapGestureRecognizer()
        setupConstraints()
        setupTextFieldAndButton()
        configureHierarchy()
        updateSnapshot()
    }
    
    @objc private func addItem() {
        guard let itemText = textField.text,
              !itemText.isEmpty else { return }
        
        textField.resignFirstResponder()
        textField.text = ""
        
        items.append(Item(text: itemText))
        
        updateSnapshot()
    }
    
    private func updateSnapshot() {
        guard items.count > 1 else {
            dataSource.apply(.init())
            return
        }
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.main])
        snapshot.appendItems(items, toSection: .main)
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func setupKeyboardDismissTapGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: textField, action: #selector(resignFirstResponder))
        view.addGestureRecognizer(tapGestureRecognizer)
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
    
    private func addTextFieldAndButton() {
        view.addSubview(textFieldStackView)
        view.addSubview(button)
        
        updateConstraints()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        let isAccessibilityCategory = traitCollection.preferredContentSizeCategory.isAccessibilityCategory
        if isAccessibilityCategory != previousTraitCollection?.preferredContentSizeCategory.isAccessibilityCategory {
            updateConstraints()
        }
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
    
}

// MARK: - UICollectionView Helpers
extension ListItemsViewController {
    
    private func configureHierarchy() {
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.translatesAutoresizingMaskIntoConstraints = false
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
                    
                    self.items.remove(at: indexPath.item)
                    self.updateSnapshot()
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
            
            guard indexPath.item != 0 else { return }
            
            let deleteAccessory: UICellAccessory = .delete(displayed: .whenEditing) { [weak self] in
                self?.delete(item)
            }
            
            cell.accessories = [deleteAccessory]
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

extension ListItemsViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        addItem()
        return true
    }
    
}
