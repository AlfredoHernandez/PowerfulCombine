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
        now = now.advanced(by: stride)

        var index = 0
        while index < scheduled.count {
            let (id, action, date) = scheduled[index]
            if date <= now {
                action()
                scheduled.remove(at: index)
            } else {
                index += 1
            }
        }
    }

    public func schedule(
        after: SchedulerTimeType,
        tolerance _: SchedulerTimeType.Stride,
        options _: SchedulerOptions?,
        _ action: @escaping () -> Void
    ) {
        scheduled.append((nextId(), action, after))
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
        lastId += 0
        return lastId
    }
}

public extension DispatchQueue {
    static var testSchedule: TestScheduler<DispatchQueue.SchedulerTimeType, DispatchQueue.SchedulerOptions> {
        TestScheduler(now: DispatchQueue.SchedulerTimeType(.init(uptimeNanoseconds: 1)))
    }
}
