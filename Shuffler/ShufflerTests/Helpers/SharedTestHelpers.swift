//
//  SharedTestHelpers.swift
//  ShufflerTests
//
//  Created by Suhayl Ahmed on 21/01/2022.
//

import Foundation
import Shuffler

func anyList() -> List {
    List(id: UUID(), name: "Any List", items: [])
}

func anyError() -> NSError {
    NSError(domain: "Test Error", code: 0)
}
