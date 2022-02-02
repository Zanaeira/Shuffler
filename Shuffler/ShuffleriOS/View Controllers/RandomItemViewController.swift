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
    private let instructionsLabel = UILabel()
    
    private let listsManager: ListsManager
    private let listId: UUID
    private var items: [Item]?
    private var timer: Timer?
    
    public init(listId: UUID, listsManager: ListsManager) {
        self.listId = listId
        self.listsManager = listsManager
        
        super.init(nibName: nil, bundle: nil)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemGroupedBackground
        setupItemNameLabel()
        setupInstructionsLabel()
        setupTimer()
        loadItems()
    }
    
    public func reloadItems() {
        loadItems()
    }
    
    private func loadItems() {
        listsManager.load { [weak self] result in
            guard let self = self else { return }
            
            if case let .success(lists) = result {
                self.items = lists.filter({ $0.id == self.listId }).first?.items
            } else {
                self.items = []
            }
        }
    }
    
    private func setupTimer() {
        self.timer = .scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { _ in
            self.itemNameLabel.text = self.items?.randomElement()?.text
        })
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(toggleTimer))
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc private func toggleTimer() {
        guard let timer = timer else { return }
        
        if timer.isValid {
            timer.invalidate()
        } else {
            self.timer = .scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { _ in
                self.itemNameLabel.text = self.items?.randomElement()?.text
            })
        }
        
        toggleInstructionsText()
    }
    
    private func setupItemNameLabel() {
        itemNameLabel.font = .preferredFont(forTextStyle: .largeTitle)
        itemNameLabel.textAlignment = .center
        itemNameLabel.adjustsFontForContentSizeCategory = true
        itemNameLabel.numberOfLines = 3
        itemNameLabel.textColor = .systemBlue
        itemNameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(itemNameLabel)
        NSLayoutConstraint.activate([
            itemNameLabel.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor, constant: 10),
            itemNameLabel.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor, constant: 10),
            itemNameLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupInstructionsLabel() {
        instructionsLabel.textAlignment = .center
        instructionsLabel.adjustsFontForContentSizeCategory = true
        instructionsLabel.numberOfLines = 0
        instructionsLabel.translatesAutoresizingMaskIntoConstraints = false
        setInitialInstructionsText()
        
        view.addSubview(instructionsLabel)
        NSLayoutConstraint.activate([
            instructionsLabel.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor, constant: 10),
            instructionsLabel.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor, constant: 10),
            instructionsLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    private func toggleInstructionsText() {
        setInstructionsText()
    }
    
    private func setInstructionsText() {
        let text: String
        let length: Int
        let color: UIColor
        if timer?.isValid ?? false {
            text = "Tap the screen to stop shuffling"
            length = 4
            color = .systemRed
        } else {
            text = "Tap the screen to start shuffling"
            length = 5
            color = .systemGreen
        }
        
        let attributedText = NSMutableAttributedString(string: text, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .callout)])
        attributedText.addAttribute(.foregroundColor, value: color, range: .init(location: 18, length: length))
        
        instructionsLabel.attributedText = attributedText
    }
    
    private func setInitialInstructionsText() {
        let attributedText = NSMutableAttributedString(string: "Tap the screen to stop shuffling", attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .callout)])
        attributedText.addAttribute(.foregroundColor, value: UIColor.systemRed, range: .init(location: 18, length: 4))
        
        instructionsLabel.attributedText = attributedText
    }
    
}
