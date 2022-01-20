//
//  Cache.swift
//  Shuffler
//
//  Created by Suhayl Ahmed on 20/01/2022.
//

import Foundation

public protocol Cache {
    func retrieve(completion: @escaping (Result<[List], Error>) -> Void)
}
