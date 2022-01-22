//
//  ListsLoader.swift
//  Shuffler
//
//  Created by Suhayl Ahmed on 22/01/2022.
//

import Foundation

public protocol ListsLoader {
    func load(completion: @escaping (Result<[List], Error>) -> Void)
}
