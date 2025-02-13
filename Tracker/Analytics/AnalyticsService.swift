//
//  AnalyticsService.swift
//  Tracker
//
//  Created by Anton Demidenko on 24.10.24..
//
import AppMetricaCore

struct AnalyticsService {
    static func activate() {
        guard let configuration = AppMetricaConfiguration(apiKey: "5f082272-89cf-4f50-8e86-b7e7965167a0") else { return }
        
        AppMetrica.activate(with: configuration)
    }
    
    static func reportScreenOpened(screen: String) {
        let params: [AnyHashable: Any] = ["event": "open", "screen": screen]
        report(event: "Screen Event", params: params)
    }
    
    static func reportScreenClosed(screen: String) {
        let params: [AnyHashable: Any] = ["event": "close", "screen": screen]
        report(event: "Screen Event", params: params)
    }

    static func reportButtonClick(screen: String, item: String) {
        let params: [AnyHashable: Any] = [
            "event": "click",
            "screen": screen,
            "item": item
        ]
        report(event: "Button Click", params: params)
    }
    
    static func report(event: String, params: [AnyHashable: Any]) {
        AppMetrica.reportEvent(name: event, parameters: params, onFailure: { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        })
    }
}
