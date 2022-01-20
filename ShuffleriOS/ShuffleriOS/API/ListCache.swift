//
//  ListCache.swift
//  Shuffler
//
//  Created by Suhayl Ahmed on 18/01/2022.
//

import Foundation

final class ListCache {
    
    private var lists: [List] = loadSampleLists()
    
    func retrieve(completion: @escaping (Result<[List], Error>) -> Void) {
        completion(.success(lists))
    }
    
    func update(list: List, newItems: [Item]) {
        var newLists = [List]()
        for originalList in lists {
            if originalList.id == list.id {
                newLists.append(List(name: list.name, items: newItems))
            } else {
                newLists.append(originalList)
            }
        }
        
        lists = newLists
    }
    
    private static func loadSampleLists() -> [List] {
        var lists = [List]()
        
        lists.append(.init(name: "Manārah Y2", items: [
            .init(text: "Abdullah"),
            .init(text: "Ali"),
            .init(text: "Asma"),
            .init(text: "Aysha"),
            .init(text: "Ferdoushi"),
            .init(text: "Mahbub"),
            .init(text: "Muktadeer"),
            .init(text: "Parvez"),
            .init(text: "Rosna"),
            .init(text: "Dr. Khaled"),
            .init(text: "Tahir"),
            .init(text: "Yassin"),
            .init(text: "Zainab"),
            .init(text: "Hasanayn")
        ]))
        
        lists.append(.init(name: "Madkhal Y1", items: [
            .init(text: "Aysma"),
            .init(text: "Eiram"),
            .init(text: "Hamida"),
            .init(text: "Ismail"),
            .init(text: "Rabia"),
            .init(text: "Saher"),
            .init(text: "Saima"),
            .init(text: "Sadiyah")
        ]))
        
        lists.append(.init(name: "Hifz Class", items: [
            .init(text: "Fatima"),
            .init(text: "Khalid"),
            .init(text: "Faiza"),
            .init(text: "Erina"),
            .init(text: "Zafir")
        ]))
        
        return lists
    }
    
}