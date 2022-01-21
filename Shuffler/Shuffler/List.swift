//
//  List.swift
//  Shuffler
//
//  Created by Suhayl Ahmed on 20/01/2022.
//

import Foundation

public struct List: Equatable {
    
    public let id: UUID
    public let name: String
    public let items: [Item]
    
    public init(id: UUID, name: String, items: [Item]) {
        self.id = id
        self.name = name
        self.items = items
    }
    
}
