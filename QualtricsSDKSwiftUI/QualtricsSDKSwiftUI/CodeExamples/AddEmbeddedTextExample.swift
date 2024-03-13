//
//  AddEmbeddedTextExample.swift
//  QualtricsSDKSwiftUI
//
//  Created by Qualtrics on 25/02/2024.
//

import Foundation
import Qualtrics

/// This is a separate class so it's easy to read/find the right code snippet.
class AddEmbeddedTextExample {
    
    /// This function will allow you to log embedded text to your Qualtrics project.
    /// Please beware that **this function will only work *if* you have already called `initializeProject` at least once within the app lifecycle, and recieved the callback.**
    func addEmbeddedText() {
        /// 1. Prepare the instruction to register the visit using the right key as soon as `EvaluateProject` is called.
        Qualtrics.shared.properties.setString(string: "YourEmbeddedDataValue", for: "YourEmbeddedDataKey")
        /// 2. Once `EvaluateProject()` function is called the properties will be updated to the Qualtrics project.
    }
}
