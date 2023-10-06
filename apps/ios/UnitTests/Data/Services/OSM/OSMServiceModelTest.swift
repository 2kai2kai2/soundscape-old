//
//  OSMServiceModelTest.swift
//  
//
//  Created by Kai on 9/29/23.
//

import XCTest
@testable import Soundscape

final class OSMServiceModelTest: XCTestCase {
    let osm = OSMServiceModel()
    let tile0_0 = VectorTile(latitude: 0, longitude: 0, zoom: 16)
    let tileRPI = VectorTile(latitude: 42.73036, longitude: -73.67663, zoom: 16)
    
    func testGetTileData() throws {
        let expectation = XCTestExpectation()
        
        osm.getTileData(tile: tile0_0, categories: [:]) {status,tiledata,err in
            XCTAssertNil(err)
            XCTAssertEqual(status, .success)
            XCTAssertNotNil(tiledata)
            
            // Check stuff
            XCTAssertEqual(tiledata, TileData())
            expectation.fulfill()
        }
        
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 10), .completed, "OSM getTileData timed out")
    }

}
