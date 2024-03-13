//
//  GettingCurrentWindowScene.swift
//  QualtricsSDKSwiftUI
//
//  Created by Qualtrics on 25/02/2024.
//

import Foundation
import UIKit

/// This is a separate class so it's easy to read/find the right code snippet.
class GettingCurrentWindowSceneExample {
    
    /// This is an example implementation of a function that will determine the right UIWindowScene that is currently being used in the foreground of the app.
    func getCurrentWindowScene(completion: @escaping (UIWindowScene?) -> Void) {
        
        /// 1. Make sure to run this on the main thread.
        DispatchQueue.main.async {

            /// 2. Return the scene that is currently first on the list.
            return completion(UIApplication.shared.connectedScenes.first as? UIWindowScene)
        }
    }
}
