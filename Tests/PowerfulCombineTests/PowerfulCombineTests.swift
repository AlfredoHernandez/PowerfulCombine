//
//  Copyright © 2022 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Combine
import PowerfulCombine
import XCTest

final class PowerfulCombineTests: XCTestCase {
    private var cancellable: AnyCancellable?

    func test_dispatchsOnMainQueue_dispatchesOnMainQueue() {
        let sut = PassthroughSubject<Void, Error>()

        whenDispatchesOnBackground(sut)

        cancellable = sut.dispatchOnMainQueue().sink { _ in } receiveValue: { _ in
            XCTAssertTrue(Thread.isMainThread, "Expected to receive on main thread.")
        }
    }

    func test_fallback_catchesErrorAndContinueWithFallbackPublisher() {
        let sut = PassthroughSubject<String, Error>()
        let fallbackPublisher = PassthroughSubject<String, Error>()
        let exp = expectation(description: "Wait for subscription")

        cancellable = sut
            .eraseToAnyPublisher()
            .dispatchOnMainQueue()
            .fallback(to: fallbackPublisher.eraseToAnyPublisher())
            .sink(receiveCompletion: { _ in }, receiveValue: { fallbackValue in
                XCTAssertEqual(fallbackValue, "The fallback value")
                exp.fulfill()
            })

        sut.send(completion: .failure(AnyError()))
        fallbackPublisher.send("The fallback value")
        wait(for: [exp], timeout: 1.0)
    }

    func test_aScheduler_canBeErasedToAnyScheduler() {
        let sut = DispatchQueue
            .global()
            .eraseToAnyScheduler()

        XCTAssertNotNil(sut, "Expected a scheduler erased to AnyScheduler")
    }

    // MARK: - Powerful Combine Testing

    func test_immediateScheduleAction() {
        var isExecuted = false
        let sut = DispatchQueue.testSchedule

        sut.schedule { isExecuted = true }
        XCTAssertFalse(isExecuted, "Expected to no execute the schedule action")

        sut.advance()
        XCTAssertTrue(isExecuted, "Expected to execute the schedule action")
    }

    // MARK: - Helpers

    private func whenDispatchesOnBackground(_ sut: PassthroughSubject<Void, Error>) {
        DispatchQueue.global().async { sut.send(()) }
    }

    private class AnyError: Error {}
}
