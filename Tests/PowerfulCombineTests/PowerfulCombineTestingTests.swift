//
//  Copyright © 2022 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Combine
import PowerfulCombine
import XCTest

final class PowerfulCombineTestingTests: XCTestCase {
    func test_immediateScheduleAction() {
        var isExecuted = false
        let testScheduler = DispatchQueue.testSchedule

        testScheduler.schedule { isExecuted = true }
        XCTAssertFalse(isExecuted, "Expected to no execute the schedule action")

        testScheduler.advance()
        XCTAssertTrue(isExecuted, "Expected to execute the schedule action")
    }

    func test_multipleImmediateScheduleActions() {
        var executionCallCount = 0
        let testScheduler = DispatchQueue.testSchedule

        testScheduler.schedule { executionCallCount += 1 }
        testScheduler.schedule { executionCallCount += 1 }

        XCTAssertEqual(executionCallCount, 0, "Expected no actions executed")

        testScheduler.advance()
        XCTAssertEqual(executionCallCount, 2, "Expected actions executed")
    }

    func test_immediateScheduleWithPublisher() {
        var output = [String]()
        var cancellables = Set<AnyCancellable>()
        let testScheduler = DispatchQueue.testSchedule

        Just("a value")
            .receive(on: testScheduler)
            .sink(receiveValue: { output.append($0) })
            .store(in: &cancellables)
        XCTAssertEqual(output, [], "Expected no emmited values")

        testScheduler.advance()
        XCTAssertEqual(output, ["a value"], "Expected emmited value")
    }
    
    func test_immediateScheduleWithMultiplePublishers() {
        var output = [String]()
        var cancellables = Set<AnyCancellable>()
        let testScheduler = DispatchQueue.testSchedule
        let secondPublisher = Just("another value").receive(on: testScheduler)

        Just("a value")
            .receive(on: testScheduler)
            .merge(with: secondPublisher)
            .sink(receiveValue: { output.append($0) })
            .store(in: &cancellables)
        XCTAssertEqual(output, [], "Expected no emmited values")

        testScheduler.advance()
        XCTAssertEqual(output, ["a value", "another value"], "Expected emmited value")
    }
}
