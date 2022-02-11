//
//  Copyright © 2022 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Combine
import Foundation

public final class TestScheduler<SchedulerTimeType: Strideable, SchedulerOptions>: Scheduler where SchedulerTimeType.Stride: SchedulerTimeIntervalConvertible {
    public var now: SchedulerTimeType
    public var minimumTolerance: SchedulerTimeType.Stride = 0

    private var scheduled = [(action: () -> Void, date: SchedulerTimeType)]()

    public init(now: SchedulerTimeType) {
        self.now = now
    }

    public func schedule(options _: SchedulerOptions?, _ action: @escaping () -> Void) {
        scheduled.append((action, now))
    }

    public func advance(by stride: SchedulerTimeType.Stride = .zero) {
        now = now.advanced(by: stride)

        for (action, date) in scheduled {
            if date <= now {
                action()
            }
        }
        scheduled.removeAll(where: { $0.date <= self.now })
    }

    public func schedule(
        after: SchedulerTimeType,
        tolerance _: SchedulerTimeType.Stride,
        options _: SchedulerOptions?,
        _ action: @escaping () -> Void
    ) {
        scheduled.append((action, after))
    }

    public func schedule(
        after date: SchedulerTimeType,
        interval: SchedulerTimeType.Stride,
        tolerance _: SchedulerTimeType.Stride,
        options _: SchedulerOptions?,
        _ action: @escaping () -> Void
    ) -> Cancellable {
        func scheduleAction(for date: SchedulerTimeType) -> () -> Void {
            { [weak self] in
                action()
                let nextDate = date.advanced(by: interval)
                self?.scheduled.append((scheduleAction(for: nextDate), nextDate))
            }
        }

        scheduled.append((scheduleAction(for: date), date))
        return AnyCancellable {}
    }
}

public extension DispatchQueue {
    static var testSchedule: TestScheduler<DispatchQueue.SchedulerTimeType, DispatchQueue.SchedulerOptions> {
        TestScheduler(now: DispatchQueue.SchedulerTimeType(.init(uptimeNanoseconds: 1)))
    }
}
