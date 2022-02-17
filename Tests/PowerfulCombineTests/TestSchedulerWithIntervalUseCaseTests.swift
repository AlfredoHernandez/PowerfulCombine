//
//  Copyright © 2022 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Combine
import XCTest

final class TestSchedulerWithIntervalUseCaseTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()

    func test_advance_withInterval() {
        var executionCallCount = 0
        let testScheduler = DispatchQueue.testScheduler

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

        testScheduler.advance(by: .seconds(2))
        XCTAssertEqual(executionCallCount, 5, "Expected to increment two executions more")

        testScheduler.advance(by: .seconds(5))
        XCTAssertEqual(executionCallCount, 10, "Expected to increment five executions more")
    }

    func test_whenScheduleTwoIntervals_keepsTrackingInOrder() {
        let testScheduler = DispatchQueue.testScheduler
        var values: [String] = []

        testScheduler.schedule(after: testScheduler.now.advanced(by: 1), interval: .seconds(1)) {
            values.append("Hello")
        }.store(in: &cancellables)
        testScheduler.schedule(after: testScheduler.now.advanced(by: 2), interval: .seconds(2)) {
            values.append("World")
        }.store(in: &cancellables)
        XCTAssertEqual(values, [])

        testScheduler.advance(by: 2)
        XCTAssertEqual(values, ["Hello", "Hello", "World"])
    }

    // MARK: This test behaves differently on M1 and Intel chips.

    func test_scheduleNow() {
        var times: [UInt64] = []
        let testScheduler = DispatchQueue.testScheduler
        testScheduler.schedule(after: testScheduler.now, interval: 1) {
            times.append(testScheduler.now.dispatchTime.uptimeNanoseconds)
        }
        .store(in: &cancellables)

        XCTAssertEqual(times, [])
        testScheduler.advance(by: 3)

        if ProcessInfo().machineHardwareName == "arm64" {
            XCTAssertEqual(times, [41, 1_000_000_041, 2_000_000_041, 3_000_000_041])
        } else {
            XCTAssertEqual(times, [1, 1_000_000_001, 2_000_000_001, 3_000_000_001])
        }
    }

    func test_verify_schedulerRunsNTimes() {
        var values = [Int]()
        let testScheduler = DispatchQueue.testScheduler

        testScheduler.schedule(after: testScheduler.now, interval: .seconds(1)) {
            values.append(values.count)
        }.store(in: &cancellables)
        XCTAssertEqual(values, [], "Expected no captured values")

        testScheduler.advance(by: .seconds(1000))
        XCTAssertEqual(values, Array(0 ... 1000))
    }

    func test_scheduleInterval_whenCancelSchedule() {
        var executionCallCount = 0
        let testScheduler = DispatchQueue.testScheduler

        testScheduler.schedule(after: testScheduler.now, interval: .seconds(1)) {
            executionCallCount += 1
        }.store(in: &cancellables)
        XCTAssertEqual(executionCallCount, 0)

        testScheduler.advance()
        XCTAssertEqual(executionCallCount, 1)

        whenCancelScheduler()
        testScheduler.advance(by: .seconds(1))
        XCTAssertEqual(executionCallCount, 1, "Expected to cancel the schedule")
    }

    private func whenCancelScheduler() {
        cancellables.removeAll()
    }
}

extension ProcessInfo {
    /// Returns a `String` representing the machine hardware name or nil if there was an error invoking `uname(_:)` or decoding the response.
    ///
    /// Return value is the equivalent to running `$ uname -m` in shell.
    var machineHardwareName: String? {
        var sysinfo = utsname()
        let result = uname(&sysinfo)
        guard result == EXIT_SUCCESS else { return nil }
        let data = Data(bytes: &sysinfo.machine, count: Int(_SYS_NAMELEN))
        guard let identifier = String(bytes: data, encoding: .ascii) else { return nil }
        return identifier.trimmingCharacters(in: .controlCharacters)
    }
}
