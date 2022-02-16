//
//  Copyright © 2022 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Combine
import Foundation

public extension Publisher {
    /**
     * If on the main thread, execute work immediately. Else, dispatch the work asynchronously on the main dispatch queue.
     */
    func dispatchOnMainQueue() -> AnyPublisher<Output, Failure> {
        receive(on: DispatchQueue.immediateWhenOnMainQueueScheduler).eraseToAnyPublisher()
    }
}
