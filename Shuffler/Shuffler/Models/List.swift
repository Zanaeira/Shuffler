//
//  List.swift
//  Shuffler
//
//  Created by Suhayl Ahmed on 18/01/2022.
//

import Foundation

struct List: Hashable {
    private let id = UUID()
    let name: String
    let items: [Item]
}
