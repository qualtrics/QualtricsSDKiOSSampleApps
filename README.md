# QualtricsSDK + SwiftUI
This is a sample application with examples of using [Qualtrics iOS SDK](https://api.qualtrics.com/2241421657525-getting-started-with-the-mobile-app-sdk-on-i-os) with SwiftUI.

## Using the App
1. [Clone](https://docs.github.com/en/repositories/creating-and-managing-repositories/cloning-a-repository) this repository.
2. Open the project file with xCode (This App has been tested with `xCode 15.3`).
3. That's it! If you want to learn more  - **view documentation, sample use-cases, changelog and more on https://api.qualtrics.com **

## Issues / Support
For help on the Qualtrics SDK, you will want to reach out to our support team via our [Support Portal](https://www.qualtrics.com/support/). If you do not have a login, please work with your brand admin to file a support ticket. We do not take support requests or community PRs through GitHub.

## Troubleshooting

### Project Initialization issues
Please make sure you're running `initializeProject`, and then await for the callback before you try to use any other functions from the SDK. Not respecting this flow will result in intercepts failing the display evaluation logic, and not displaying properly.

### UIKit issues
Please beware that this SDK is implemented using UIKit, so all the functions handling UIKit objects need to be run on the main thread.
