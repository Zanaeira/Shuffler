//
//  UpdateError.swift
//  Shuffler
//
//  Created by Suhayl Ahmed on 22/01/2022.
//

import Foundation

public enum UpdateError: Error {
    case listNotFound
    case couldNotSaveCache
    case couldNotRetrieveCache
}
