import XCTest
import SwiftUI
import UIKit
@testable import PawLink

final class RootViewSnapshotTests: XCTestCase {
    func testRootViewRenders() {
        let view = RootView()
            .environmentObject(AppCoordinator())
            .environmentObject(ApplicationEnvironment.preview)
        let renderer = ImageRenderer(content: view)
        let image = renderer.uiImage
        XCTAssertNotNil(image)
    }
}
