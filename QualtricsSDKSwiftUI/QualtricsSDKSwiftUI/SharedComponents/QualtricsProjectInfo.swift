//
//  QualtricsProjectInfo.swift
//  QualtricsSDKSwiftUI
//
//  Created by Natalie Niziolek on 06/02/2023.
//

import Foundation

/// This is an example on how to extract the most commonly used data for project configuration in one place.
class QualtricsProjectInfo: ObservableObject {
    static let shared = QualtricsProjectInfo()
    @Published var projectID: String
    @Published var brandID: String
    @Published var interceptIDs: [String]?

    init(projectID: String = "", brandID: String = "", interceptIDs: [String]? = nil) {
        self.projectID = projectID
        self.brandID = brandID
        self.interceptIDs = interceptIDs
    }
}
