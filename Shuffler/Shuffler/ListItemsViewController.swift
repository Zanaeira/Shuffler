//
//  ListItemsViewController.swift
//  Shuffler
//
//  Created by Suhayl Ahmed on 18/01/2022.
//

import UIKit

final class ListItemsViewController: UIViewController {
    
    private let textField = UITextField()
    private let stackView = UIStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        setupTextFieldForNewItem()
    }
    
    private func setupTextFieldForNewItem() {
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "New Item"
        textField.font = .preferredFont(forTextStyle: .body)
        textField.adjustsFontForContentSizeCategory = true
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(textField)
        stackView.layoutMargins = .init(top: 10, left: 10, bottom: 10, right: 10)
        stackView.isLayoutMarginsRelativeArrangement = true
        
        stackView.layer.borderColor = UIColor.label.cgColor
        stackView.layer.borderWidth = 1
        
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor, constant: 10),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor, constant: -10)
        ])
    }
    
}
