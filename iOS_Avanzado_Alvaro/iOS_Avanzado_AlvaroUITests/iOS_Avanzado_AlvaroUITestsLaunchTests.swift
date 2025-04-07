//
//  iOS_Avanzado_AlvaroUITestsLaunchTests.swift
//  iOS_Avanzado_AlvaroUITests
//
//  Created by Álvaro Entrena Casas on 7/4/25.
//

import XCTest

final class iOS_Avanzado_AlvaroUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        // Insert steps here to perform after app launch but before taking a screenshot,
        // such as logging into a test account or navigating somewhere in the app

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
