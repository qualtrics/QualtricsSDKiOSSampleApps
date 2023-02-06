//
//  ContentView.swift
//  QualtricsSDKSwiftUI
//
//  Created by Natalie Niziolek on 02/02/2023.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = MainViewModel()

    var body: some View {
        VStack {
            Spacer()
            Button("Evaluate project button") {
                viewModel.evaluateProjectButtonTapped()
            }
            Spacer()
            Button("Evaluate second intercept button") {
                viewModel.evaluateInterceptButtonTapped()
            }
            Spacer()
            Button("Ask for review button") {
                viewModel.requestReviewWithQualtrics()
            }
            Spacer()
        }
        .padding()
        .onAppear {
            viewModel.registerViewVisit()
            viewModel.AddEmbeddedText()
        }
    }
}
