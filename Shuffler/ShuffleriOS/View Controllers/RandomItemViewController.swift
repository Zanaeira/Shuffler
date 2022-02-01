//
//  RandomItemViewController.swift
//  ShuffleriOS
//
//  Created by Suhayl Ahmed on 01/02/2022.
//

import UIKit
import Shuffler

public final class RandomItemViewController: UIViewController {
    
    public required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }
    
    private let itemNameLabel = UILabel()
    
    private let list: List
    
    public init(list: List) {
        self.list = list
        
        super.init(nibName: nil, bundle: nil)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLabel()
    }
    
    public func displayRandomItem() {
        itemNameLabel.text = list.randomItemName()
    }
    
    private func setupLabel() {
        itemNameLabel.font = .preferredFont(forTextStyle: .largeTitle)
        itemNameLabel.adjustsFontForContentSizeCategory = true
        itemNameLabel.textColor = .systemBlue
        itemNameLabel.translatesAutoresizingMaskIntoConstraints = false
        displayRandomItem()
        
        view.addSubview(itemNameLabel)
        NSLayoutConstraint.activate([
            itemNameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            itemNameLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
}

private extension List {
    func randomItemName() -> String? {
        items.randomElement()?.text
    }
}
