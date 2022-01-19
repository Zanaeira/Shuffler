//
//  List.swift
//  Shuffler
//
//  Created by Suhayl Ahmed on 18/01/2022.
//

import Foundation

struct List: Hashable {
    
    let id: UUID
    let name: String
    let items: [Item]
    
    init(id: UUID = UUID(), name: String, items: [Item]) {
        self.id = id
        self.name = name
        self.items = items
    }
    
}
