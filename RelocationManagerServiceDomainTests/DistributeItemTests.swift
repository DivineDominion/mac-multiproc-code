//
//  DistributeItemTests.swift
//  RelocationManager
//
//  Created by Christian Tietze on 24/02/15.
//  Copyright (c) 2015 Christian Tietze. All rights reserved.
//

import Cocoa
import XCTest

import RelocationManagerServiceDomain

class DistributeItemTests: XCTestCase {
    class TestBoxRepository: BoxRepository {
        func nextId() -> BoxId { return BoxId(0) }
        
        func nextItemId() -> ItemId { return ItemId(0) }
        
        func addBox(box: Box) { }
        func removeBox(#boxId: BoxId) { }
        
        func box(#boxId: BoxId) -> Box? { return nil }
        
        var boxesStub = [Box]()
        func boxes() -> [Box] {
            return boxesStub
        }
        
        func count() -> Int {
            return 0
        }
    }
    
    class TestProvisioningService: ProvisioningService {
        override func provisionBox(#capacity: BoxCapacity) { }
        
        var provisionedItemTitle: String?
        override func provisionItem(title: String, inBox box: Box) {
            provisionedItemTitle = title
        }
    }
    
    let repository = TestBoxRepository()
    lazy var provisioningService: TestProvisioningService = {
        TestProvisioningService(repository: self.repository)
    }()
    lazy var distributeItem: DistributeItem = {
        DistributeItem(repository: self.repository, provisioningService: self.provisioningService)
    }()
    
    let irrelevantCallback: () -> () = { }
    let shouldNotSucceed = { XCTFail("should not succeed") }
    let shouldNotBeFull = { XCTFail("should not be full") }
    
    func testDistributeItem_WithoutExistingBoxes_RunsErrorCallback() {
        var didFail = false
        let fail = {
            didFail = true
        }
        
        distributeItem.distribute(itemTitle: "irrelevant", successCallback: shouldNotSucceed, noCapacityCallback: fail)
        
        XCTAssert(didFail)
    }

    func testDistributeItem_WithOneEmptyBox_RunsSuccessCallback() {
        repository.boxesStub = [emptyBox()]
        
        var didSucceed = false
        let succeed = {
            didSucceed = true
        }
        
        distributeItem.distribute(itemTitle: "irrelevant", successCallback: succeed, noCapacityCallback: shouldNotBeFull)
        
        XCTAssert(didSucceed)
    }
    
    func emptyBox() -> Box {
        return Box(boxId: BoxId(0), capacity: .Medium, title: "irrelevant")
    }
    
    func testDistributeItem_WithOneEmptyBox_ProvisionsItem() {
        let box = emptyBox()
        repository.boxesStub = [box]
        let itemTitle = "the title"
        
        distributeItem.distribute(itemTitle: itemTitle, successCallback: irrelevantCallback, noCapacityCallback: irrelevantCallback)
        
        if let receivedTitle = provisioningService.provisionedItemTitle {
            XCTAssertEqual(provisioningService.provisionedItemTitle!, itemTitle)
        } else {
            XCTFail("no item provisioned")
        }
    }
    
    func testDistributeItem_WithOneFullBox_RunsErrorCallback() {
        repository.boxesStub = [fullBox()]
        
        var didFail = false
        let fail = {
            didFail = true
        }
        
        distributeItem.distribute(itemTitle: "irrelevant", successCallback: shouldNotSucceed, noCapacityCallback: fail)
        
        XCTAssert(didFail)
    }
    
    func fullBox() -> Box {
        let box = emptyBox()
        
        for index in 1...box.capacity.rawValue {
            box.addItem(Item(itemId: ItemId(1), title: "irrelevant item"))
        }
        
        return box
    }

    func testDistributeItem_WithOneFullAndOneEmptyBox_RunsSuccessCallback() {
        repository.boxesStub = [fullBox(), emptyBox()]
        
        var didSucceed = false
        let succeed = {
            didSucceed = true
        }
        
        distributeItem.distribute(itemTitle: "irrelevant", successCallback: succeed, noCapacityCallback: shouldNotBeFull)
        
        XCTAssert(didSucceed)
    }
    
}
