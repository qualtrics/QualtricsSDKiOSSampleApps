//
//  QualtricsSDKSwiftUIApp.swift
//  QualtricsSDKSwiftUI
//
//  Created by Qualtrics on 02/02/2023.
//

import SwiftUI
import Qualtrics

@main
struct QualtricsSDKSwiftUIApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    private var qualtricsProjectInfo = QualtricsProjectInfo.shared

    init() {
        configureQualtricsProjectData()

        Qualtrics.shared.initializeProject(
            brandId: qualtricsProjectInfo.brandID,
            projectId: qualtricsProjectInfo.projectID
        ) { (myInitializationResult) in
            print(myInitializationResult.description)
        }
    }

    /// This is an example function allowing you to configure project (hardcode the values)
    private func configureQualtricsProjectData() {
        qualtricsProjectInfo.brandID = "YourBrandID"
        qualtricsProjectInfo.projectID = "YourProjectID"
        qualtricsProjectInfo.interceptID = "YourInterceptID"
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
