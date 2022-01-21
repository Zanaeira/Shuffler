//
//  Item.swift
//  Shuffler
//
//  Created by Suhayl Ahmed on 21/01/2022.
//

import Foundation

public struct Item: Equatable {
    
    public let id: UUID
    public let text: String
    
    public init(id: UUID, text: String) {
        self.id = id
        self.text = text
    }
    
}
