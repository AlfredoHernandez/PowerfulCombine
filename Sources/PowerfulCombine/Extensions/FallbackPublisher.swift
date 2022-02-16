//
//  Copyright © 2022 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Combine
import Foundation

public extension Publisher {
    /**
     If first `Publisher` fails, then error is ignored and continue with a fallback version of it.
     - Parameters:
        - fallbackPublisher: A fallback version of the desired publisher
     - Returns: An `AnyPublisher` with the same `Output` and `Failure`
     */
    func fallback(to fallbackPublisher: AnyPublisher<Output, Failure>) -> AnyPublisher<Output, Failure> {
        self.catch { _ in fallbackPublisher }.eraseToAnyPublisher()
    }
}
