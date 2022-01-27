//
//  ListError.swift
//  Shuffler
//
//  Created by Suhayl Ahmed on 26/01/2022.
//

import Foundation

public enum ListError: Error {
    case listNotFound
    case itemNotFound
    case unableToAddItem
    case unableToAddLists
    case unableToInsertLists
    case unableToUpdateList
    case unableToDeleteItem
    case unableToDeleteList
}
