//
//  DispatchClientTests.swift
//  RelocationManager
//
//  Created by Christian Tietze on 20/03/15.
//  Copyright (c) 2015 Christian Tietze. All rights reserved.
//

import Cocoa
import XCTest

import RelocationManagerServiceDomain

class DispatchClientTests: XCTestCase {

    class TestClient: UsesBoxesAndItems {
        var lastAppliedEvent: NSDictionary?
        func apply(eventRepresentation: NSDictionary) {
            lastAppliedEvent = eventRepresentation
        }
    }
    
    class TestEvent: ClientEvent {
        var dictionaryRepresentation: NSDictionary = ["irrelevant" : "value"]
    }
    
    let clientDouble = TestClient()
    lazy var dispatcher: DispatchClient = DispatchClient(client: self.clientDouble)
    
    func testSendingEvent_DispatchesEventRepresentation() {
        let eventStub = TestEvent()
        
        dispatcher.send(eventStub)
        
        if let lastEvent = clientDouble.lastAppliedEvent {
            XCTAssertEqual(lastEvent, eventStub.dictionaryRepresentation)
        } else {
            XCTFail("no event sent")
        }
    }
}
