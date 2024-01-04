//
//  IdentifiableURL.swift
//  ODRTest
//
//  Created by Ilias Mirzoiev on 04.01.2024.
//

import Foundation

struct IdentifiableURL: Identifiable, Equatable {
    let id: UUID
    let url: URL

    init(url: URL) {
        self.id = UUID() 
        self.url = url
    }
}
