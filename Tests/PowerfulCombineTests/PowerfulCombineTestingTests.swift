//
//  Copyright © 2022 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Combine
import PowerfulCombine
import XCTest

final class PowerfulCombineTestingTests: XCTestCase {
    func test_immediateScheduleAction() {
        var isExecuted = false
        let sut = DispatchQueue.testSchedule

        sut.schedule { isExecuted = true }
        XCTAssertFalse(isExecuted, "Expected to no execute the schedule action")

        sut.advance()
        XCTAssertTrue(isExecuted, "Expected to execute the schedule action")
    }
}
