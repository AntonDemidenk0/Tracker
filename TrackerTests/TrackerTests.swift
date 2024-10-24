//
//  TrackerTests.swift
//  TrackerTests
//
//  Created by Anton Demidenko on 24.10.24..
//

import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        
    }
    
    func testViewControllerInLightMode() {
        
        let vc = TrackersViewController()
        
        vc.overrideUserInterfaceStyle = .light
        
        vc.view.frame = UIScreen.main.bounds
        vc.view.layoutIfNeeded()
        
        assertSnapshot(matching: vc, as: .image)
    }
    
    func testViewControllerInDarkMode() {
        
        let vc = TrackersViewController()
        
        vc.overrideUserInterfaceStyle = .dark
        
        vc.view.frame = UIScreen.main.bounds
        vc.view.layoutIfNeeded()
        
        assertSnapshot(matching: vc, as: .image)
    }
}
