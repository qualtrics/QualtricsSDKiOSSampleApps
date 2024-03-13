//
//  QualtricsProjectInfo.swift
//  QualtricsSDKSwiftUI
//
//  Created by Qualtrics on 06/02/2023.
//

import Foundation

/// This is an example on how to extract the most commonly used data for project configuration in one place.
class QualtricsProjectInfo {
    static let shared = QualtricsProjectInfo()
    var projectID: String
    var brandID: String
    /// Unlike *projectID* and *brandID*, not all QualtricsSDK features require *interceptID*s, and there may be more than one so you may want to use an array instead.
    var interceptID: String?

    init(projectID: String = "", brandID: String = "", interceptID: String? = nil) {
        self.projectID = projectID
        self.brandID = brandID
        self.interceptID = interceptID
    }
}
