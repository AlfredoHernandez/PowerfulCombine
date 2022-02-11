//
//  Copyright © 2022 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Combine
import XCTest

final class TestSchedulerWithIntervalUseCaseTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()

    func test_advance_withInterval() {
        var executionCallCount = 0
        let testScheduler = DispatchQueue.testSchedule

        testScheduler.schedule(after: testScheduler.now, interval: .seconds(1)) {
            executionCallCount += 1
        }.store(in: &cancellables)
        XCTAssertEqual(executionCallCount, 0)

        testScheduler.advance()
        XCTAssertEqual(executionCallCount, 1)

        testScheduler.advance(by: .milliseconds(500))
        XCTAssertEqual(executionCallCount, 1)

        testScheduler.advance(by: .milliseconds(499))
        XCTAssertEqual(executionCallCount, 1)

        testScheduler.advance(by: .microseconds(999))
        XCTAssertEqual(executionCallCount, 1)

        testScheduler.advance(by: .microseconds(1))
        XCTAssertEqual(executionCallCount, 2)

        testScheduler.advance(by: .seconds(1))
        XCTAssertEqual(executionCallCount, 3)
    }
}
