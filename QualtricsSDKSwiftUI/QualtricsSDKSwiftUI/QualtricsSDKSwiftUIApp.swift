//
//  QualtricsSDKSwiftUIApp.swift
//  QualtricsSDKSwiftUI
//
//  Created by Natalie Niziolek on 02/02/2023.
//

import SwiftUI
import Qualtrics

@main
struct QualtricsSDKSwiftUIApp: App {

    init() {
        Qualtrics.shared.initializeProject(brandId: "YourBrandId", projectId: "YourProjectId") { (myInitializationResult) in
            print(myInitializationResult.description)
        }
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
