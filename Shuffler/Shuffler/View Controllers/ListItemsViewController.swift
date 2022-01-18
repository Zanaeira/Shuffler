//
//  ListItemsViewController.swift
//  Shuffler
//
//  Created by Suhayl Ahmed on 18/01/2022.
//

import UIKit

final class ListItemsViewController: UIViewController {
    
    private let textField = UITextField()
    private let textFieldStackView = UIStackView()
    private let button = UIButton()
    private let stackView = UIStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        setupKeyboardDismissTapGestureRecognizer()
        setupSubviews()
    }
    
    private func setupKeyboardDismissTapGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: textField, action: #selector(resignFirstResponder))
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    private func setupSubviews() {
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
    }
    
    private func setupStackView() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .fillProportionally
        [textFieldStackView, button].forEach(stackView.addArrangedSubview)
        
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor, constant: 10),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor, constant: -10)
        ])
    }
    
}
