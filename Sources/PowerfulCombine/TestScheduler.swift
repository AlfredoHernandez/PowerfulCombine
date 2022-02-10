//
//  Copyright © 2022 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Combine
import Foundation

public final class TestScheduler<SchedulerTimeType: Strideable, SchedulerOptions>: Scheduler where SchedulerTimeType.Stride: SchedulerTimeIntervalConvertible {
    public var now: SchedulerTimeType
    public var minimumTolerance: SchedulerTimeType.Stride = 0

    private var scheduled = [() -> Void]()

    public init(now: SchedulerTimeType) {
        self.now = now
    }

    public func schedule(options _: SchedulerOptions?, _ action: @escaping () -> Void) {
        scheduled.append(action)
    }

    public func advance() {
        scheduled.forEach { $0() }
        scheduled.removeAll()
    }

    public func schedule(after _: SchedulerTimeType, tolerance _: SchedulerTimeType.Stride, options _: SchedulerOptions?, _: @escaping () -> Void) {}

    public func schedule(
        after _: SchedulerTimeType,
        interval _: SchedulerTimeType.Stride,
        tolerance _: SchedulerTimeType.Stride,
        options _: SchedulerOptions?,
        _: @escaping () -> Void
    ) -> Cancellable {
        AnyCancellable {}
    }
}
