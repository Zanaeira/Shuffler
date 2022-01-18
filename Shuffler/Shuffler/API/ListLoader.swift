//
//  ListLoader.swift
//  Shuffler
//
//  Created by Suhayl Ahmed on 18/01/2022.
//

import Foundation

protocol ListLoader {
    func load(completion: (Result<[List], Error>) -> Void)
}
