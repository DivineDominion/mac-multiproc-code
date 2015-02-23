//
//  BoxTests.swift
//  RelocationManager
//
//  Created by Christian Tietze on 23/02/15.
//  Copyright (c) 2015 Christian Tietze. All rights reserved.
//

import Cocoa
import XCTest

import RelocationManagerServiceDomain

class BoxTests: XCTestCase {

    func testCreateBox_SetsRawCapacity() {
        let box = Box(boxId: BoxId(1234), capacity: .Medium, title: "irrelevant")
        
        XCTAssertEqual(box.capacityRaw, BoxCapacity.Medium.rawValue)
    }

    func testChangeCapacity_UpdatesRawCapacity() {
        let box = Box(boxId: BoxId(1234), capacity: .Medium, title: "irrelevant")
        box.capacity = .Large
        
        XCTAssertEqual(box.capacityRaw, BoxCapacity.Large.rawValue)
    }
}
