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

    func test_multipleImmediateScheduleActions() {
        var executionCallCount = 0
        let sut = DispatchQueue.testSchedule

        sut.schedule { executionCallCount += 1 }
        sut.schedule { executionCallCount += 1 }

        XCTAssertEqual(executionCallCount, 0, "Expected no actions executed")

        sut.advance()
        XCTAssertEqual(executionCallCount, 2, "Expected actions executed")
    }

    func test_immediateScheduleWithPublisher() {
        var output = [String]()
        var cancellables = Set<AnyCancellable>()
        let sut = DispatchQueue.testSchedule

        Just("a value")
            .receive(on: sut)
            .sink(receiveValue: { output.append($0) })
            .store(in: &cancellables)
        XCTAssertEqual(output, [], "Expected no emmited values")

        sut.advance()
        XCTAssertEqual(output, ["a value"], "Expected emmited value")
    }
}
