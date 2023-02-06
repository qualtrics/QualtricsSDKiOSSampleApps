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
    @ObservedObject private var qualtricsProjectInfo = QualtricsProjectInfo.shared

    init() {
        configureQualtricsProjectData()

        Qualtrics.shared.initializeProject(
            brandId: qualtricsProjectInfo.brandID,
            projectId: qualtricsProjectInfo.projectID
        ) { (myInitializationResult) in
            print(myInitializationResult.description)
        }
    }

    private func configureQualtricsProjectData() {
        qualtricsProjectInfo.brandID = "xmmobileint0lhr1"
        qualtricsProjectInfo.projectID = "ZN_29z7vjRzTkCecXc"
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
