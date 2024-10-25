//
//  TrackerTests.swift
//  TrackerTests
//
//  Created by Anton Demidenko on 25.10.24..
//

import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {
    
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
