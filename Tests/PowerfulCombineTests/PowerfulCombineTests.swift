//
//  Copyright © 2022 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Combine
import PowerfulCombine
import XCTest

final class PowerfulCombineTests: XCTestCase {
    func test_dispatchsOnMainQueue_dispatchesOnMainQueue() {
        let sut = PassthroughSubject<Void, Error>()

        whenDispatchesOnBackground(sut)

        _ = sut.dispatchOnMainQueue().sink { _ in } receiveValue: { _ in
            XCTAssertTrue(Thread.isMainThread, "Expected to receive on main thread.")
        }
    }

    
    // MARK: - Helpers
    
    private func whenDispatchesOnBackground(_ sut: PassthroughSubject<Void, Error>) {
        DispatchQueue.global().async { sut.send(()) }
    }
}
