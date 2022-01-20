//
//  ListUpdater.swift
//  Shuffler
//
//  Created by Suhayl Ahmed on 18/01/2022.
//

import Foundation

protocol ListUpdater {
    func update(list: List, newItems: [Item])
}
