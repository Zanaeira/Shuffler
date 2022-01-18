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
    private let stackView = UIStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        setupKeyboardDismissTapGestureRecognizer()
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
        guard items.count > 1 else { return }
        
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
        setupStackView()
    }
    
    private func setupTextField() {
        textField.translatesAutoresizingMaskIntoConstraints = false
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
        button.setTitle("Add", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.addTarget(self, action: #selector(addItem), for: .touchUpInside)
    }
    
    private func setupStackView() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 16
        stackView.distribution = .fill
        [textFieldStackView, button].forEach(stackView.addArrangedSubview)
        
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor, constant: 10),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor, constant: -10)
        ])
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
            collectionView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 10),
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
