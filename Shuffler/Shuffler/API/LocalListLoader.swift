//
//  LocalListLoader.swift
//  Shuffler
//
//  Created by Suhayl Ahmed on 18/01/2022.
//

import Foundation

class LocalListLoader: ListLoader {
    
    private var lists = [List]()
    
    func load(completion: @escaping (Result<[List], Error>) -> Void) {
        loadSampleLists()
        
        completion(.success(lists))
    }
    
    private func loadSampleLists() {
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
    }
    
}
