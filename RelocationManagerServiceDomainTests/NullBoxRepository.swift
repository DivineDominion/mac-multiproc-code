//
//  NullBoxRepository.swift
//  RelocationManager
//
//  Created by Christian Tietze on 03/03/15.
//  Copyright (c) 2015 Christian Tietze. All rights reserved.
//

import Foundation

import RelocationManagerServiceDomain

class NullBoxRepository: BoxRepository {
    init() { }
    
    func nextId() -> BoxId { return BoxId(0) }
    
    func nextItemId() -> ItemId { return ItemId(0) }
    
    func addBox(box: Box) { }
    func removeBox(#boxId: BoxId) { }
    
    func box(#boxId: BoxId) -> Box? { return nil }
    
    func boxes() -> [Box] { return [] }
    
    func count() -> Int { return 0 }
}
