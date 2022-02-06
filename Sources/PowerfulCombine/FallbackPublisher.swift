//
//  Copyright © 2022 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Combine
import Foundation

public extension Publisher {
    func fallback(to fallbackPublisher: AnyPublisher<Output, Failure>) -> AnyPublisher<Output, Failure> {
        self.catch { _ in fallbackPublisher }.eraseToAnyPublisher()
    }
}
