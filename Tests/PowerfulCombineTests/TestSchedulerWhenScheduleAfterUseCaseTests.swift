//
//  Copyright © 2022 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import XCTest

class TestSchedulerWhenScheduleAfterUseCaseTests: XCTestCase {
    func test_advance_schedulesAfterDelay() {
        var isExecuted = false
        let testScheduler = DispatchQueue.testSchedule

        testScheduler.schedule(after: testScheduler.now.advanced(by: .seconds(1))) { isExecuted = true }
        XCTAssertFalse(isExecuted)

        testScheduler.advance(by: .milliseconds(500))
        XCTAssertFalse(isExecuted)

        testScheduler.advance(by: .milliseconds(499))
        XCTAssertFalse(isExecuted)

        testScheduler.advance(by: .milliseconds(1))
        XCTAssertTrue(isExecuted)
    }
}
