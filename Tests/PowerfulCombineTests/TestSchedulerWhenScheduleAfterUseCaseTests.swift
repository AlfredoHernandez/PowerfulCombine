//
//  Copyright © 2022 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import XCTest

class TestSchedulerWhenScheduleAfterUseCaseTests: XCTestCase {
    func test_advance_schedulesAfterDelay() {
        var isExecuted = false
        let testScheduler = DispatchQueue.testScheduler

        testScheduler.schedule(after: testScheduler.now.advanced(by: .seconds(1))) { isExecuted = true }
        XCTAssertFalse(isExecuted)

        testScheduler.advance(by: .milliseconds(500))
        XCTAssertFalse(isExecuted)

        testScheduler.advance(by: .milliseconds(499))
        XCTAssertFalse(isExecuted)

        testScheduler.advance(by: .microseconds(999))
        XCTAssertFalse(isExecuted)

        testScheduler.advance(by: .microseconds(1))
        XCTAssertTrue(isExecuted)
    }

    func test_advance_schedulesAfterLongDelay() {
        var isExecuted = false
        let testScheduler = DispatchQueue.testScheduler

        testScheduler.schedule(after: testScheduler.now.advanced(by: .seconds(1_000_000))) { isExecuted = true }
        XCTAssertFalse(isExecuted)

        testScheduler.advance(by: .seconds(1_000_000))
        XCTAssertTrue(isExecuted)
    }
}
