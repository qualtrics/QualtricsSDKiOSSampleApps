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
        VStack(alignment: .leading, spacing: 18) {
            Spacer()
            Button("Evaluate project button") {
                viewModel.evaluateProjectButtonTapped()
            }
            Button("Evaluate second intercept button") {
                viewModel.evaluateInterceptButtonTapped()
            }
            Button("Ask for review button") {
                viewModel.requestReviewWithQualtrics()
            }
            Button("Simple Custom Survay Invitation Dialog Button") {
                viewModel.simpleCustomSurvayInvitationDialog()
            }
            Button("Give Feedback Prompt Bypass Button") {
                viewModel.giveFeedbackPromptBypassButtonTapped()
            }
            Spacer()
        }
        .padding()
        .onAppear {
            viewModel.registerViewVisit()
            viewModel.addEmbeddedText()
        }
    }
}

