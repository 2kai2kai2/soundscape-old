//
//  PreviewBehaviorTest.swift
//  UnitTests
//
//  Created by Kai on 9/19/23.
//  Copyright © 2023 Microsoft. All rights reserved.
//

import XCTest
import CoreLocation
@testable import Soundscape

class PreviewBehaviorTest: XCTestCase {
    class TestMotionActivity: MotionActivityProtocol {
        var isWalking: Bool = true
        var isInVehicle: Bool = false
        var currentActivity: ActivityType = .walking
        func startActivityUpdates() { }
        func stopActivityUpdates() { }
    }
    class TestSpatialData: SpatialDataProtocol {
        static var zoomLevel: UInt = SpatialDataContext.zoomLevel
        static var cacheDistance: CLLocationDistance = SpatialDataContext.cacheDistance
        static var initialPOISearchDistance: CLLocationDistance = SpatialDataContext.initialPOISearchDistance
        static var expansionPOISearchDistance: CLLocationDistance = SpatialDataContext.expansionPOISearchDistance
        static var refreshTimeInterval: TimeInterval = SpatialDataContext.refreshTimeInterval
        static var refreshDistanceInterval: CLLocationDistance = SpatialDataContext.refreshDistanceInterval
        
        var motionActivityContext: MotionActivityProtocol
        var destinationManager: DestinationManagerProtocol
        var state: SpatialDataState = SpatialDataState.waitingForLocation
        var loadedSpatialData: Bool = false
        var currentTiles: [VectorTile] = []
        
        init(_ motionActivity: MotionActivityProtocol, _ destination: DestinationManagerProtocol) {
            motionActivityContext = motionActivity
            destinationManager = destination
        }
        
        func start() { }
        func stop() { }
        func clearCache() -> Bool {
            false
        }
        
        func getDataView(for location: CLLocation, searchDistance: CLLocationDistance) -> SpatialDataViewProtocol? {
            nil
        }
        func getCurrentDataView(searchDistance: CLLocationDistance) -> SpatialDataViewProtocol? {
            nil
        }
        func getCurrentDataView(initialSearchDistance: CLLocationDistance, shouldExpandDataView: @escaping (SpatialDataViewProtocol) -> Bool) -> SpatialDataViewProtocol? {
            nil
        }
        
        func updateSpatialData(at location: CLLocation, completion: @escaping () -> Void) -> Progress? {
            nil
        }
    }
    
    class MockBehaviorDelegate: BehaviorDelegate {
        var event_log: [Event] = []
        
        func interruptCurrent(clearQueue: Bool, playHush: Bool) {
        }
        
        func process(_ event: Event) {
            event_log.append(event)
        }
        
        
    }
    
    // ----
    
    let osm = OSMServiceModel()
    
    let motion = TestMotionActivity()
    let destinationM = DestinationManager(userLocation: nil, audioEngine: AudioEngine(envSettings: TestAudioEnvironmentSettings(), mixWithOthers: true), collectionHeading: Heading(orderedBy: [], course: nil, deviceHeading: nil, userHeading: nil, geolocationManager: nil))
    var intA: Intersection!
    var intersectionA: IntersectionDecisionPoint!
    let geoM = GeolocationManager(isInMotion: false)
    
    var spatial: SpatialDataContext!
    let burdett_sage = CLLocation(latitude: 42.7290570, longitude: -73.6726370)
    let locDetail0_0 = LocationDetail(location: CLLocation(latitude: 0, longitude: 0))
    
    override func setUpWithError() throws {
        // load a tile maybe?
        /*AppContext.shared.geolocationManager.location
        
        spatial = .init(geolocation: geoM, motionActivity: motion, services: <#T##OSMServiceModelProtocol#>, device: <#T##UIDeviceManager#>, destinationManager: destinationM, settings: <#T##SettingsContext#>)
        spatial = .init(location: burdett_sage, range: 250 /*meters*/, zoom: 8, geolocation: geoM, motionActivity: nil, destinationManager: destinationM)
        OSMPOISearchProvider.init()*/
        
        intA = Intersection()
        // We might want to just add a better intersection constructor?
        // I'm doing this hack since I'm not sure about the serialization
        
        // from https://www.openstreetmap.org/node/41721819
        //let json_feature = GeoJsonFeature(json: <#T##[String : Any]#>, superCategories: <#T##SuperCategories#>)
        intA.key = "41721819" // an intersection in Troy, NY
        //Intersection(feature: <#T##GeoJsonFeature#>)
        intA.roadIds.append(IntersectionRoadId(withId: "5615823")) // segment of Burdett Avenue
        intA.roadIds.append(IntersectionRoadId(withId: "282843345")) // segment of Sage Avenue
        
        intersectionA = IntersectionDecisionPoint(node: intA)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testActivate() throws {
        let behavior = PreviewBehavior(at: intersectionA, from: locDetail0_0, geolocationManager: geoM, destinationManager: destinationM)
        let bDelegate = MockBehaviorDelegate()
        behavior.delegate = bDelegate
        
        XCTAssertFalse(behavior.canGoToPrevious)
        XCTAssertEqual(behavior.initialLocation.location.coordinate, locDetail0_0.location.coordinate)
        
        behavior.activate(with: nil)
        guard let previewstartedevent = bDelegate.event_log.first as? PreviewStartedEvent<IntersectionDecisionPoint> else {
            XCTFail("PreviewBehavior.activate() should trigger a PreviewStartedEvent")
            return
        }
        XCTAssertEqual(locDetail0_0.location.coordinate, previewstartedevent.from.location.coordinate)
    }

    /*func testSelect() throws {
        geoM.mockLocation(burdett_sage)
        
        //AppContext.shared.start()
        let expectation = XCTestExpectation()
        sleep(1)
        
        _ = AppContext.shared.spatialDataContext.updateSpatialData(at: burdett_sage) {
            let view = AppContext.shared.spatialDataContext.getDataView(for: self.burdett_sage)
            XCTAssertNil(view)
            XCTAssertNotNil(view)
            expectation.fulfill()
        }
        
        _ = XCTWaiter.wait(for: [expectation])
    }
    
    /// Testing that `select` properly fails if we give bad input
    func testSelect_bad() throws {
        let behavior = PreviewBehavior(at: intersectionA, from: locDetail0_0, geolocationManager: geoM, destinationManager: destinationM)
        let bDelegate = MockBehaviorDelegate()
        behavior.delegate = bDelegate
        
        behavior.select(nil)
        
        XCTAssertNotNil(bDelegate.event_log.first as? PreviewRoadSelectionErrorEvent)
        let views = RoadAdjacentDataView.make(for: intA)
        XCTAssertNotEqual(views.count, 0)
        //behavior.select(views.first)
    }*/
}
