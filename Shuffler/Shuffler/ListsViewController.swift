//
//  ListsViewController.swift
//  Shuffler
//
//  Created by Suhayl Ahmed on 17/01/2022.
//

import UIKit

final class ListsViewController: UIViewController {
    
    private let addAListLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemGray6
        addNavigationBarButtonToAddList()
        configureAddAListLabel()
    }
    
    private func addNavigationBarButtonToAddList() {
        navigationItem.setRightBarButton(.init(barButtonSystemItem: .add, target: self, action: #selector(addList)), animated: true)
    }
    
    @objc private func addList() {
        
    }
    
    private func configureAddAListLabel() {
        addAListLabel.text = "Tap the + button to add a list"
        addAListLabel.translatesAutoresizingMaskIntoConstraints = false
        addAListLabel.font = .preferredFont(forTextStyle: .title1)
        addAListLabel.textAlignment = .center
        addAListLabel.adjustsFontForContentSizeCategory = true
        addAListLabel.numberOfLines = 0
        
        let horizontalSpacing: CGFloat = 24
        
        view.addSubview(addAListLabel)
        NSLayoutConstraint.activate([
            addAListLabel.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor, constant: horizontalSpacing),
            addAListLabel.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor, constant: -horizontalSpacing),
            addAListLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
}
