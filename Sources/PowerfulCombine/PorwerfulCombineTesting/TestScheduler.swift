//
//  Copyright © 2022 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Combine
import Foundation

public final class TestScheduler<SchedulerTimeType: Strideable, SchedulerOptions>: Scheduler where SchedulerTimeType.Stride: SchedulerTimeIntervalConvertible {
    public var now: SchedulerTimeType
    public var minimumTolerance: SchedulerTimeType.Stride = 0
    private var lastId = 0
    private var scheduled = [(id: Int, action: () -> Void, date: SchedulerTimeType)]()

    public init(now: SchedulerTimeType) {
        self.now = now
    }

    public func schedule(options _: SchedulerOptions?, _ action: @escaping () -> Void) {
        scheduled.append((nextId(), action, now))
    }

    public func advance(by stride: SchedulerTimeType.Stride = .zero) {
        scheduled.sort { lhs, rhs in
            (lhs.date, lhs.id) < (rhs.date, rhs.id)
        }

        guard
            let nextDate = scheduled.first?.date,
            self.now.advanced(by: stride) >= nextDate
        else {
            now = now.advanced(by: stride)
            return
        }

        let nextStride = stride - now.distance(to: nextDate)
        now = nextDate

        while let (_, action, date) = scheduled.first, date == nextDate {
            action()
            scheduled.removeFirst()
        }

        advance(by: nextStride)
        scheduled.removeAll(where: { $0.date <= self.now })
    }

    public func schedule(
        after date: SchedulerTimeType,
        tolerance _: SchedulerTimeType.Stride,
        options _: SchedulerOptions?,
        _ action: @escaping () -> Void
    ) {
        scheduled.append((nextId(), action, date))
    }

    public func schedule(
        after date: SchedulerTimeType,
        interval: SchedulerTimeType.Stride,
        tolerance _: SchedulerTimeType.Stride,
        options _: SchedulerOptions?,
        _ action: @escaping () -> Void
    ) -> Cancellable {
        let id = nextId()
        func scheduleAction(for date: SchedulerTimeType) -> () -> Void {
            { [weak self] in
                action()
                let nextDate = date.advanced(by: interval)
                self?.scheduled.append((id, scheduleAction(for: nextDate), nextDate))
            }
        }

        scheduled.append((id, scheduleAction(for: date), date))
        return AnyCancellable { [weak self] in
            self?.scheduled.removeAll(where: { $0.id == id })
        }
    }

    private func nextId() -> Int {
        lastId += 1
        return lastId
    }
}

public extension DispatchQueue {
    static var testScheduler: TestScheduler<DispatchQueue.SchedulerTimeType, DispatchQueue.SchedulerOptions> {
        TestScheduler(now: DispatchQueue.SchedulerTimeType(.init(uptimeNanoseconds: 1)))
    }
}
